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
             allinstances = obj['instances']
             allinstances.each do |inst|
               label = inst['label']
               name = inst['name']
               chefrunlist = inst.dig('attributes', 'userdata', 'chef', 'run_list')
               chefenvironment = inst.dig('attributes', 'userdata', 'chef', 'environment')
               tags = inst.dig('attributes', 'userdata', 'chef', 'tags')
               launchplan = { 'label' => label, 'name' => name }
               launchplan['runlist'] = chefrunlist unless chefrunlist.nil?
               launchplan['chefenvironment'] = chefenvironment unless chefenvironment.nil?
               launchplan['tags'] = chefrunlist unless tags.nil?
               instances.insert(-1, launchplan)
             end # end of inside loop
           end # end of if
         end # end of outside loop
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
