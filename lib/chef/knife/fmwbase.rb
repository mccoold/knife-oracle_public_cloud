class Chef
  class Knife
    module FmwBase
      def fmw_create(config, service)
        attrcheck = nil
        @validate = Validator.new
        @validate.attrvalidate(config, attrcheck)
        file = File.read("#{config[:create_json]}")
        create_data = JSON.parse(file)
        jcscreate = InstCreate.new(config[:id_domain], config[:user_name], config[:passwd], service)
        createcall = jcscreate.create(create_data)
        if createcall.code == '401' || createcall.code == '404'
          print ui.color('Error', :red, :bold)
          print ui.color(createcall.body, :red)
        else
          res = JSON.parse(jcscreate.create_status(createcall['location']))
          print ui.color('Provisioning the JCS Cloud Asset ' + res['service_name'], :green)
          while res['status'] == 'In Progress'
            print ui.color('.', :green)
            sleep 90
            res = JSON.parse(jcscreate.create_status(createcall['location']))
          end # end of while
          result = SrvList.new(config[:id_domain], config[:user_name], config[:passwd])
          result = result.inst_list(service, res['service_name'])
          result = JSON.parse(result.body)
          ssh_host = result['content_url']
          ssh_host.delete! 'http://'
          bootstrap_for_linux_node(ssh_host).run
        end # end of if
      end # end of fmw_create
    end # end of FmwBase
  end # end of knife
end # end of chef