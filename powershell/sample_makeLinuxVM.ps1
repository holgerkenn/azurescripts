
# this is pre-existing stuff
$staccount="<storage account>"
$subscriptionId="<subscription ID>"
$datacenter="West Europe"
$vnetname="<name of your virtual network>"
$subnetname="<name of your subnet>"
$ipaddress="<ip address in that subnet>"

#this is what the script creates
$servicename="<cloud service name>"
$fullname=$servicename + ".cloudapp.net"
$vmname="<a VM name>"
$vmsize="Small"
$family="Ubuntu Server 14.04 LTS"
$linuxUserName="azureuser"
$linuxPassword="<a password you chose>"



#fixing up some subscription stuff
$subscriptionName = (Get-AzureSubscription | `
	select SubscriptionName, SubscriptionId | `
	Where-Object SubscriptionId -eq $subscriptionId | `
	Select-Object SubscriptionName)[0].SubscriptionName


Select-AzureSubscription -SubscriptionId $subscriptionId

set-AzureSubscription -SubscriptionID $subscriptionId -CurrentStorageAccountName $staccount


# pull the latest image name for the family out of the public VM image repository
$image=Get-AzureVMImage | where { $_.ImageFamily -eq $family } | sort PublishedDate -Descending | select -ExpandProperty ImageName -First 1


#this allows you to run the script several times without seeing error messages if the cloud service already exists
if ((Get-AzureService | where ServiceName -eq $servicename) -eq $null) {
    Write-Host "Create cloud service"
    New-AzureService -ServiceName $servicename -Location $datacenter
}


# this builds the VM configuration for our linux box
$vm1=New-AzureVMConfig -Name $vmname -InstanceSize $vmsize -ImageName $image

$vm1 | Add-AzureProvisioningConfig -Linux -LinuxUser $linuxUserName -Password $linuxPassword

$vm1 | Set-AzureStaticVNetIP -IPAddress $ipaddress

$vm1 | Set-AzureSubnet -SubnetNames $subnetname

# I don't like the random port assignment for ssh. So I fix it to the default (22) port
# Note that this enables ssh worms to guess passwords
# the ssh port should be disabled again for production use and only enabled when you need to access the machine!
$vm1 | Remove-AzureEndpoint -Name SSH

$vm1 | Add-AzureEndpoint -Name SSH -LocalPort 22 -PublicPort 22 -Protocol tcp

New-AzureVM –ServiceName $servicename -VMs $vm1 -VNetName $vnetname

