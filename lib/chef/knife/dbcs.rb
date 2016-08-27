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
    require 'chef/knife/base_options'
    require 'OPC'
    require 'opc_client'
    class OpcDbcsCreate < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc dbcs create (options)'
      option :create_json,
        :long        => '--create_json JSON',
        :description => 'json file to describe OPC DBCS Instance'
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

      def run # rubocop:disable Metrics/AbcSize
        validate!
        # getting values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        attrcheck = {
          'create_json'     => config[:create_json],
          'ssh-user'        => config[:ssh_user],
          'identity-file'   => config[:identity_file],
          'chef node name'  => config[:chef_node_name]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        file = File.read(config[:create_json])
        data_hash = JSON.parse(file)
        dbcscreate = InstCreate.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
        # updates URL if is passed in by the flag or knife.rb
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], 'dbcs') if config[:paas_rest_endpoint]
        dbcscreate.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        createcall = dbcscreate.create(data_hash)
        if createcall.code == '401' || createcall.code == '404' || createcall.code == '400' || createcall.code == '403' || createcall.code == '500'
          print ui.color('Error with REST call, returned http code: ' + createcall.code + ' ', :red, :bold)
          print ui.color(createcall.body, :red)
        else
          status_object = dbcscreate.create_status(createcall['location']) unless dbcscreate.create_status(createcall['location']).code == '500'
          status_message =  status_object.body
          status_message_status = JSON.parse(status_message) if status_object.code == '202'
          print ui.color('Provisioning the DB Cloud Asset ' + status_message_status['service_name'], :green)
          # tracking the build
          while status_message_status['status'] == 'In Progress' || status_message_status['status'] == 'Provisioning completed'
            print ui.color('.', :green)
            sleep 90
            status_object = dbcscreate.create_status(createcall['location'])
            status_message =  status_object.body
            status_message_status = JSON.parse(status_message) if status_object.code == '202' || status_object.code == '200'
            if status_object.code == '500'
              breakkout +=
              abort('Rest calls failing 5 times ' + status_object.code) if breakout == 5
            end # end of if
          end # end of while
          # do a propersearch on the object now that its complete
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
          result.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
          result = result.inst_list(status_message_status['service_name'])
          result = JSON.parse(result.body)
          puts result
          # parse through some stuff to get the IP works with external only
          ssh_host = result['em_url']
          ssh_host.delete! 'https://'
          ssh_host.chomp!('em')
          ssh_host.chomp!('5500')
          bootstrap_for_linux_node(ssh_host).run
          node_attributes(ssh_host, 'PaaS DBCS')
          print ui.color('The IP is ' + ssh_host, :green)
          puts ''
        end # end of if
      end # end of run
    end # end of create

    class OpcDbcsList < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
      end # end of deps
      banner 'knife opc dbcs list (options)'
      option :paas_rest_endpoint,
        :long         => '--paas_rest_endpoint PAASREST',
        :description  => 'REST end point for PaaS services not in the US'
      option :inst,
        :short        => '-I INST',
        :long         => '--instance INST',
        :description  => 'The instance name you want to delete'

      def run # rubocop:disable Metrics/AbcSize
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        attrcheck = nil
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], 'dbcs') if config[:paas_rest_endpoint]
        result.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        result = result.service_list unless config[:inst]
        result = result.inst_list(config[:inst]) if config[:inst]
        if result.code == '401' || result.code == '400' || result.code == '404'
          print ui.color('error, JSON was not returned  the http response code was')
          puts result.code
        else
          print ui.color(JSON.pretty_generate(JSON.parse(result.body)), :green)
          puts ''
        end # end of if
      end # end of run
    end # end of list

    class OpcDbcsDelete < Knife
      # These two are needed for the '--purge' deletion case
      require 'chef/node'
      require 'chef/api_client'
      include Knife::OpcBase
      include Knife::OpcOptions
      banner 'knife opc dbcs delete (options)'

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
      option :inst,
        :short        => '-I INST',
        :long         => '--instance INST',
        :description  => 'The instance name you want to delete'
      option :paas_rest_endpoint,
        :long         => '--paas_rest_endpoint PAASREST',
        :description  => 'REST end point for PaaS services not in the US'

      def run # rubocop:disable Metrics/AbcSize
        validate!
        @util = Utilities.new
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        config[:purge] = locate_config_value(:purge)
        config[:paas_rest_endpoint] = locate_config_value(:paas_rest_endpoint)
        confirm('Do you really want to delete this DB server')
        attrcheck = { 'instance'  => config[:inst],
                      'chef node name'  => config[:chef_node_name]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        deleteinst = InstDelete.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], 'dbcs') if config[:paas_rest_endpoint]
        deleteinst.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        deleteinst = deleteinst.delete(nil, config[:inst])
        @util.response_handler(deleteinst)
        deleteinst = JSON.parse(deleteinst.body)
        JSON.pretty_generate(deleteinst)
        chef_delete
      end # end of method run

      def query
        @query ||= Chef::Search::Query.new
      end # end of query
    end # end of delete
  end # end of knife
end # end of chef
