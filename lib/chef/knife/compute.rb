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
    require 'OPC'
    require 'chef/knife/base_options'
    include Knife::OpcBase
    include Knife::ChefBase
    class OpcComputeInstanceList < Chef::Knife
      include Knife::OpcOptions
      include Knife::NimbulaOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc compute instance list (options)'
      option :rest_endpoint,
        :short       => '-R',
        :long        => '--rest_endpoint REST_ENDPOINT',
        :description => 'Rest end point for compute',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :container,
       :long        => '--container CONTAINER',
       :description => 'container name for OPC IaaS Compute',
       :proc        =>  Proc.new { |key| Chef::Config[:knife][:container] = key }

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        config[:function]= 'instance'
        compute = ComputeClient.new
        #loading and setting objects needed for the computeclient object
        compute.util = Utilities.new
        compute.validate =  Validator.new
        compute.options = config
        print ui.color(compute.list, :green)
      end 
    end 

    class OpcComputeInstanceDelete < Chef::Knife
      include Knife::NimbulaOptions
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end 
      banner 'knife opc compute instance delete (options)'

      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
         
      option :container,
       :long        => '--container CONTAINER',
       :description => 'container name for OPC IaaS Compute'

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        config[:function] = 'instance'
        compute = ComputeClient.new
        compute.options = config
        compute.validate =  Validator.new
        compute.util = Utilities.new
        print ui.color(compute.delete, :red)
      end 
    end 

    class OpcComputeImagelistShow < Chef::Knife
      include Knife::OpcOptions
      include Knife::NimbulaOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute imagelist show(options)'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :container,
         :long        => '--container CONTAINER',
         :description => 'container name for OPC IaaS Compute'

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        attrcheck = {
          'Rest End Point'  => config[:rest_endpoint],
          'Container'       => config[:container]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        compute = ComputeClient.new
        compute.validate = @validate
        compute.util = Utilities.new
        config[:function] = 'instance'
        compute.options = config
        instance = compute.image_list
        print ui.color(instance, :green)
      end 
    end 

    class OpcComputeInstanceSnapshotShow < Chef::Knife
      include Knife::OpcOptions
      include Knife::NimbulaOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end 
      banner 'knife opc compute instance snapshot show (options)'
      option :rest_endpoint,
        :short       => '-R',
        :long        => '--rest_endpoint REST_ENDPOINT',
        :description => 'Rest end point for compute',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :container,
        :long        => '--container CONTAINER',
        :description => 'container name for OPC IaaS Compute'

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        compute = ComputeClient.new
        compute.util = Utilities.new
        compute.validate =  Validator.new
        config[:function] = 'inst_snapshot'
        compute.options = config
        print ui.color(compute.list, :green)
      end 
    end 
    
    class OpcComputeInstanceSnapshotCreate < Chef::Knife
      include Knife::OpcOptions
      include Knife::NimbulaOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc compute instance snapshot create (options)'
      option :rest_endpoint,
        :short       => '-R',
        :long        => '--rest_endpoint REST_ENDPOINT',
        :description => 'Rest end point for compute',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :container,
        :long        => '--container CONTAINER',
        :description => 'container name for OPC IaaS Compute'
      option :inst,
        :long        => '--imagelist IMAGELIST',
        :description => 'imagelist name for snapshot'

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        compute = ComputeClient.new
        compute.util = Utilities.new
        compute.validate =  Validator.new
        config[:function] = 'inst_snapshot'
        compute.options = config
        print ui.color(compute.create_snap, :green)
      end 
    end 
    
    class OpcComputeInstanceSnapshotDelete < Chef::Knife
      include Knife::OpcOptions
      include Knife::NimbulaOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance snapshot delete (options)'
      option :rest_endpoint,
        :short       => '-R',
        :long        => '--rest_endpoint REST_ENDPOINT',
        :description => 'Rest end point for compute',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
      option :container,
        :long        => '--container CONTAINER',
        :description => 'container name for OPC IaaS Compute'

      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        compute = ComputeClient.new
        compute.util = Utilities.new
        compute.validate =  Validator.new
        config[:function] = 'inst_snapshot'
        compute.options = config
        print ui.color(compute.delete, :red)
      end 
    end 
  end 
end 
