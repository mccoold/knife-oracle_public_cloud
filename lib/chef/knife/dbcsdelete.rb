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
# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'
# Needed to delete the instance from OPC
require 'OPC'
require 'chef/knife/opc_base'
class Chef
  class Knife
    class OpcDbcsDelete < Knife
      include Knife::OpcBase
      banner 'knife OPC dbcs delete (options)'

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

      def run
        confirm('Do you really want to delete this DB server')
        deleteinst = DbDelete.new
        deleteinst = deleteinst.delete("#{config[:id_domain]}", "#{config[:user_name]}",
                                       "#{config[:passwd]}", "#{config[:inst]}")
        deleteinst = JSON.parse(deleteinst)
        deleteinst = JSON.pretty_generate(deleteinst)
        print ui.color(deleteinst, :yellow)
        puts ''
        ui.warn("Deleted server #{config[:inst]}")
        if config[:purge]
          if config[:chef_node_name]
            thing_to_delete = config[:chef_node_name]
          else
            thing_to_delete = config[:inst]
            puts 'in else'
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
