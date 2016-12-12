class Chef
  class Knife
    require 'chef/knife/opc_base'
    require 'OPC'
    require 'chef/knife/base_options'
    include Knife::OpcBase
    include Knife::NgenBase
    
    class OpcNgenInstanceList < Chef::Knife
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc ngen instance list (options)'
      option :yaml,
        :short       => '-Y',
        :long        => '--yaml YAML',
        :description => 'YAML file for the instance',
        :proc        =>  Proc.new { |key| Chef::Config[:knife][:opc_rest_endpoint] = key }

      def run
        ngen_auth
        @validate = Validator.new
        instlist = InstanceClient.new
        instlist.validate = @validate
        config[:action] = 'list'
        instlist.options = config
        instlist.opt_parse    
      end
    end
    
    class OpcNgenInstanceCreate < Chef::Knife
      include Knife::OpcOptions
      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      banner 'knife opc ngen instance create (options)'
      option :yaml,
        :short       => '-Y',
        :long        => '--yaml YAML',
        :description => 'YAML file for the instance'

      def run
        ngen_auth
        @validate = Validator.new
#        attrcheck = { 'Node Name'   => config[:chef_node_name] }
#        @validate.validate(config, attrcheck)
        inst = InstanceClient.new
        @instanceparameters = inst.yaml_reader(config[:yaml])
        inst.validate = @validate
        config[:action] = 'create'
        inst.options = config
        inst.supress_output ='1'
        inst.instanceparameters = @instanceparameters
        inst_result = inst.opt_parse
        @instanceparameters = @instanceparameters['compute'].at(0)
        i = 0
        num = 15
        while i < num  do
          print ui.color('.', :green)
         sleep 15
         i +=1
        end
        inst_result.each do |server|
          config[:inst] = server['server']['display_name']
          config[:chef_node_name] = config[:inst]
          inst_details = AttrFinder.new(server)
          inst_details.options = config
          inst_details.validate = @validate
          inst_details.function = 'server' 
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
          #'VCN'         => config[:vcn]
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