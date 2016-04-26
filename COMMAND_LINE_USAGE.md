# Overview

This is the function tool set for the Oracle public cloud. This tool will allow you to have 
command line functions provisioning and maintaining cloud elements in the Oracle public cloud.

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
