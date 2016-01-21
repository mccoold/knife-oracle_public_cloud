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
require 'OPC'
require 'opc_client'
class Chef
  class Knife
    class OpcOrchestration < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc orchestration (options)'
      option :create_json,
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe orchestration'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute'
      option :action,
         :short       => '-A',
         :long        => '--action ACTION',
         :description => 'action options list or details'
      option :function,
         :short       => '-f',
         :long        => '--function FUNCTION',
         :description => 'function options secapp, secrule, seciplist, seclist, etc'
      option :container,
         :long        => '--container CONTAINER',
         :description => 'container name'
      option :inst,
         :long        => '--instance INSTANCE',
         :description => 'Instance Name'
    def run
      attrcheck = {
                   'Action'          => config[:action],
                   'Rest End Point'  => config[:rest_endpoint]
                  }
      @validate = Validator.new
      @validate.attrvalidate(config, attrcheck)
      orch = OrchClient.new
      case config[:action]
      when 'list', 'details'
        print ui.color(orch.list(config), :green)
      when 'create', 'update', 'delete'
        attrcheck = { 'create_json' => config[:create_json] } unless config[:action].downcase == 'delete'
        attrcheck = { 'orch Instance -I' => config[:inst] } if config[:action].downcase == 'delete'
        @validate = Validator.new
        @validate.attrvalidate(@options, attrcheck)
        print ui.color(orch.update(config), :green)
      when 'start', 'stop'
        orch.manage(config)
      end # end of case
      end # end of run
    end # end of orch
  end # end of knife
end # end of chef