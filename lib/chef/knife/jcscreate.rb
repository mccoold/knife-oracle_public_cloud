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
require 'chef/knife/opc_base'
class Chef
  class Knife
    class OpcJcsCreate < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'OPC'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps

      banner 'knife OPC jcs create (options)'

      option :create_json,
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe server'
      option :identity_file,
         :long        => '--identity-file IDENTITY_FILE',
         :description => 'The SSH identity file used for authentication'
      option :ssh_user,
         :short       => '-x USERNAME',
         :long        => '--ssh-user USERNAME',
         :description => 'The ssh username',
         :default     => 'opc'
      option :chef_node_name,
         :short       => '-N NAME',
         :long        => '--node-name NAME',
         :description => 'The Chef node name for your new node',
         :proc        => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }

      def run
        attrcheck = nil
        valid = attrvalidate(config, attrcheck)
        if valid.at(0) == 'true'
          puts valid.at(1)
        else
          file = File.read("#{config[:create_json]}")
          data_hash = JSON.parse(file)
          jcscreate = InstCreate.new
          createcall = jcscreate.create(data_hash, "#{config[:id_domain]}", "#{config[:user_name]}", "#{config[:passwd]}")
          if createcall.code == '401' || createcall.code == '404'
            print ui.color('Error', :red, :bold)
            print ui.color(createcall.body, :red)
          else
            res = JSON.parse(jcscreate.create_status(createcall['location'], "#{config[:id_domain]}", "#{config[:user_name]}",
                                                     "#{config[:passwd]}"))
            print ui.color('Provisioning the JaaS Cloud Asset ' + res['service_name'], :green)
            while res['status'] == 'In Progress'
              print ui.color('.', :green)
              sleep 90
              res = JSON.parse(jcscreate.create_status(createcall['location'], "#{config[:id_domain]}",
                                                       "#{config[:user_name]}", "#{config[:passwd]}"))
            end # end of while
            result = SrvList.new
            result = result.inst_list("#{config[:id_domain]}", "#{config[:user_name]}", "#{config[:passwd]}", "#{res['service_name']}")
            result = JSON.parse(result.body)
            ssh_host = result['content_url']
            ssh_host.delete! 'http://'
            bootstrap_for_linux_node("#{ssh_host}").run
          end # end of if
        end # end of validator
      end # end of run
    end # end of create
  end # end of knife
end # end of chef
