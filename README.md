This set of scripts builds a cluster of VMs, and optionally, Ansible, kubernetes, and the elastic operator 

Once the requirements are met, the following scripts are run:
1.  deploy-u2204.ps1
   Deploys an ansible master, a kubernetes control node, and any number of worker nodes
2.  install-ansible.ps1
   Prompts user to install ansible, which is needed to deploy kubernetes using kubespray, but can be skipped if ansible is already installed
   Prompts user to install kubernetes - optional if you only want a cluster with ansible running
3.  install-eck.sh
   This script is run on the kubernetes control node to deploy the elastic operator

Pre-reqs
---------------------------------------------------------------------------------------------------------------
Download PowerShell for MacOS

Download VMWare PowerCLI

These tools are built to run a generic Ubuntu 22.04 VM

Update script with your Lab/vcenter defaults 
	vCenter Customixation script for your liinux VM - Update for your labs env - ntp, default route, etc.
	Know your root password and set it in the template
  Enable root ssh:  modify /etc/ssh/sshd_config:
	PermitRootLogin yes
  
Update PowerCLI config to ignore invalid certs
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore






