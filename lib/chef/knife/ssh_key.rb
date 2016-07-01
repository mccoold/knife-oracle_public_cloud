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
    require 'chef/knife/opc_base'
    require 'chef/knife/util'
    require 'OPC'
    require 'opc_client'
    require 'chef/node'
    require 'chef/knife/base_options'
      
    deps do
      require 'chef/json_compat'
      require 'chef/knife/bootstrap'
      Chef::Knife::Bootstrap.load_deps
    end # end of deps
    class OpcSshkeyUpdate < Chef::Knife
      include Knife::OpcOptions
      include Knife::OpcBase
      banner 'knife opc sshkey update (options)'
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
        :description => 'action options: create, delete'
      option :container,
        :long        => '--container CONTAINER',
        :description => 'container name for OPC IaaS Compute'

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
        sshkeyconfig = SshkeyClient.new
        print ui.color(sshkeyconfig.update(config), :green) if config[:action]  == 'create'
        print ui.color(sshkeyconfig.update(config), :red) if config[:action]  == 'delete'
      end # end of run
    end # end of update

    class OpcSshkeyShow < Chef::Knife
      include Knife::OpcOptions
      include Knife::OpcBase
      require 'opc_client'
      banner 'knife opc sshkey show (options)'

      option :rest_endpoint,
        :short       => '-R',
        :long        => '--rest_endpoint REST_ENDPOINT',
        :description => 'Rest end point for OPC IaaS Compute',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :action,
        :short       => '-A',
        :long        => '--action ACTION',
        :description => 'action options list or details'
      option :container,
        :long        => '--container CONTAINER',
        :description => 'container name for OPC IaaS Compute'

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
        sshkeyconfig = SshkeyClient.new
        print ui.color(sshkeyconfig.list(config), :green)
      end # end of run
    end # end of list
  end # end of knife
end # end of Chef
