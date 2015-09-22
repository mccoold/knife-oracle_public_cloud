# README #


### Knife Plugin for Oracle Public Cloud PaaS (OPC) ###


** Summary: **
This is an open source tool and repo for the knife-opc plugin used to integrate Chef (knife) with Oracle Public Cloud (OPC).  
The plugin adds knife command and options to allow users to provision Java instances, database instances and bootstrap them 
into chef with a single command.  The plug-in also creates storage containers, but they are not bootstrapped for obvious reasons
Has list feature for storage, DB, and Java as well
### Version ###
* 0.0.1

### How do I get set up? ###

* Setup:
This GEM and the OPC gem will need to be installed into the instance of ruby that 
comes embedded with Chef and is used by knife



 **Dependencies**

     Ruby (1.8+), knife(chef 11.4+), OPC(0.0.1)


### Usage ###


	* The following flags are required with all commands 
		* -u --user_name  The user name for the Oracle cloud account
		* --id_domain  The id domain for the Oracle Cloud account
		* -p --passwd The password for the Oracle cloud account



### Who do I talk to? ###

* Repo Owner: Daryn McCool
* email
mdaryn@hotmail.com