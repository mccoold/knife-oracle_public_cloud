# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Knife
    class OpcOrchestration < Chef::Knife
      require 'chef/knife/opc_base'
      require 'chef/knife/util'
      require 'OPC'
      require 'opc_client'
      require 'chef/node'
      require 'chef/knife/base_options'
      include Knife::OpcOptions
      include Knife::OpcBase
      include Knife::OrchJson
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      
      banner 'knife opc orchestration (options)'
      option :create_json,
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe orchestration'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for OPC IaaS Compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :action,
         :short       => '-A',
         :long        => '--action ACTION',
         :description => 'action options list or details, create, stop, start'
      option :container,
         :long        => '--container CONTAINER',
         :description => 'container name for OPC IaaS Compute'
      option :track,
         :long        => '--track',
         :description => 'tracks the install',
         :default     => 'true'
      option :ip_access,
         :long        => '--ip_access IP_ACCESS',
         :description => 'is the Chef server talkig to public or private IP',
         :default     => 'public'
      option :purge,
        :long        => '--purge',
        :boolean     => true,
        :default     => false,
        :description => 'Destroy corresponding node and client on the Chef Server.
        Assumes node and client have the same name as the server (if not, add the --node-name option).'

      def run # rubocop:disable Metrics/AbcSize
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        config[:purge] = locate_config_value(:purge)
        attrcheck = {
          'Action'          => config[:action],
          'Rest End Point'  => config[:rest_endpoint]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        orch = OrchClient.new
        orch.options = config
        orch.orch = Orchestration.new(config[:id_domain], config[:user_name], config[:passwd], config[:rest_endpoint])
        orch.util = Utilities.new
        case config[:action]
        when 'list', 'details'
          attrcheck = { 'container'  => config[:container] }
          @validate.attrvalidate(config, attrcheck)
          print ui.color(orch.list, :green)
        when 'create', 'update', 'delete'
          attrcheck = { 'create_json' => config[:create_json] } unless config[:action].downcase == 'delete'
          attrcheck = { 'container' => config[:container] } if config[:action].downcase == 'delete'
          @validate.attrvalidate(config, attrcheck)
          print ui.color(orch.update, :green)
        when 'start', 'stop'
          attrcheck = { 'container' => config[:container],
                        'IP address access' => config[:ip_access] }
          @validate.attrvalidate(config, attrcheck)
          instance_data = orch_json_parse(orch.list) if config[:action] == 'stop'
          instance_data = orch_json_parse(orch.manage) if config[:action] == 'start'
          instanceconfig = Instance.new(config[:id_domain], config[:user_name], config[:passwd], config[:rest_endpoint])
          instance_data.each do |instance|
            instance_IP = instanceconfig.list_ip(instance['name'])
            ssh_host = instance_IP[1] if config[:ip_access] == 'public'
            ssh_host = instance_IP[0] if config[:ip_access] == 'private'
            chef_node_configuration(instance)
            puts config[:chef_node_name]
            chef_delete if config[:action] == 'stop' && config[:purge] == true
            sleep 20 if config[:action] == 'start'
            bootstrap_for_linux_node(ssh_host).run if config[:action] == 'start'
            instance['chefenvironment'] = '_default' if instance['chefenvironment'].nil?
            node_update(ssh_host, instance_IP[0]) unless config[:action] == 'stop'
          end # end of loop
          print ui.color(orch.manage, :yellow) if config[:action] == 'stop'
        end # end of case
      end # end of run

      def chef_node_configuration(instance) # rubocop:disable Metrics/AbcSize
        Chef::Config[:knife][:environment] = instance['chefenvironment'] unless instance['chefenvironment'].nil?
        config[:environment] = Chef::Config[:knife][:environment] unless instance['chefenvironment'].nil?
        Chef::Config[:knife][:chef_node_name] = instance['label']
        config[:chef_node_name] = instance['label']
        config[:run_list] = instance['runlist'] unless  instance['runlist'].nil?
        config[:tags] = instance['tags'] unless instance['tags'].nil?
        config[:ssh_user] = instance['ssh_user'] unless instance['ssh_user'].nil?
      end
      
      def node_update(ssh_host, private_ip)
        node = Chef::Node.load(config[:chef_node_name]) unless config[:action] == 'stop'
            node.chef_environment = Chef::Config[:knife][:environment] unless config[:action] == 'stop'
            node.normal_attrs = { 'cloud' => { 'Note' => 'ignore this attribute, its wrong an Ohai bug' },
                                  'Cloud' => { 'provider' => 'Oracle Public Cloud', 'Service' => 'Compute',
                                               'public_ips' => ssh_host, 'private_ips' => private_ip,
                                               'ID_DOMAIN' => config[:id_domain] } }  unless config[:action] == 'stop'
            config[:tags].each do |tag|
              node.tags << tag
            end
            node.save unless config[:action] == 'stop'
      end
    end # end of orch
  end # end of knife
end # end of chef
