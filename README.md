For the whiners from Jersey....

Pre-reqs
---------------------------------------------------------------------------------------------------------------
Download PowerShell for MacOS

Download VMWare PowerCLI

These tools are built to run a generic Ubuntu 22.04 VM

Update script with your Lab/vcenter defaults 
  vCenter Customixation script for your liinux VM - Update for your labs env - ntp, default route, etc.
  Know your root password and set it in the template
  Enable toor ssh:  modify /etc/ssh/sshd_config:
    PermitRootLogin yes
  
Update PowerCLI config to ignore invalid certs
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore






