class Chef
  require 'opc_client'
  class Knife
    module OrchJson
      def orch_json_parse(config_data)
        instances = Array.new
        json_data = JSON.parse(config_data)
        plan = json_data['oplans']
       
        plan.each do |op|
          if op['obj_type'] == "launchplan"
             obj = op['objects']
             obj = obj.at(0)
             inst = obj['instances'].at(0)
             label = inst['label']
             name = inst['name']
             puts inst.dig('attributes', 'userdata', 'chef', 'run_list')
             chefrunlist = inst.dig('attributes', 'userdata', 'chef', 'run_list')
             puts chefrunlist
             launchplan = { 'label' => label, 'name' => name }
             launchplan['runlist'] = chefrunlist unless chefrunlist.nil?
             puts launchplan['runlist']
             instances.insert(-1, launchplan)
           end # end of if
         end # end of loop
        # config[:run_list] = chefdata   # if config[:run_list].empty? && !chefdata.nil?
         return instances
       end # end of method
     end
   end
 end
 
 class Hash
  def dig(*path)
    path.inject(self) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
end
