This set of scripts builds a cluster of VMs, and optionally, Ansible, kubernetes, and the elastic operator 

Once the requirements are met, the following scripts are run:
1.  deploy-u2204.ps1
   Deploys an ansible master, a kubernetes control node, and any number of worker nodes
2.  install-ansible.ps1
   Prompts user to install ansible, which is needed to deploy kubernetes using kubespray, but can be skipped if ansible is already installed
   Prompts user to install kubernetes - optional if you only want a cluster with ansible running - also insgtalls elastic operator

Pre-reqs
---------------------------------------------------------------------------------------------------------------
Download PowerShell for your local platform

Download VMWare PowerCLI

You will need access to an Ubuntu 22.04 template with the following commands/configurations set:
1.  Modify /etc/ssh/sshd_config and change PermitRootLogin  to “PermitRootLogin yes”
2.  Turn off the GUI login by running "sudo systemctl set-default multi-user"
3.  Make sure you know the root password
4.  Ensure the networking is setup as static and not DHCP

Update script with your Lab/vcenter defaults 
1. vCenter Customization script for your liinux VM - There is a customization script template/XML file in this rep.  You can use your own, or download and import this XML file and modify to work in your environment.
   Update for your labs env - ntp, default route, etc.
  
Update PowerCLI config to ignore invalid certs
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore






