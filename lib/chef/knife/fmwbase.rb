class Chef
  require 'opc_client'

  class Knife
    module FmwBase
      def fmw_create(config, service) # rubocop:disable Metrics/AbcSize
        attrcheck = { 
          'create_json'     => config[:create_json],
          'ssh-user'        => config[:ssh_user],
          'identity file'   => config[:identity_file],
          'run-list'        => config[:run_list]
        }
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        create_json = File.read(config[:create_json])
        create_data = JSON.parse(create_json)
        paas_create = InstCreate.new(config[:id_domain], config[:user_name], config[:passwd], service)
        createcall = paas_create.create(create_data)
        if createcall.code == '401' || createcall.code == '404' || createcall.code == '400'
          print ui.color('Error with REST call, returned http code: ' + createcall.code + ' ', :red, :bold)
          print ui.color(createcall.body, :red)
        else
          # res = JSON.parse(paas_create.create_status(createcall['location']))
          status_object = paas_create.create_status(createcall['location'])
          status_message =  status_object.body # have to break all the calls out for error
          # handling REST end point tends not to be consistant
          status_message_status = JSON.parse(status_message) if status_object.code == '202'
          print ui.color('Provisioning the Cloud Asset ' + status_message_status['service_name'], :green)
          breakout = 1
          while status_message_status['status'] == 'In Progress' || status_message_status['status'] == 'Provisioning completed'
            print ui.color('.', :green)
            sleep 90
            status_object = paas_create.create_status(createcall['location'])
            status_message =  status_object.body
            status_message_status = JSON.parse(status_message) if status_object.code == '202' || status_object.code == '200'
            if status_object.code == '500'
              breakkout++
              abort('Rest calls failing 5 times ' + status_object.code) if breakout == 5
            end # end of if
          end # end of while
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], service)
          result = result.inst_list(status_message_status['service_name'])
          result = JSON.parse(result.body)
          ssh_host = result['content_url']
          ssh_host.delete! 'http://'
          bootstrap_for_linux_node(ssh_host).run
        end # end of if
      end # end of fmw_create

      def fmw_delete(data_hash, service) # rubocop:disable Metrics/AbcSize
        deleteinst = InstDelete.new(config[:id_domain], config[:user_name], config[:passwd], service)
        deleteinst = deleteinst.delete(data_hash, config[:inst])
        deleteinst = JSON.parse(deleteinst.body)
        deleteinst = JSON.pretty_generate(deleteinst)
        print ui.color(deleteinst, :yellow)
        puts ''
        ui.warn("Deleted instance #{config[:inst]}")
        chef_delete
      end # end of delete
    end # end of FmwBase
  end # end of knife
end # end of chef
