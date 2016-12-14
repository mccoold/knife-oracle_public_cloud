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
    module ChefBase
      # used to pull values from the knife.rb
      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      
      def chef_node_configuration(instance) # rubocop:disable Metrics/AbcSize
        Chef::Config[:knife][:environment] = instance['environment'] unless instance['environment'].nil?
        config[:environment] = instance['environment'] unless instance['environment'].nil?
        Chef::Config[:knife][:chef_node_name] = instance['label'] unless instance['label'].nil?
        config[:chef_node_name] = instance['label'] unless instance['label'].nil?
        config[:run_list] = instance['run_list'] unless  instance['run_list'].nil?
        config[:tags] = instance['tags'] unless instance['tags'].nil?
        config[:ssh_user] = instance['ssh_user'] unless instance['ssh_user'].nil?
      end
        
      def validate!(keys = [:opc_id_domain, :opc_username])
        errors = []
        keys.each do |k|
          if locate_config_value(k).nil?
            errors << "You did not provide a valid '#{k}' value. " \
                      "Please set knife[:#{k}] in your knife.rb or pass as an option."
          end
        end
        exit 1 if errors.each { |e| ui.error(e) }.any?
      end

      # bootstrap method to boot linux nodes leverages the config object for values
      def bootstrap_for_linux_node(ssh_host) # rubocop:disable Metrics/AbcSize
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = ssh_host
        puts ssh_host
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_password] = locate_config_value(:ssh_password)
        bootstrap.config[:ssh_port] = config[:ssh_port]
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:identity_file] = locate_config_value(:opc_ssh_identity_file)
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap_common_params(bootstrap)
      end

      def bootstrap_common_params(bootstrap) # rubocop:disable Metrics/AbcSize
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
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
        bootstrap.config[:tags] = config[:tags]
        # Modify global configuration state to ensure hint gets set by
        # knife-bootstrap
        sleep 15
        Chef::Config[:knife][:hints] ||= {}
        Chef::Config[:knife][:hints]['opc'] ||= {}
        bootstrap
      end

      # removes nodes from the Chef Server for paas calls
      def destroy_item(klass, name, type_name)
        begin
          object = klass.load(name)
          object.destroy
          ui.warn("Deleted #{type_name} #{name} from Chef Server")
        rescue Net::HTTPServerException
          ui.warn("Could not find a #{type_name} named #{name} to delete!")
        end
      end

      # deletes nodes from Chef Server, newer method
      def chef_delete # rubocop:disable Metrics/AbcSize
        if config[:purge]
          if config[:chef_node_name]
            thing_to_delete = config[:chef_node_name]
          else
            thing_to_delete = config[:inst]
          end
          destroy_item(Chef::Node, thing_to_delete, 'node')
          destroy_item(Chef::ApiClient, thing_to_delete, 'client')
        else
          ui.warn("Corresponding node and client for the #{config[:inst]} server were not deleted
          and remain registered with the Chef Server")
        end
        rescue NoMethodError
          ui.error("Could not locate server #{config[:inst]}.  Please verify it was provisioned ")
      end

      # updates ohai attributes with oracle cloud specific values
      def node_attributes(ssh_host, service)
        node = Chef::Node.load(config[:chef_node_name])
        node.chef_environment = Chef::Config[:knife][:environment]
        node.normal_attrs = { 'Cloud' => { 'provider' => 'Oracle Public Cloud', 'Service' => service,
                                           'public_ips' => ssh_host, 'ID_DOMAIN' => config[:id_domain] } }
        node.save
        config[:tags].each do |tag|
          node.tags << tag
        end
        node.save unless config[:action] == 'stop'
      end
    end

    # base module for methods specific to Next Gen / BMC
    module NgenBase
      # authentication for next gen cloud
      def ngen_auth
        config[:compartment] = locate_config_value(:compartment)
        config[:user] = locate_config_value(:bmc_user)
        config[:fingerprint] = locate_config_value(:fingerprint)
        config[:tenancy] = locate_config_value(:tenancy)
        config[:key_file] = locate_config_value(:key_file)
        config[:region] = locate_config_value(:bmc_region)
        config[:verify_certs] = locate_config_value(:verify_certs)
      end
      
      # nice screen display while you wait :)
      def ho_hum
        i = 0
        num = 15
        while i < num  do
          print ui.color('.', :green)
         sleep 15
         i +=1
        end
      end
    end
    
    # module for Nimbula methods
    module OpcBase

      # defines PaaS URL's based on service
      def paas_url(restendpoint, service) # rubocop:disable Metrics/AbcSize
        full_url = restendpoint + '/paas/service/jcs/api/v1.1/instances/' + config[:id_domain] if service == 'jcs'
        full_url = restendpoint + '/paas/service/dbcs/api/v1.1/instances/' + config[:id_domain] if service == 'dbcs'
        full_url = restendpoint + '/paas/service/soa/api/v1.1/instances/' + config[:id_domain] if service == 'soa'
        return full_url
      end
    end
  end
end
