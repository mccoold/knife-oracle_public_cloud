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
    class OpcObjectstorageList < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'OPC'
      end # end of deps
      banner 'knife opc objectstorage list (options)'
      option :container,
         :long        => '--container CONTAINER',
         :description => 'storage container name'

      def run
        attrcheck = { 'Container' => config[:container] }
        valid = attrvalidate(config, attrcheck)
        abort(valid.at(1)) if valid.at(0) == 'true'
        newcontainer = ObjectStorage.new(config[:id_domain], config[:user_name], config[:passwd])
        newcontainer = newcontainer.list
        if newcontainer.code == '200'
          print ui.color(newcontainer.body, :green)
          puts ''
        else
          puts newcontainer.code
          puts 'in else'
        end # end of if
      end # end of run
    end # end of create
  end # end of knife
end # end of chef
