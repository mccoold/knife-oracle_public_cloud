class Chef
  require 'opc_client'
  class Knife
    module OrchJson
      def orch_json_parse(config_data)
        json_data = JSON.parse(config_data)
        plan = json_data['oplans']
        plan.each do |op|
         if op['obj_type'] == "launchplan"
           obj =op['objects']
           obj = obj.at(0)
           inst = obj['instances'].at(0)
           label = op['label']
           name =inst['name']
           return label, name
         end
       end
     end
   end
 end
 end
