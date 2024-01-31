
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
$Snap_name = Read-Host -Prompt 'Snapshot name'

##############  Initializing arrays   ############################
$hosts = [object[]]::new($Num_nodes)
$IPS = [object[]]::new($Num_nodes)

#####################   Processing scripts  #######################
Write-Host "Snapping ansible VM '$ansible_node_name'..."
New-Snapshot -VM $ansible_node_name -Name $Snap_name -Memory


Write-Host "Snapping control VM '$control_node_name'..."
New-Snapshot -VM $control_node_name -Name $Snap_name -Memory

for ($i=1; $i -le $Num_nodes; $i++)
{
	Write-Host "Snapping VM '$Node_name_base$i'..."
	New-Snapshot -VM $Node_name_base$i -Name $Snap_name -Memory
}


Disconnect-VIServer -Server * -Force -Confirm:$false
