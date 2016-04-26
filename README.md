# README #


### Knife Plugin for Oracle Public Cloud (OPC) ###


**Summary:**
This is an open source tool to integrate Chef (knife) with Oracle Public Cloud (OPC).  
The plugin adds knife commands and options allowing users to provision cloud assets on OPC e.g. java instances, database instances, compute instances, network settings, and containers
and bootstrap them into chef with a single command.  The plug-in also creates storage containers, but they are not bootstrapped for obvious reasons


### Version ###
* 0.1.2

### How do I install and configure? ###

* Setup:
  * This Gem assumes that Chef (either the development kit or a full Chef client) has been installed.  Path to the embedded\bin folder of your Chef install.
    run gem install knife-oracle_public_cloud.
  * Ensure your knife.rb file is properly configured to connect to your Chef server. 
    See below section for addition knife.rb options

     * to verify install type knife from the command line
     * you should see knife opc _list of functions_



 **Dependencies**

     Ruby (1.8+), knife(chef 11.4+), OPC(0.3.2), oracle_public_cloud_client(0.4.0)


### Usage ###

 * The gem handles both the IaaS and PaaS(JaaS, DBaaS) functinality
  *     Version 0.1.0 and above

# Available Commands:

* knife opc dbcs create: -u _username_ -i _identity_domain_ -p _password_ -j _JSON_file_  --identity-file _sshkeyfile_
* knife opc dbcs delete -u _username_ -i _identity_domain_ -p _password_ -I _Instance Service Name_
* knife opc dbcs list -u _username_ -i _identity_domain_ -p _password_
* knife opc jcs create -u _username_ -i _identity_domain_ -p _password_ -j _JSON_file_ --identity-file _sshkeyfile_
* knife opc jcs delete -u _username_ -i _identity_domain_ -p _password_ -I _Instance Service Name_
* knife opc jcs list -u _username_ -i _identity_domain_ -p _password_ 
* knife opc network -u _username_ -i _identity_domain_ -p _password_  _see JSON Page for more details_
* knife opc objectstorage create -u _username_ -i _identity_domain_ -p _password_ -C _containername_
* knife opc objectstorage delete -u _username_ -i _identity_domain_ -p _password_ -C _containername_
* knife opc objectstorage list -u _username_ -i _identity_domain_ -p _password_
   * for contents of the container: -C _containername_
* knife opc compute instance list -u _username_ -i _identity_domain_ -p _password_ 
* knife opc compute imagelist show  -u _username_ -i _identity_domain_ -p _password_    **Verison 1.2 and above
* knife opc orchestration -A _start, stop, create, delete, list, details_  -u _username_ -i _identity_domain_ -p _password_ 
   * for start, stop, delete:  -C _containername_
   * for create: -j _json_ file

**Notes**
 * configuring Network can be done with orchestrations for accounts that have IaaS, for PaaS only accounts use the network command to define network rules.

# Knife.rb Settings:
 Some flags to can be skipped from the command line if pre configured in the knife.rb file
The following parameters can be set in the knife.rb file
  * knife[:opc_id_domain] = '<value>'
  * knife[:opc_username] = '<value>'
  * knife[:opc_rest_endpoint] = '<value>'
  * knife[:opc_ssh_identity_file] = "<value>"
  * knife[:purge] = true


# Defining your Chef runlist via JSON

For Compute Orchestrations Chef can be configured via the orchestration JSON.  In the JSON under the instances section of your 
launchplan add Chef configuration:  runlists, environment, tags, and roles.  You can define more than one instance in your launchplan and define
 a unique run list, environment, and tags for each instance.  The bootstrap process will run serially.
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


	* See COMMAND_LINE_USAGE for full detail
## Proxy Setup ##
To enable proxy servers create a file in your home directory called opcclientcfg.conf In the file define two properties proxy_addr and proxy_port

proxy_addr = 127.0.0.1

proxy_port = 8888
### Who do I talk to? ###

* Repo Owner: Daryn McCool
* email
mdaryn@hotmail.com