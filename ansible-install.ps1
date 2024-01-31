
$vCenterInstance = "10.207.116.50"
$vCenterUser = "administrator@vsphere.local"
$vCenterPass = "Pureuser1!"

##############  Connect to vCenter   ############################ 
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds 1800 -Confirm:$false
Connect-VIServer $vCenterInstance -User $vCenterUser -Password $vCenterPass -WarningAction SilentlyContinue

##############  Connect to vCenter   ############################ 
$ansible_node_name = Read-Host -Prompt 'Ansible node name'
$control_node_name = Read-Host -Prompt 'Kubernetes control node name'
$Node_name_base = Read-Host -Prompt 'Data node name base'
$Num_nodes = Read-Host -Prompt 'Number of data nodes'
$Subnet = Read-Host -Prompt 'Enter subnet (first three bytes)'
$IP = Read-Host -Prompt 'Starting IP address (last byte)'
$StartingIP=$IP

##############  Initializing arrays   ############################
$hosts = [object[]]::new($Num_nodes)
$IPS = [object[]]::new($Num_nodes)

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
$response = Read-Host -Prompt "Install ansible? [Y or N]"

if ( $response -eq "y" )
{
    #####################   Processing scripts  #######################
    Write-Host "Running CMD:  $script"
    $script='ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N "" -q <<< y'
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    Write-Host "Running CMD on $control_node_name :  $script"
    Invoke-VMScript -VM $control_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    $script='apt install sshpass -y'
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    Write-Host "Running CMD on $control_node_name :  $script"
    Invoke-VMScript -VM $control_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    $ip_address="$Subnet.$IP"
    $line="$ip_address $ansible_node_name"
    $script="echo $line >>/etc/hosts"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    Write-Host "Running CMD on $control_node_name :  $script"
    Invoke-VMScript -VM $control_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    $IP = [int]$IP + 1

    $ip_address="$Subnet.$IP"
    $line="$ip_address $control_node_name"
    $script="echo $line >>/etc/hosts"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    $script="sshpass -p Pureuser1! ssh-copy-id -o StrictHostKeyChecking=no root@$control_node_name"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    $IP = [int]$IP + 1

    for ($i=1; $i -le $Num_nodes; $i++)
    {
      $ip_address="$Subnet.$IP"
      $line="$ip_address $Node_name_base$i"
      $hostname="$Node_name_base$i"
      $script="echo $line >>/etc/hosts"
      Write-Host "Running CMD on $ansible_node_name :  $script"
      Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
      Write-Host "Running CMD on $control_node_name :  $script"
      Invoke-VMScript -VM $control_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
      $script="sshpass -p Pureuser1! ssh-copy-id -o StrictHostKeyChecking=no root@$hostname"
      Write-Host "Running CMD on $ansible_node_name :  $script"
      Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
      Write-Host "Running CMD on $control_node_name :  $script"
      Invoke-VMScript -VM $control_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
      $IP = [int]$IP + 1
    }

    $script="apt-add-repository ppa:ansible/ansible -y"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
    
    $script="apt update"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    $script="apt install ansible -y"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    $script="apt install python3-pip -y"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
}

#   Run/install kubernetes via ansible-playbook 
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
$response = Read-Host -Prompt "Install k8s via ansible playbook [Y or N]"

if ( $response -eq "y" )
{
    #####################  Get kubespray  #############################################
    $script="cd /usr/share; git clone https://github.com/kubernetes-sigs/kubespray"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    $script="cd /usr/share/kubespray; pip install -r requirements.txt"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    #   pip3 install -r contrib/inventory_builder/requirements.txt
    $script="cd /usr/share/kubespray; pip install -r requirements.txt"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    #   cp -pr inventory/sample inventory/mycluster
    $script="cd /usr/share/kubespray; cp -pr inventory/sample inventory/mycluster"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"

    ############################################################################
    #####################  Creating k8s hosts yaml file  #######################
    ############################################################################
    $IP=$StartingIP
    $IP = [int]$IP + 1

$YAML = @"
all:
  hosts:

"@

$ip_address="$Subnet.$IP"
$Host_IPs = $ip_address
$YAML += "    " + $control_node_name + ":"
$YAML += @"

      ansible_host: $ip_address
      ip: $ip_address
      access_ip: $ip_address

"@

$IP = [int]$IP + 1
for ($i=1; $i -le $Num_nodes; $i++)
{
  $ip_address="$Subnet.$IP"
  $Host_IPs += " $ip_address"
  $YAML += @"
    $Node_name_base${i}:
      ansible_host: $ip_address
      ip: $ip_address
      access_ip: $ip_address

"@
  $IP = [int]$IP + 1
}

$YAML += @"
  children:
    kube_control_plane:
      hosts:
        ${control_node_name}:
        ${Node_name_base}1:
    kube_node:
      hosts:
        ${control_node_name}:

"@

for ($i=1; $i -le $Num_nodes; $i++)
{
  $YAML += @"
        $Node_name_base${i}:

"@
}

$YAML += @"
    etcd:
      hosts:
        ${control_node_name}:
        ${Node_name_base}1:
        ${Node_name_base}2:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
"@


    ############################################################################
    ############  END - of Creating k8s hosts yaml file  #######################
    ############################################################################
    #   Create inventory/mycluster/hosts.yaml
    $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
    Out-File -FilePath file.$timestamp -InputObject $YAML

    Write-Host "CMD:  copying file..."
    Copy-VMGuestFile -Source file.$timestamp -Destination /usr/share/kubespray/inventory/mycluster/hosts.yaml -VM $ansible_node_name -LocalToGuest -GuestUser root -GuestPassword "Pureuser1!" -Force

    Remove-Item -Force file.$timestamp

    $script = "cd /usr/share/kubespray; ansible-playbook -i inventory/mycluster/hosts.yaml --become --become-user=root cluster.yml"
    Write-Host "Running CMD on $ansible_node_name :  $script"
    Invoke-VMScript -VM $ansible_node_name -ScriptText "$script" -GuestUser root -GuestPassword "Pureuser1!"
}
else
{
	Write-Host "OK, not running the playbook to install kubernetes.  Ansible is installed and ready."
}

Disconnect-VIServer -Server * -Force -Confirm:$false

