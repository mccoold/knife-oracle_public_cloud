# Overview

This is the function tool set for the Oracle public cloud. This tool will allow you to have 
command line functions provisioning and maintaining cloud elements in the Oracle public cloud.

  * The gem handles both the IaaS and PaaS(JaaS, DBaaS) functinality
  *     Version 0.1.6

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

**Notes**
 * configuring Network can be done with orchestrations for accounts that have IaaS, for PaaS only accounts use the network command to define network rules.
 * If using PaaS Services outside of the United States or OCM use --paas_rest_endpoint to specify the REST endpoint for your PaaS services.  (PaaS and Compute have different REST endpoints, thus the two different flags)

# Knife.rb Settings:
 Some flags to can be skipped from the command line if pre configured in the knife.rb file
The following parameters can be set in the knife.rb file
  * knife[:opc_id_domain] = '<value>'
  * knife[:opc_username] = '<value>'
  * knife[:opc_rest_endpoint] = '<value>'
  * knife[:opc_ssh_identity_file] = "<value>"
  * knife[:paas_rest_endpoint] = '<value>'


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
