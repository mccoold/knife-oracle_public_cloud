# Author:: Daryn McCool (<mdaryn@hotmail.com>)
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
    require 'chef/knife/fmwbase'
    require 'chef/knife/base_options'
    require 'OPC'
    class OpcSoaCreate < Chef::Knife
      include Knife::OpcBase
      include Knife::FmwBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps

      banner 'knife opc soa create (options)'

      option :create_json,
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe OPC Instance'
      option :json_attributes,
         :long        => '--json-attributes JSON_ATTRIBS',
         :description => 'A JSON string that is added to the first run of a chef-client'
      option :chef_node_name,
         :short       => '-N NAME',
         :long        => '--node-name NAME',
         :description => 'The Chef node name for your new node',
         :proc        => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }
      option :paas_rest_endpoint,
        :long         => '--paas_rest_endpoint PAASREST',
        :description  => 'REST end point for PaaS services not in the US'

      def run
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        fmw_create(config, 'soa')
      end # end of run
    end # end of create

class OpcSoaList < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'OPC'
      end # end of deps
      banner 'knife opc soa list (options)'
      option :inst,
        :short        => '-I INST',
        :long         => '--instance INST',
        :description  => 'force delete of the JCS Instance'
      option :paas_rest_endpoint,
        :long         => '--paas_rest_endpoint PAASREST',
        :description  => 'REST end point for PaaS services not in the US'

      def run # rubocop:disable Metrics/AbcSize
        validate!
        # loading values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        # even with attcheck nil, method attrvalidate still checks for user, pass, iddomain
        attrcheck = nil
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        # for values passed in for PaaS REST end point
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], 'soa') if config[:paas_rest_endpoint]
        result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], 'soa')
        result.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        result = result.service_list unless config[:inst]
        result = result.inst_list(config[:inst]) if config[:inst]
        if result.code == '401' || result.code == '400' || result.code == '404' || result.code == '500'
          print ui.color('Error with REST call, returned http code: ' + result.code + ' ', :red, :bold)
          print ui.color(result.body, :red)
        else
          print ui.color(JSON.pretty_generate(JSON.parse(result.body)), :green)
          puts ''
        end # end of if
      end # end of run
    end # end of list

    class OpcSoaDelete < Chef::Knife
      include Knife::OpcBase
      include Knife::FmwBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps

      banner 'knife opc soa delete (options)'

      option :purge,
        :long        => '--purge',
        :boolean     => true,
        :default     => false,
        :description => 'Destroy corresponding node and client on the Chef Server.
        Assumes node and client have the same name as the server (if not, add the --node-name option).'

      option :chef_node_name,
        :short       => '-N NAME',
        :long        => '--node-name NAME',
        :description => 'The name of the node and client to delete, if it differs from the server name.
                         Only has meaning when used with the --purge option.'
      option :dbaname,
        :long         => '--dbaname DBANAME',
        :default      => 'sys',
        :description  => 'DBA user ID for the DB that Weblogic is connected too'
      option :dbapass,
        :long         => '--dbapass DBAPASS',
        :default      => 'sys',
        :description  => 'DBA user password for the DB that Weblogic is connected too'
      option :forcedelete,
        :long         => '--soaforce',
        :boolean     => true,
        :default     => true,
        :description  => 'force delete of the SOA Instance'
      option :inst,
        :short        => '-I INST',
        :long         => '--instance INST',
        :description  => 'force delete of the SOA Instance'
      option :paas_rest_endpoint,
        :long         => '--paas_rest_endpoint PAASREST',
        :description  => 'REST end point for PaaS services not in the US'

      def run
        validate!
        # checking my knife.rb for values
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        config[:purge] = locate_config_value(:purge)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        confirm('Do you really want to delete this server')
        attrcheck = { 'chef node name'  => config[:chef_node_name],
                      'db password'     => config[:dbapass]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        data_hash = { 'dbaName' => config[:dbaname], 'dbaPassword' => config[:dbapass], 'forceDelete' => config[:forcedelete] }
        data_hash.to_json
        puts data_hash
        puts config[:inst]
        fmw_delete(data_hash, 'soa')
      end # end of run
    end # end of delete
  end # end of knife
end # end of chef
