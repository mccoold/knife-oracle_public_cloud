class Chef
  require 'opc_client'
  
  class Knife
    module FmwBase
      def fmw_create(config, service)
        attrcheck = {'create_json'     => config[:create_json],
                     'ssh-user'        => config[:ssh_user],
                     'identity file'   => config[:identity_file],
                     'run-list'        => config[:run_list]}
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
          res = JSON.parse(paas_create.create_status(createcall['location']))
          print ui.color('Provisioning the Cloud Asset ' + res['service_name'], :green)
          while res['status'] == 'In Progress' || res['status'] == 'Provisioning completed'
            print ui.color('.', :green)
            sleep 90
            res = JSON.parse(paas_create.create_status(createcall['location']))
          end # end of while
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd], service)
          result = result.inst_list(res['service_name'])
          result = JSON.parse(result.body)
          ssh_host = result['content_url']
          ssh_host.delete! 'http://'
          bootstrap_for_linux_node(ssh_host).run
        end # end of if
      end # end of fmw_create
    end # end of FmwBase
  end # end of knife
end # end of chef