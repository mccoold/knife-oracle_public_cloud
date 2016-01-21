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
    module OpcBase
      def self.included(includer)
        includer.class_eval do
          option :user_name,
             :short       => '-u',
             :long        => '--user_name NAME',
             :description => 'username for OPC account'
          option :id_domain,
             :short       => '-i',
             :long        => '--id_domain ID_DOMAIN',
             :description => 'OPC id domain'
          option :passwd,
             :short       => '-p',
             :long        => '--passwd PASS',
             :description => 'password for OPC account'
          option :run_list,
            :short => '-r RUN_LIST',
            :long => '--run-list RUN_LIST',
            :description => 'Comma separated list of roles/recipes to apply',
            :proc => lambda { |o| o.split(/[\s,]+/) }
          option :bootstrap_version,
            :long => "--bootstrap-version VERSION",
            :description => "The version of Chef to install",
            :proc => lambda { |v| Chef::Config[:knife][:bootstrap_version] = v }
        end # end of includer
      end # end of included

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      def bootstrap_for_linux_node(ssh_host)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = ssh_host
        puts ssh_host
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
        bootstrap.config[:ssh_port] = config[:ssh_port]
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        puts 'in boot for linux'
        bootstrap_common_params(bootstrap)
      end # end bootstrap

      def bootstrap_common_params(bootstrap)
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        # setting bootstrap_template value to template_file for backward compatibility
        bootstrap.config[:template_file] = locate_config_value(:template_file) || locate_config_value(:bootstrap_template)
        bootstrap.config[:environment] = locate_config_value(:environment)
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:first_boot_attributes] = locate_config_value(:json_attributes) || {}
        bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:encrypted_data_bag_secret)
        bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
        bootstrap.config[:secret] =  locate_config_value(:secret)
        bootstrap.config[:secret_file] = locate_config_value(:secret_file)
        bootstrap.config[:node_ssl_verify_mode] = locate_config_value(:node_ssl_verify_mode)
        bootstrap.config[:node_verify_api_cert] = locate_config_value(:node_verify_api_cert)
        bootstrap.config[:bootstrap_no_proxy] = locate_config_value(:bootstrap_no_proxy)
        bootstrap.config[:bootstrap_url] = locate_config_value(:bootstrap_url)
        bootstrap.config[:bootstrap_install_command] = locate_config_value(:bootstrap_install_command)
        bootstrap.config[:bootstrap_wget_options] = locate_config_value(:bootstrap_wget_options)
        bootstrap.config[:bootstrap_curl_options] = locate_config_value(:bootstrap_curl_options)
        bootstrap.config[:bootstrap_vault_file] = locate_config_value(:bootstrap_vault_file)
        bootstrap.config[:bootstrap_vault_json] = locate_config_value(:bootstrap_vault_json)
        bootstrap.config[:bootstrap_vault_item] = locate_config_value(:bootstrap_vault_item)
        bootstrap.config[:use_sudo_password] = locate_config_value(:use_sudo_password)
        # Modify global configuration state to ensure hint gets set by
        # knife-bootstrap
        puts 'in bootstrap common'
        puts bootstrap.config
        puts bootstrap.name_args
        bootstrap
      end # end of bootstap common
    end # end of OpcBase
  end # end of knife
end # end of class chef
