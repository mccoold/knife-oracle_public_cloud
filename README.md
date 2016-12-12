# README #


### Knife Plugin for Oracle Public Cloud (OPC) ###


**Summary:**
This is an open source tool to integrate Chef (knife) with Oracle Public Cloud (OPC).  
The plugin adds knife commands and options allowing users to provision cloud assets on OPC e.g. java instances, database instances, compute instances, orchestrations, network settings, and containers
and bootstrap them into chef with a single command.  The plug-in also creates storage containers, but they are not bootstrapped for obvious reasons


### Version ###
* 0.1.6

### How do I install and configure? ###

* Setup:
  * This Gem assumes that Chef (either the development kit or a full Chef client) has been installed.  Path to the embedded\bin folder of your Chef install.
    run gem install knife-oracle_public_cloud.
  * Ensure your knife.rb file is properly configured to connect to your Chef server. 
    See below section for addition knife.rb options

     * to verify install type knife from the command line
     * you should see knife opc _list of functions_



 **Dependencies**

     Ruby (1.8+), knife(chef 11.4+), OPC(0.4.0), oracle_public_cloud_client(0.5.0)


### Usage ###

 * The gem handles both the IaaS and PaaS(JaaS, DBaaS) functinality
  *     Version 0.1.0 and above

# Available Commands:

* knife opc dbcs create: -u _username_ -i _identity_domain_ -p _password_ --create_json _JSON_file_  --identity-file _sshkeyfile_
* knife opc dbcs delete -u _username_ -i _identity_domain_ -p _password_ -I _Instance Service Name_
* knife opc dbcs list -u _username_ -i _identity_domain_ -p _password_
* knife opc jcs create -u _username_ -i _identity_domain_ -p _password_ --create_json _JSON_file_ --identity-file _sshkeyfile_ -N _chefnodename_
* knife opc jcs delete -u _username_ -i _identity_domain_ -p _password_ -I _Instance Service Name_ -N _chefnodename_
* knife opc jcs list -u _username_ -i _identity_domain_ -p _password_ 
* knife opc network -u _username_ -i _identity_domain_ -p _password_  _see JSON Page for more details_
* knife opc objectstorage create -u _username_ -i _identity_domain_ -p _password_ -C _containername_
* knife opc objectstorage delete -u _username_ -i _identity_domain_ -p _password_ -C _containername_
* knife opc objectstorage list -u _username_ -i _identity_domain_ -p _password_
   * for contents of the container: --container _containername_
* knife opc compute instance list -u _username_ -i _identity_domain_ -p _password_ -R _RESTURL_
* knife opc orchestration -A _start, stop, create, delete, list, details_  -u _username_ -i _identity_domain_ -p _password_ -R _RESTURL_
   * for start, stop, delete:  -C _containername_
   * for create: --create_json _json_ file
* knife opc soa create -u _username_ -i _identity_domain_ -p _password_ --create_json _JSON_file_ --identity-file _sshkeyfile_ -N _chefnodename_
* knife opc soa delete -u _username_ -i _identity_domain_ -p _password_ -I _Instance Service Name_ -N _chefnodename_
* knife opc soa list -u _username_ -i _identity_domain_ -p _password_ 
* knife opc ngen instance -A (create, delete) -Y YAML file

**Notes**
 * configuring Network can be done with orchestrations for accounts that have IaaS, for PaaS only accounts use the network command to define network rules.
 * If using PaaS Services outside of the United States or OCM use --paas_rest_endpoint to specify the REST endpoint for your PaaS services.  (PaaS and Compute have different REST endpoints, thus the two different flags)

# Knife.rb Settings:
 Some flags to can be skipped from the command line if pre configured in the knife.rb file
The following parameters can be set in the knife.rb file

       knife[:opc_id_domain] = '<value>'
       knife[:opc_username] = '<value>'
       knife[:opc_rest_endpoint] = '<value>'
       knife[:opc_ssh_identity_file] = "<value>"
       knife[:paas_rest_endpoint] = '<value>'
       knife[:tenancy] = '<value>'
       knife[:key_file] = '<value>'
       knife[:bmc_debug] = false
       knife[:bmc_user]= '<value>'
       knife[:bmc_region] = 'us-phoenix-1'
       knife[:pass_phrase] = '<value>'
       knife[:compartment] = '<value>'



# Defining your Chef runlist via JSON

Under the instances section of your launchplan you can now add Chef configuration:  runlists and roles.  You can define more than one instance in your launchplan and define a unique run list, environment, and tags for each instance.
_Requires 0.1.1 or above_

     "instances": [
      {
        "attributes": {
          "userdata": {
            "chef": {
              "run_list": [
                "recipe[cron::default]",
                "recipe[Hudson]"
              ],
              "environment" : "demo",
              "tags" : [
                         "tag1",
                         "tag2"
                       ]
            }
          }
        },

## Orchestrations##

How to work with orchestrations with this plug-in

* knife opc orchestration  -A  create :  This command adds the orchestration to OPC but does not do anything with Chef
* knife opc orchestration -A delete  :  This command removes the orchestration from OPC but does not do anything with Chef 
* knife opc orchestration -A start  : This command will start the orchestration, look for an launchplans in the orchestration, find all the described instances, grab the Chef information from user data and register all nodes during the start of the orchestration.
* knife opc orchestration -A stop :  this command will stop the orchestration in OPC and remove all nodes from Chef server.
* Nested orchestrations are supported with version 0.1.4 and above

## Proxy Setup ##
To enable proxy servers create a file in your home directory called opcclientcfg.conf In the file define two properties proxy_addr and proxy_port
for details on the config file see the [configFile](https://github.com/mccoold/oracle_public_cloud_client/wiki/README)
        
        
        proxy_addr = 127.0.0.1
        proxy_port = 8888
        
### Who do I talk to? ###

* Repo Owner: Daryn McCool
* email
mdaryn@hotmail.com