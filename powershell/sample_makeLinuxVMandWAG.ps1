
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


#this is local stuff for configuring the SSL part of the Web Application Gateway
$gatewayconfig="C:\users\holgerk\Documents\TestApplicationGatewayConfig.xml"
$pathToSelfSignedCertPfx="C:\Users\holgerk\Documents\testcert.pfx"
$selfSignedCertPasswd="1234"


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


#this configures the web application gateway

#make uf a self-signed certificate, use the DNS full name of the cloud service.
#this is just for testing, build a real .pfx for your key and upload it
$selfsignedcert = New-SelfSignedCertificate -DnsName $fullname -CertStoreLocation "cert:\CurrentUser\My"
$certpath = "cert:\currentuser\my\" + $selfsignedcert.Thumbprint 
$mypwd = ConvertTo-SecureString -String $selfSignedCertPasswd -Force –AsPlainText


Export-PfxCertificate -Cert $certpath -FilePath $pathToSelfSignedCertPfx -Password $mypwd

#default size is medium, see https://azure.microsoft.com/en-gb/services/application-gateway/ for pricing! Use -GatewaySize <String> to set size
New-AzureApplicationGateway -Name AppGwTest -VnetName $vnetname -Subnets $subnetname

#this actually uploads the cert as .pfx
Add-AzureApplicationGatewaySslCertificate  -Name AppGwTest -CertificateName GWCert -Password $selfSignedCertPasswd -CertificateFile $pathToSelfSignedCertPfx

$GWCert = Get-AzureApplicationGatewaySslCertificate AppGwTest 

#this is the name you have to use in your gateway config file. 
$GWCert.Name


Set-AzureApplicationGatewayConfig -Name AppGwTest -ConfigFile $gatewayconfig

Start-AzureApplicationGateway AppGwTest 

Get-AzureApplicationGateway AppGwTest 
#this should show that the gateway is running



