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
    require 'opc_client'
    require 'chef/knife/base_options'

    include Knife::OpcBase
    include Knife::ChefBase

    # lists the various components of the Nimbula network
    class OpcNetworkList < Chef::Knife
      include Knife::NimbulaOptions
      include Knife::OpcOptions
      require 'chef/knife/base_options'
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc network list (options)'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }
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

      def run # rubocop:disable Metrics/AbcSize
        attrcheck = {
          'Action'          => config[:action],
          'Rest End Point'  => config[:rest_endpoint],
          'Container'       => config[:container],
          'Function'        => config[:function]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        case config[:function]
        when 'seclist'
          seclistc = SecListClient.new
          seclistc.list(config)
        when 'secrule'
          secrulec = SecRuleClient.new
          secrulec.list(config)
        when 'secapp'
          secappc = SecAppClient.new
          secappc.list(config)
        when 'seciplist'
          seciplistc = SecIPListClient.new
          seciplistc.list(config)
        when 'secassoc'
          secassocc = SecAssocClient.new
          secassocc.list(config)
        when 'ip_reservation', 'ip_association'
          iputilc = IPUtilClient.new
          iputilc.list(config)
        end
      end
    end
  end
end
