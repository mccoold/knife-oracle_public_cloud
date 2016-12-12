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
class Chef
  class Knife
    module OpcOptions
      def self.included(includer) # rubocop:disable Metrics/AbcSize
        includer.class_eval do
          option :run_list,
            :short => '-r RUN_LIST',
            :long => '--run-list RUN_LIST',
            :description => 'Comma separated list of roles/recipes to apply',
            :proc => lambda { |o| o.split(/[\s,]+/) },
            :default => []
          option :bootstrap_version,
            :long => '--bootstrap-version VERSION',
            :description => 'The version of Chef to install',
            :proc => lambda { |v| Chef::Config[:knife][:bootstrap_version] = v }
          option :identity_file,
            :long        => '--identity-file IDENTITY_FILE',
            :description => 'The SSH identity file used for authentication',
            :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_ssh_identity_file] = key }
          option :ssh_user,
           :short       => '-x USERNAME',
           :long        => '--ssh-user USERNAME',
           :description => 'The ssh username',
           :default     => 'opc'
          option :tags,
            :short => '-T T=V[,T=V,...]',
            :long => '--tags Tag=Value[,Tag=Value...]',
            :description => 'A list of tags associated with the virtual machine',
            :proc => Proc.new { |tags| tags.split(',') },
            :default => []
          option :secret,
            :long => '--secret',
            :description => 'The secret key to use to encrypt data bag item values',
            :proc => lambda { |s| Chef::Config[:knife][:secret] = s }
          option :secret_file,
            :long => '--secret-file SECRET_FILE',
            :description => 'A file containing the secret key to use to encrypt data bag item values',
            :proc => lambda { |sf| Chef::Config[:knife][:secret_file] = sf }
          option :first_boot_attributes,
            :long => "--json-attributes",
            :description => "A JSON string to be added to the first run of chef-client",
            :proc => lambda { |o| Chef::JSONCompat.parse(o) },
            :default => {}
          option :bootstrap_url,
            :long        => "--bootstrap-url URL",
            :description => "URL to a custom installation script",
            :proc        => Proc.new { |u| Chef::Config[:knife][:bootstrap_url] = u }
          option :bootstrap_install_command,
            :long        => "--bootstrap-install-command COMMANDS",
            :description => "Custom command to install chef-client",
            :proc        => Proc.new { |ic| Chef::Config[:knife][:bootstrap_install_command] = ic }
    
          option :bootstrap_wget_options,
            :long        => "--bootstrap-wget-options OPTIONS",
            :description => "Add options to wget when installing chef-client",
            :proc        => Proc.new { |wo| Chef::Config[:knife][:bootstrap_wget_options] = wo }
          option :chef_node_name,
            :short       => '-N NAME',
            :long        => '--node-name NAME',
            :description => 'The Chef node name for your new node',
            :proc        => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }
          option :bootstrap_curl_options,
            :long        => "--bootstrap-curl-options OPTIONS",
            :description => "Add options to curl when install chef-client",
            :proc        => Proc.new { |co| Chef::Config[:knife][:bootstrap_curl_options] = co }
          option :node_ssl_verify_mode,
            :long        => "--node-ssl-verify-mode [peer|none]",
            :description => "Whether or not to verify the SSL cert for all HTTPS requests.",
            :proc        => Proc.new { |v|
              valid_values = %w{none peer}
              unless valid_values.include?(v)
              raise "Invalid value '#{v}' for --node-ssl-verify-mode. Valid values are: #{valid_values.join(", ")}"
            end
              v
            }
          option :node_verify_api_cert,
            :long        => "--[no-]node-verify-api-cert",
            :description => "Verify the SSL cert for HTTPS requests to the Chef server API.",
            :boolean => false
        end 
      end 
    end
    
    module NimbulaOptions
      require 'chef/knife'
      def self.included(includer) # rubocop:disable Metrics/AbcSize
        includer.class_eval do
          option :user_name,
             :short       => '-u',
             :long        => '--user_name NAME',
             :description => 'username for OPC account',
             :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_username] = key }
          option :id_domain,
             :short       => '-i',
             :long        => '--id_domain ID_DOMAIN',
             :description => 'OPC id domain',
             :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_id_domain] = key }
          option :passwd,
             :short       => '-p',
             :long        => '--passwd PASS',
             :description => 'password for OPC account'
        end
      end
    end
  end
end
