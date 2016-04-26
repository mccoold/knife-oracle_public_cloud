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
  require 'chef/knife/base_options'
  class Knife
    class OpcComputeInstanceList < Chef::Knife
      include Knife::OpcOptions
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance list (options)'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }

      def run # rubocop:disable Metrics/AbcSize
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        compute = ComputeClient.new
        compute.util = Utilities.new
        compute.options = config
        instance = compute.list
      end # end of run
    end # end of list class

    class OpcComputeInstanceDelete < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc compute instance delete (options)'

      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }

      def run
        config[:id_domain] = locate_config_value(:opc_id_domain)
        config[:user_name] = locate_config_value(:opc_username)
        config[:rest_endpoint] = locate_config_value(:opc_rest_endpoint)
        compute = ComputeClient.new
        compute.options = config
        compute.util = Utilities.new
        instance = compute.delete
      end # end of run
    end # end of delete class
    
     class OpcComputeImagelistShow < Chef::Knife
      include Knife::OpcOptions
      include Knife::OpcBase
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
        compute.options = config
        instance = compute.image_list
        print ui.color(instance, :green)
      end # end of run
    end # end of list class
  end # end of knife
end # end of chef
