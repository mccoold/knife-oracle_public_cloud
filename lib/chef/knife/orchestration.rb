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

      include Knife::ChefBase
      include Knife::OpcOptions
      include Knife::OpcBase
      include Knife::OrchJson
      include Knife::NimbulaOptions

      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps

      banner 'knife opc orchestration (options)'
      option :create_json,
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
         :description => 'container name for OPC IaaS Compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:container] = key }
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
      option :node_ssl_verify_mode,
        :long        => "--node-ssl-verify-mode [peer|none]",
        :description => "Whether or not to verify the SSL cert for all HTTPS requests.",
        :proc        => Proc.new { |v|
          valid_values = %w{none peer}
          unless valid_values.include?(v)
            raise "Invalid value '#{v}' for --node-ssl-verify-mode. Valid values are: #{valid_values.join(", ")}"
          end
          v
        }

      def run # rubocop:disable Metrics/AbcSize
        validate!
        # check and load values from knife.rb if present
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
        # create the orchestration client object
        @orch = OrchClient.new
        # populate setter methods needed
        @orch.options = config
        @orch.orch = Orchestration.new(config)
        @orch.util = Utilities.new
        case config[:action]
        when 'list', 'details'
          attrcheck = { 'container'  => config[:container] }
          @validate.attrvalidate(config, attrcheck)
          print ui.color(@orch.list, :green)
        when 'create', 'update', 'delete'
          attrcheck = { 'create_json' => config[:create_json] } unless config[:action].downcase == 'delete'
          attrcheck = { 'container' => config[:container] } if config[:action].downcase == 'delete'
          @validate.attrvalidate(config, attrcheck)
          print ui.color(@orch.update, :green)
        when 'start', 'stop'
          attrcheck = { 'container' => config[:container],
                        'IP address access' => config[:ip_access] }
          @validate.attrvalidate(config, attrcheck)
          # get the orchestration from the system
          yuuup = @orch.list if config[:action] == 'stop'
          # this starts the orchestration in OPC
          yuuup = @orch.manage if config[:action] == 'start'
          # check for a master orchestration
          master_orchcall = master_orch(yuuup)
          if master_orchcall == 'null'
            # @parent maintains the top orchestration in the event of nested orchestrations
            @parent = config[:container]
            # handles to building and destroying of the node on the Chef server if there is no master orch
            chef_instance_build(yuuup)
            #chef_instance_build(@orch.list)
          else
            @parent = config[:container]
            # handles to building and destroying of the node on the Chef server if there is nested orch
            # it parses through all the oplans looking for launch plans and the instances
            # chef bootstrap runs serially
            master_orchcall.each do |orchlist|
              config[:container] = orchlist
              @orch.options = config
              chef_instance_build(@orch.list)
            end
          end
        end
      end

      # sets values for the node in Chef and values to be read during the Chef bootstrap
#      def chef_node_configuration(instance) # rubocop:disable Metrics/AbcSize
#        Chef::Config[:knife][:environment] = instance['environment'] unless instance['environment'].nil?
#        config[:environment] = Chef::Config[:knife][:environment] unless instance['environment'].nil?
#        Chef::Config[:knife][:chef_node_name] = instance['label']
#        config[:chef_node_name] = instance['label']
#        config[:run_list] = instance['runlist'] unless  instance['runlist'].nil?
#        config[:tags] = instance['tags'] unless instance['tags'].nil?
#        config[:ssh_user] = instance['ssh_user'] unless instance['ssh_user'].nil?
#      end

      #  populates some custom ohai values
      def node_update(ssh_host, private_ip) # rubocop:disable Metrics/AbcSize
        node = Chef::Node.load(config[:chef_node_name]) unless config[:action] == 'stop'
        node.chef_environment = Chef::Config[:knife][:environment] unless config[:action] == 'stop'
        node.normal_attrs = { 'Cloud' => { 'provider' => 'Oracle Public Cloud', 'Service' => 'Compute',
                                           'public_ips' => ssh_host, 'private_ips' => private_ip,
                                           'ID_DOMAIN' => config[:id_domain] } }  unless config[:action] == 'stop'
        config[:tags].each do |tag|
          node.tags << tag
        end
        node.save unless config[:action] == 'stop'
      end

      # builds or destroys the instance in chef
      # pulling the instance data from the launch plan section of the orchestration
      def chef_instance_build(orchestration) # rubocop:disable Metrics/AbcSize
        instance_data = orch_json_parse(orchestration)
        instanceconfig = Instance.new(config)
        # iterate through all of the instnaces listed in the launch plan in case there is more than one
        instance_data.each do |instance|
          instance_IP = instanceconfig.list_ip(instance['name'])
          ssh_host = instance_IP[1] if config[:ip_access] == 'public'
          ssh_host = instance_IP[0] if config[:ip_access] == 'private'
          # populate the Chef config object with values before calling bootstrat
          chef_node_configuration(instance)
          puts config[:chef_node_name]
          chef_delete if config[:action] == 'stop' && config[:purge] == true
          sleep 20 if config[:action] == 'start'
          # calling the chef bootstrap method
          bootstrap_for_linux_node(ssh_host).run if config[:action] == 'start'
          instance['chefenvironment'] = '_default' if instance['chefenvironment'].nil?
          # update some node attributes that will not be done by ohai by default
          node_update(ssh_host, instance_IP[0]) unless config[:action] == 'stop'
        end # end of loop
        config[:container] = @parent if config[:action] == 'stop'
        @orch.options = config if config[:action] == 'stop'
        print ui.color(@orch.manage, :yellow) if config[:action] == 'stop'
      end
    end
  end
end
