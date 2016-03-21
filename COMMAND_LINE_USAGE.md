# **Overview**

This is the function tool set for the Oracle public cloud. This tool will allow you to have 
command line functions provisioning and maintaining cloud elements in the Oracle public cloud.

  * The gem handles both the IaaS and PaaS(JaaS, DBaaS) functinality
  *     Version 0.0.5

# **Available Commands:**

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
