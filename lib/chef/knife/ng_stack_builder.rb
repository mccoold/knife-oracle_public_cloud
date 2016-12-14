class Chef
  class Knife
    require 'chef/knife/opc_base'
    require 'OPC'
    require 'chef/knife/base_options'

    include Knife::ChefBase
    include Knife::NgenBase
    include Knife::OpcOptions

    # class creates next gen stacks
    class OpcNgenStackCreate < Chef::Knife
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc ngen stack create (options)'
      option :yaml,
        :short       => '-Y',
        :long        => '--yaml YAML',
        :description => 'YAML file for the instance'
      
      option :ip_access,
        :long        => '--ip_access IP_ACCESS',
        :description => 'is the Chef server talkig to public or private IP',
        :default     => 'public'

      # run method for this class
      def run
        ngen_auth
        @validate = Validator.new
        stack = EcoSystem.new
        @instanceparameters = stack.yaml_reader(config[:yaml])
        stack.validate = @validate
        config[:action] = 'create'
        stack.options = config
        stack.supress_output ='1'
        stack.instanceparameters = @instanceparameters
        inst_result = stack.opt_parse
       ho_hum
        
        inst_result.each do |server|
          config[:inst] = server['server']['display_name']
          instance = {}
          #  puts chef_attrs = server['server']['userdata'].at(0)['chef']
          chef_attrs = server['server']['userdata'].at(0)['chef'] if !server['server']['userdata'].at(0)['chef'].nil?
            chef_attrs.each do |attr, value|
              instance[attr] = value
            end
          chef_node_configuration(instance)
          config[:chef_node_name] = config[:inst]
          inst_details = AttrFinder.new(server)
          inst_details.options = config
          inst_details.validate = @validate
          inst_details.function = 'server' 
          inst = InstanceClient.new
          inst.validate = @validate
          inst.options = config
          inst.supress_output ='1'
          inst.instanceparameters = @instanceparameters
          ssh_host = inst.list_instance_ip(inst_details.compartment, inst_details.instance).at(1)
          bootstrap_for_linux_node(ssh_host).run
          node_attributes(ssh_host, 'IaaS')
        end
      end
    end
    
    class OpcNgenInstanceDelete < Chef::Knife
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc ngen instance create (options)'
      option :vcn,
        :long        => '--vcn VCN',
        :description => 'VCN for the instance'
      option :purge,
        :long        => '--purge',
        :boolean     => true,
        :default     => false,
        :description => 'Destroy corresponding node and client on the Chef Server.
        Assumes node and client have the same name as the server (if not, add the --node-name option).'

      option :chef_node_name,
        :short       => '-N NAME',
        :long        => '--node-name NAME',
        :description => 'The name of the node and client to delete, if it differs from the server name.
                         Only has meaning when used with the --purge option.'
      option :inst,
        :short        => '-I INST',
        :long         => '--instance INST',
        :description  => 'The instance name you want to delete'

      def run
        ngen_auth
        @validate = Validator.new
        attrcheck = { 
          'Node Name'   => config[:inst]
        }
        @validate.validate(config, attrcheck)
        inst = InstanceClient.new
        inst.validate = @validate
        config[:action] = 'delete'
        config[:chef_node_name] = config[:inst] unless config[:chef_node_name]
        inst.options = config
        inst_result = inst.opt_parse
        chef_delete
      end
    end
  end
end