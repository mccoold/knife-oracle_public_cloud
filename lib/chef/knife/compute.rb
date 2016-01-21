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
  require 'chef/knife/opc_base'
  require 'OPC'
  class Knife
    class OpcComputeInstanceCreate < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance create (options)'
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
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute'

      def run
        compute = ComputeClient.new
        compute.options = config
        instance = compute.create
        while instance['status'] == 'In Progress'
            print ui.color('.', :green)
            sleep 90
            instance = JSON.parse(dbcscreate.create_status(createcall['location']))
          end # end of while
          ####### double check ######
          instance = JSON.parse(dbcscreate.create_status(createcall['location']))
          while instance['status'] == 'In Progress'
            print ui.color('REST API gave a faulty return ', :cyan)
            print ui.color('.', :cyan)
            sleep 120
            instance = JSON.parse(dbcscreate.create_status(createcall['location']))
          end # end of while again
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], service)
          result = result.inst_list(instance['service_name'])
          result = JSON.parse(result.body)
          ssh_host = result['content_url']
          ssh_host.delete! 'http://'
          bootstrap_for_linux_node(ssh_host).run
      end # end of run
    end # end of OpcComputeInstanceCreate
    
    class OpcComputeInstanceList < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance list (options)'
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
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute'

      def run
        compute = ComputeClient.new
        compute.options = config
        instance = compute.list
      end # end of run
    end # end of list class
    
    class OpcComputeInstanceDelete < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance delete (options)'
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
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute'

      def run
        compute = ComputeClient.new
        compute.options = config
        instance = compute.delete
      end # end of run
    end # end of delete class
  end # end of knife
end # end of chef
