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
    require 'chef/knife/base_options'
    class OpcObjectstorageDelete < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'OPC'
      end # end of deps
      banner 'knife opc objectstorage delete (options)'
      option :container,
         :long        => '--container CONTAINER',
         :description => 'storage container name'

      def run # rubocop:disable Metrics/AbcSize
        attrcheck = { 'Container' => config[:container] }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        newcontainer = ObjectStorage.new(config[:id_domain], config[:user_name], config[:passwd])
        newcontainer = newcontainer.delete(config[:container])
        if newcontainer.code == '204'
          print ui.color('Container ' + config[:container] + ' deleted', :green)
          puts ''
        else
          print ui.color('ERROR this task could not be completed, the response code was ' + newcontainer.code, :red)
          puts ''
          puts newcontainer.body
          # puts 'in else'
        end # end of if
      end # end of run
    end # end of delete
    
    class OpcObjectstorageCreate < Chef::Knife
      include Knife::OpcBase
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'OPC'
      end # end of deps
      banner 'knife opc objectstorage create (options)'
      option :container,
         :long        => '--container CONTAINER',
         :description => 'storage container name'

      def run # rubocop:disable Metrics/AbcSize
        attrcheck = { 'Container' => config[:container] }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        newcontainer = ObjectStorage.new(config[:id_domain], config[:user_name], config[:passwd])
        newcontainer = newcontainer.create(config[:container])
        if newcontainer.code == '201'
          print ui.color('Container ' + config[:container] + ' created', :green)
          puts ''
        else
          puts newcontainer.body
        end # end of if
      end # end of run
    end # end of create
    
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
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
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
    end # end of list
  end # end of knife
end # end of chef
