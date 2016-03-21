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
require 'OPC'

class Chef
  class Knife
    class OpcNetwork < Chef::Knife
      include Knife::OpcBase
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end # end of deps
      banner 'knife opc network (options)'
      option :create_json,
         :short       => '-j',
         :long        => '--create_json JSON',
         :description => 'json file to describe server'
      option :rest_endpoint,
         :short       => '-R',
         :long        => '--rest_endpoint REST_ENDPOINT',
         :description => 'Rest end point for compute',
         :proc        =>  Proc.new {|key| Chef::Config[:knife][:opc_rest_endpoint] = key}

      def run
        attrcheck = { 'create_json' => config[:create_json] }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        file = File.read(config[:create_json])
        inputdata = JSON.parse(file)
        inputdata.each do |json_top_level|
          func = json_top_level.at(0).downcase
          json_top_level.at(1).each do |category_instance|
            if func == 'secapp'
              networkconfig = SecApp.new(config[:id_domain], config[:user_name], config[:passwd])
              case category_instance.at(1)['Action'].downcase
              when 'create'
                puts 'created'
                networkconfig = networkconfig.modify(config[:rest_endpoint], 'create', category_instance.at(1)['Parameters'])
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'delete'
                networkconfig = networkconfig.modify(config[:rest_endpoint],  'delete',
                                                     category_instance.at(1)['Parameters']['name'])
                puts 'deleted secapplication ' + category_instance.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            elsif func == 'secrule'
              networkconfig = SecRule.new(config[:id_domain], config[:user_name], config[:passwd])
              case category_instance.at(1)['Action']
              when 'create'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'create', category_instance.at(1)['Parameters'])
                puts 'created'
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'modify'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'update', category_instance.at(1)['Parameters'])
                puts 'updated'
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'delete'
                networkconfig = networkconfig.update(config[:rest_endpoint], category_instance.at(1)['Parameters']['name'], 'delete',
                                                             category_instance.at(1)['Parameters'])
                puts 'deleted rule ' + category_instance.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            elsif func == 'seclist'
              networkconfig = SecList.new(config[:id_domain], config[:user_name], config[:passwd])
              case category_instance.at(1)['Action']
              when 'create'
                puts 'created'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'create', category_instance.at(1)['Parameters'])
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'modify'
                puts 'updated'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'update', category_instance.at(1)['Parameters'])
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'delete'
                networkconfig = networkconfig.update(config[:rest_endpoint], category_instance.at(1)['Parameters']['name'], 'delete',
                                                     json_top_level.at(1)['Parameters'])
                puts 'deleted Sec List ' + category_instance.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            elsif func == 'seciplist'
              networkconfig = SecIPList.new(config[:id_domain], config[:user_name], config[:passwd])
              case category_instance.at(1)['Action']
              when 'create'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'create', category_instance.at(1)['Parameters'])
                puts 'created'
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'modify'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'update', category_instance.at(1)['Parameters'])
                puts 'updated'
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'delete'
                networkconfig = networkconfig.update(config[:rest_endpoint], category_instance.at(1)['Parameters']['name'], 'delete',
                                                     category_instance.at(1)['Parameters'])
                puts 'deleted SecIP List ' + category_instance.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            elsif func == 'secassoc'
              networkconfig = SecAssoc.new(config[:id_domain], config[:user_name], config[:passwd])
              case category_instance.at(1)['Action']
              when 'create'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'create', category_instance.at(1)['Parameters'])
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'modify'
                puts 'nothing done yet'
              when 'delete'
                networkconfig = networkconfig.update(config[:rest_endpoint], category_instance.at(1)['Parameters']['name'], 'delete',
                                                     category_instance.at(1)['Parameters'])
                puts 'deleted Secassoc ' + json_top_level.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            elsif func == 'ip'
              networkconfig = IPUtil.new(config[:id_domain], config[:user_name], config[:passwd])
              callclass = category_instance.at(1)['Class']
              case category_instance.at(1)['Action']
              when 'create'
                networkconfig = networkconfig.update(config[:rest_endpoint], nil, 'create', callclass, category_instance.at(1)['Parameters'])
                puts JSON.pretty_generate(JSON.parse(networkconfig.body))
              when 'modify'
                puts 'nothing done yet'
              when 'delete'
                networkconfig = networkconfig.update(config[:rest_endpoint], category_instance.at(1)['Parameters']['name'], 'delete',
                                                     callclass, category_instance.at(1)['Parameters'])
                puts 'deleted IP ' + callclass + ' ' + category_instance.at(1)['Parameters']['name'] if networkconfig.code == '204'
              end
            end # end of if
          end # end of case
        end # end of loop for inputdata
      end # end of run method
    end # end of OPCNetwork
  end # end of knife
end # end of chef
