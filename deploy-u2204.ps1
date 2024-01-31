
$vCenterInstance = "10.207.116.50"
$vCenterUser = "administrator@vsphere.local"
$vCenterPass = "Pureuser1!"

$templateName = 'ubuntu-2204'
$esxName = 'esx4.sealab.local'
$dsName = 'm50-datastore'
$oscustomscript = 'Linux-IP'
$default_route = '10.207.116.1'
$netmask = '255.255.255.0'

$Subnet = "10.207.116"

########################  End of definitions  #############################################

$ansible_node_name = Read-Host -Prompt 'Ansible node name'
$control_node_name = Read-Host -Prompt 'Kubernetes control node name'
$Node_name_base = Read-Host -Prompt 'Data node name base'
$Num_nodes = Read-Host -Prompt 'Number of data nodes'
$Subnet = Read-Host -Prompt "Enter subnet (first three bytes: $Subnet)"
$IP = Read-Host -Prompt 'Starting IP address (last byte)'

##############  Initializing arrays   ############################ 
$hosts = [object[]]::new($Num_nodes)
$IPS = [object[]]::new($Num_nodes)

##############  COnnect to vCenter   ############################ 
Connect-VIServer $vCenterInstance -User $vCenterUser -Password $vCenterPass -WarningAction SilentlyContinue
Write-host "Done connecting to vcenter"

#####################   Prep variables to be used  #######################
$template = Get-Template -Name $templateName
$ds = Get-Datastore -Name $dsName
$esx = Get-VMHost -Name $esxName
$oscustomization = Get-OSCustomizationSpec -Name $oscustomscript

Get-OSCustomizationSpec -Name $oscustomscript | New-OSCustomizationSpec -Name tempscript -Type NonPersistent

Write-Host ""
Write-Host "Creating ansible node '$ansible_node_name'..."
$ip_address="$Subnet.$IP"
Write-Host "IP address: '$ip_address'"
Get-OSCustomizationSpec -Name tempscript | Get-OSCustomizationNicMapping |
Set-OSCustomizationNicMapping -Ipmode UseStaticIP -IpAddress $ip_address -SubnetMask $netmask -DefaultGateway $default_route
$vm = New-VM -OSCustomizationSpec tempscript -Template $templateName -Name $ansible_node_name -VMHost $esx -Datastore $ds -DiskStorageFormat Thin
Start-VM -VM $vm -Confirm:$false
$IP = [int]$IP + 1

Write-Host ""
Write-Host "Creating kubernetes control node '$control_node_name'..."
$ip_address="$Subnet.$IP"
Write-Host "IP address: '$ip_address'"
Get-OSCustomizationSpec -Name tempscript | Get-OSCustomizationNicMapping |
Set-OSCustomizationNicMapping -Ipmode UseStaticIP -IpAddress $ip_address -SubnetMask $netmask -DefaultGateway $default_route
$vm = New-VM -OSCustomizationSpec tempscript -Template $templateName -Name $control_node_name -VMHost $esx -Datastore $ds -DiskStorageFormat Thin
Start-VM -VM $vm -Confirm:$false
$IP = [int]$IP + 1

##########################   Loop to create all the data nodes   ########################################

$index=0
for ($i=1; $i -le $Num_nodes; $i++)
{
  Write-Host "Creating kubernetes data node '$Node_name_base$i'..."
  $ip_address="$Subnet.$IP"
  Write-Host "IP address: '$ip_address'"
  Get-OSCustomizationSpec -Name tempscript | Get-OSCustomizationNicMapping |
  Set-OSCustomizationNicMapping -Ipmode UseStaticIP -IpAddress $ip_address -SubnetMask $netmask -DefaultGateway $default_route
  $vm = New-VM -OSCustomizationSpec tempscript -Template $templateName -Name "$Node_name_base$i" -VMHost $esx -Datastore $ds -DiskStorageFormat Thin
  Start-VM -VM $vm -Confirm:$false
  $hostname="$Node_name_base$i"
  $hosts[$index]=@($hostname)
  $IPS[$index]=@($ip_address)
  $index++
  $IP = [int]$IP + 1
}

Remove-OSCustomizationSpec tempscript -Confirm:$false

#for ( $index = 0; $index -lt $hosts.count; $index++)
#{
    #$host_name= "{0}" -f $hosts[$index]
    #$IPaddress="{0}" -f $IPS[$index]
    #Write-Host "$IPaddress $host_name"
#}
