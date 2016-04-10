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
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe server'
      option :chef_node_name,
         :short       => '-N NAME',
         :long        => '--node-name NAME',
         :description => 'The Chef node name for your new node',
         :proc        => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }

      def run # rubocop:disable Metrics/AbcSize
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
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
        createcall = dbcscreate.create(data_hash)
        if createcall.code == '401' || createcall.code == '404' || createcall.code == '400'
          print ui.color('Error with REST call, returned http code: ' + createcall.code + ' ', :red, :bold)
          print ui.color(createcall.body, :red)
        else
          res = JSON.parse(dbcscreate.create_status(createcall['location']).body) unless dbcscreate.create_status(createcall['location']).code == '500'
          print ui.color('Provisioning the DB Cloud Asset ' + res['service_name'], :green)
          while res['status'] == 'In Progress' || res['status'] == 'Provisioning completed'
            print ui.color('.', :green)
            sleep 90
            res = JSON.parse(dbcscreate.create_status(createcall['location']).body) unless dbcscreate.create_status(createcall['location']).code == '500'
          end # end of while
          ####### double check ######
          res = JSON.parse(dbcscreate.create_status(createcall['location']).body)
          while res['status'] == 'In Progress' || res['status'] == 'Provisioning completed'
            print ui.color('REST API gave a faulty return ', :cyan)
            print ui.color('.', :cyan)
            sleep 120
            res = JSON.parse(dbcscreate.create_status(createcall['location']).body)
          end # end of while again
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
          result = result.inst_list(res['service_name'])
          result = JSON.parse(result.body)
          ssh_host = result['glassfish_url']
          ssh_host.delete! 'https://'
          ssh_host.slice!('4848')
          bootstrap_for_linux_node(ssh_host).run
          node_attributes(ssh_host, 'PaaS DBCS')
          print ui.color('the IP is ' + ssh_host, :green)
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

      def run # rubocop:disable Metrics/AbcSize
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        attrcheck = nil
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
        result = result.service_list
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
        :default     => true,
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
        :description  => 'force delete of the JCS Instance'

      # Extracted from Chef::Knife.delete_object, because it has a
      # confirmation step built in... By specifying the '--purge'
      # flag (and also explicitly confirming the server destruction!)
      # the user is already making their intent known.  It is not
      # necessary to make them confirm two more times.
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name}")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      def run # rubocop:disable Metrics/AbcSize
        validate!
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        confirm('Do you really want to delete this DB server')
        attrcheck = { 'instance'  => config[:inst] }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        deleteinst = InstDelete.new(config[:id_domain], config[:user_name], config[:passwd], 'dbcs')
        deleteinst = deleteinst.delete(nil, config[:inst])
        deleteinst = JSON.parse(deleteinst.body)
        deleteinst = JSON.pretty_generate(deleteinst)
        print ui.color(deleteinst, :yellow)
        puts ''
        ui.warn("Deleted server #{config[:inst]} from OPC")
        if config[:purge]
          if config[:chef_node_name]
            thing_to_delete = config[:chef_node_name]
          else
            thing_to_delete = config[:inst]
          end # end of chef_node_name if
          destroy_item(Chef::Node, thing_to_delete, 'node')
          destroy_item(Chef::ApiClient, thing_to_delete, 'client')
        else
          ui.warn("Corresponding node and client for the #{config[:inst]} server were not deleted
          and remain registered with the Chef Server")
        end # end of purge if
        rescue NoMethodError
          ui.error("Could not locate server #{config[:inst]}.  Please verify it was provisioned ")
      end # end of method run

      def query
        @query ||= Chef::Search::Query.new
      end # end of query
    end # end of delete
  end # end of knife
end # end of chef
