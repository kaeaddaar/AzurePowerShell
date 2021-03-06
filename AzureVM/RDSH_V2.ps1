﻿ #$secPwd = "pwdHere" | ConvertTo-SecureString -AsPlainText -Force
#$cred = New-Object System.Management.Automation.PSCredential ("cliff@wws5.com", $secPwd)
#Login-AzureRmAccount -Credential $cred -SubscriptionName "Visual Studio Enterprise – MPN"

$sleep = 2
write-host "01-Logon"
Start-Sleep $sleep

# enter your logon info
Login-AzureRmAccount -SubscriptionName "Visual Studio Enterprise – MPN"
Get-AzureRmResourceGroup | Select-Object -Property ResourceGroupName, Location

$H = @{"RGName"="cmTestRG01"}
$H | Add-Member-MakeKeyScript

write-host "02a-Create " + $H.RGName
Start-Sleep $sleep

$RGLoc = "westus2"
$H.RGLoc = Get-PropFromColObj -ColObj (Get-AzureRmLocation) -HashSetting $H -ExpandProperty "Location" -NumColumns 4
New-AzureRmResourceGroup -Name $H.RGName -Location $H.RGLoc

write-host "02b-Show contents of cmTestRG01"
Start-Sleep $sleep

$H.RGName = "cmTestRG01"
Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq $H.RGName } | Select-Object -Property Name, ResourceType
# Create a resource group

write-host "03-Create a storage account"
Start-Sleep $sleep

# Create a storage account
$StorageName = "cmpsstorageacct"
#Get-AzureRmStorageAccountNameAvailability $StorageName
$goodName = Get-AzureRmStorageAccountNameAvailability $StorageName
write-host "$goodName.NameAvailable = """ + $goodName.NameAvailable
Start-Sleep 5
if ($goodName.NameAvailable)
{
$RGStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $H.RGName -Name $StorageName -Kind Storage -Location $RGLoc -SkuName "Standard_LRS"
}
else
{
$RGStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $H.RGName -Name $StorageName
}

write-host "04a-Create a subnet"
Start-Sleep $sleep

# Create a subnet
$RGSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "cmPSSubnet" -AddressPrefix 10.0.0.0/24

write-host "04b-Create a VNet"
Start-Sleep $sleep

# Create a VNet
$RGVnet = New-AzureRmVirtualNetwork -Name "cmPSVnet" -ResourceGroupName $H.RGName -Location $RGLoc -AddressPrefix 10.0.0.0/16 -Subnet $RGSubnet

write-host "05a-Create a public ip"
Start-Sleep $sleep

# Create a Public IP
$RGPublicIP = New-AzureRmPublicIpAddress -Name "cmPSPublicIP" -ResourceGroupName $H.RGName -Location $RGLoc -AllocationMethod Dynamic

write-host "05b-Create a NIC"
Start-Sleep $sleep
write-host " $RGVnet.Subnets[0].Id = """ + $RGVnet.Subnets[0].Id

# Create a NIC
$RgNIC = New-AzureRmNetworkInterface -Name "cmPSNIC" -ResourceGroupName $H.RGName -Location $RGLoc -SubnetId $RGVnet.Subnets[0].Id -PublicIpAddressId $RGPublicIP.Id

write-host "06-Create a VM"
Start-Sleep $sleep

#Create a virtual machine
$cred = Get-Credential -Message "Type the name and password of the local administrator account."
$RGVm = New-AzureRmVMConfig -VMName "cmRDSH" -VMSize "Standard_A2"
$RGVm = Set-AzureRmVMOperatingSystem -VM $RGVm -Windows -ComputerName "cmRDSH" -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$RGVm = Set-AzureRmVMSourceImage -VM $RGVm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"
$RGVm = Add-AzureRmVMNetworkInterface -VM $RGVm -Id $RgNIC.Id
$RgBlobPath = "vhds/myOsDisk1.vhd"
$RGosDistUri = $RGStorageAccount.PrimaryEndpoints.Blob.ToString() + $RgBlobPath
$RGVm = Set-AzureRmVMOSDisk -VM $RGVm -Name "myOsDisk1" -VhdUri $RGosDistUri -CreateOption FromImage
new-azurermvm -ResourceGroupName $H.RGName -Location $RGLoc -VM $RGVm

# How to get a list of image SKUs
#Get-AzureRMVMImageSku -Location "West US 2" -Publisher "MicrosoftWindowsServer" -Offer "WindowsServer" | Select Skus

Write-Host "Done"

New-AzureRmTrafficManagerProfile -Name DevApiTest2TrafficManager -ResourceGroupName "DevApi_Test" -ProfileStatus Enabled -RelativeDnsName "DevApiTM2" -Ttl 300 -TrafficRoutingMethod Performance -MonitorProtocol HTTP -MonitorPath "/"

