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
    class OpcBmcInstanceCreate < Chef::Knife
      include Knife::OpcOptions
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc bmc instance create (options)'
      option :yaml,
        :short       => '-Y',
        :long        => '--yaml YAML',
        :description => 'YAML file for the instance',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
  
      def run # rubocop:disable Metrics/AbcSize
        # check and load values from knife.rb
        config[:tenancy] = locate_config_value(:tenancy)
        config[:fingerprint] = locate_config_value(:fingerprint)
        config[:key_file] = locate_config_value(:key_file)
        config[:bmc_user] = locate_config_value(:bmc_user)
        config[:bmc_region] = locate_config_value(:bmc_region)
        config[:compartment] = locate_config_value(:compartment)
        compute = InstanceClient.new
        #loading and setting objects needed for the compute client object
        compute.validate =  Validator.new
        compute.options = config
        inputparse =  BmcInputParser.new(args)
        if config[:yaml]
          instanceparameters = inputparse.yaml_reader(config[:yaml])
          compute.instanceparameters = instanceparameters
        end
        new_instance = compute.create
        ssh_host = new_instance.at(1)
        bootstrap_for_linux_node(ssh_host).run
        print ui.color(compute.list, :green)
      end 
    end 
  end
end