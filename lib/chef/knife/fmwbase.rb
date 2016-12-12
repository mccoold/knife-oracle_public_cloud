class Chef
  require 'opc_client'
  class Knife
    module FmwBase
      # method used to create jcs and soa instances
      def fmw_create(config, service) # rubocop:disable Metrics/AbcSize
        # checks for errors in the responses
        responsecheck = Utilities.new
        attrcheck = {
          'create_json'     => config[:create_json],
          'ssh-user'        => config[:ssh_user],
          'identity file'   => config[:identity_file],
          'chef node name'  => config[:chef_node_name]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        create_json = File.read(config[:create_json])
        create_data = JSON.parse(create_json)
        paas_create = InstCreate.new(config[:id_domain], config[:user_name], config[:passwd], service)
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], service) if config[:paas_rest_endpoint]
        paas_create.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        createcall = paas_create.create(create_data)
        responsecheck.response_handler(createcall)
        status_object = paas_create.create_status(createcall['location'])
        status_message =  status_object.body 
        # have to break all the calls out for error handling REST end point,
        # it tends not to be consistant
        status_message_status = JSON.parse(status_message) if status_object.code == '202'
        print ui.color('Provisioning the Cloud Asset ' + status_message_status['service_name'], :green)
        breakout = 1
        while status_message_status['status'] == 'In Progress' || status_message_status['status'] == 'Provisioning completed'
          print ui.color('.', :green)
          abort('Error in provisioning process' + status_message_status) if status_message_status['status'] == 'failed'
          sleep 90
          status_object = paas_create.create_status(createcall['location'])
          status_message =  status_object.body
          status_message_status = JSON.parse(status_message) if status_object.code == '202' || status_object.code == '200'
          if status_object.code == '500'
            breakkout +=
            abort('Rest calls failing 5 times ' + status_object.code) if breakout == 5
          end
        end
        config[:function] = service
        result = SrvList.new(config)
        result.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        result = result.inst_list(status_message_status['service_name'])
        result = JSON.parse(result.body)
        ssh_host = result['content_url']
        ssh_host.delete! 'http://'
        bootstrap_for_linux_node(ssh_host).run
        node_attributes(ssh_host, service)
      end

      # method to delete jcs and soa instances
      def fmw_delete(data_hash, service) # rubocop:disable Metrics/AbcSize
        responsecheck = Utilities.new
        deleteinst = InstDelete.new(config[:id_domain], config[:user_name], config[:passwd], service)
        config[:paas_rest_endpoint] = paas_url(config[:paas_rest_endpoint], service) if config[:paas_rest_endpoint]
        deleteinst.url = config[:paas_rest_endpoint] if config[:paas_rest_endpoint]
        deleteinst = deleteinst.delete(data_hash, config[:inst])
        responsecheck.response_handler(deleteinst)
        deleteinst = JSON.parse(deleteinst.body)
        deleteinst = JSON.pretty_generate(deleteinst)
        print ui.color(deleteinst, :yellow)
        puts ''
        ui.warn("Deleted instance #{config[:inst]}")
        chef_delete if config[:purge]
      end
    end
  end
end
