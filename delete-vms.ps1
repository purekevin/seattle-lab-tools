
$vCenterInstance = "10.207.116.50"
$vCenterUser = "administrator@vsphere.local"
$vCenterPass = "Pureuser1!"

##############  Connect to vCenter   ############################
Connect-VIServer $vCenterInstance -User $vCenterUser -Password $vCenterPass -WarningAction SilentlyContinue

##############  Connect to vCenter   ############################
$ansible_node_name = Read-Host -Prompt 'Ansible node name'
$control_node_name = Read-Host -Prompt 'Kubernetes control node name'
$Node_name_base = Read-Host -Prompt 'Data node name base'
$Num_nodes = Read-Host -Prompt 'Number of data nodes'

##############  Initializing arrays   ############################
$hosts = [object[]]::new($Num_nodes)
$IPS = [object[]]::new($Num_nodes)

#####################   Processing scripts  #######################
Write-Host "Deleting ansible VM '$ansible_node_name'..."
Stop-VM -VM $ansible_node_name -Kill -Confirm:$false
Remove-VM -VM $ansible_node_name -DeleteFromDisk -Confirm:$false -RunAsync

Write-Host "Deleting control VM '$control_node_name'..."
Stop-VM -VM $control_node_name -Kill -Confirm:$false
Remove-VM -VM $control_node_name -DeleteFromDisk -Confirm:$false -RunAsync

for ($i=1; $i -le $Num_nodes; $i++)
{
	Write-Host "Deleting VM '$Node_name_base$i'..."
	Stop-VM -VM $Node_name_base$i -Kill -Confirm:$false
        Remove-VM -VM $Node_name_base$i -DeleteFromDisk -Confirm:$false -RunAsync
}


Disconnect-VIServer -Server * -Force -Confirm:$false
