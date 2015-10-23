#
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
require 'chef/knife'
require 'chef/knife/opc_base'

class Chef
  class Knife
    class OpcDbcsList < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'OPC'
      end # end of deps
      banner 'knife opc dbcs list (options)'

      def run
        attrcheck = nil
        valid = attrvalidate(config, attrcheck)
        if valid.at(0) == 'true'
          puts valid.at(1)
        else
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd])
          result = result.service_list('dbcs')
          if result.code == '401' || result.code == '400' || result.code == '404'
            print ui.color('error, JSON was not returned  the http response code was')
            puts result.code
          else
            print ui.color(JSON.pretty_generate(JSON.parse(result.body)), :green)
            puts ''
          end # end of if
        end # end of validator
      end # end of run
    end # end of OPC
  end # end of knife
end # end of chef
