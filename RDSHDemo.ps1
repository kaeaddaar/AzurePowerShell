 #$secPwd = "pwdHere" | ConvertTo-SecureString -AsPlainText -Force
#$cred = New-Object System.Management.Automation.PSCredential ("cliff@wws5.com", $secPwd)
#Login-AzureRmAccount -Credential $cred -SubscriptionName "Visual Studio Enterprise – MPN"

$sleep = 2
write-host "01-Logon"
Start-Sleep $sleep

# enter your logon info
Login-AzureRmAccount -SubscriptionName "Visual Studio Enterprise – MPN"
Get-AzureRmResourceGroup | Select-Object -Property ResourceGroupName, Location

write-host "02a-Create " + $RGName
Start-Sleep $sleep

New-AzureRmResourceGroup -Name $RGName -Location $RGLoc

write-host "02b-Show contents of cmTestRG01"
Start-Sleep $sleep

Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq "cmTestRG01" } | Select-Object -Property Name, ResourceType
# Create a resource group
$RGName = "cmTestRG01"
$RGLoc = "westus2"

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
$RGStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGName -Name $StorageName -Kind Storage -Location $RGLoc -SkuName "Standard_LRS"
}
else
{
$RGStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $RGName -Name $StorageName
}

write-host "04a-Create a subnet"
Start-Sleep $sleep

# Create a subnet
$RGSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name "cmPSSubnet" -AddressPrefix 10.0.0.0/24

write-host "04b-Create a VNet"
Start-Sleep $sleep

# Create a VNet
$RGVnet = New-AzureRmVirtualNetwork -Name "cmPSVnet" -ResourceGroupName $RGName -Location $RGLoc -AddressPrefix 10.0.0.0/16 -Subnet $RGSubnet

write-host "05a-Create a public ip"
Start-Sleep $sleep

# Create a Public IP
$RGPublicIP = New-AzureRmPublicIpAddress -Name "cmPSPublicIP" -ResourceGroupName $RGName -Location $RGLoc -AllocationMethod Dynamic

write-host "05b-Create a NIC"
Start-Sleep $sleep
write-host " $RGVnet.Subnets[0].Id = """ + $RGVnet.Subnets[0].Id

# Create a NIC
$RgNIC = New-AzureRmNetworkInterface -Name "cmPSNIC" -ResourceGroupName $RGName -Location $RGLoc -SubnetId $RGVnet.Subnets[0].Id -PublicIpAddressId $RGPublicIP.Id

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
new-azurermvm -ResourceGroupName $RGName -Location $RGLoc -VM $RGVm

# How to get a list of image SKUs
#Get-AzureRMVMImageSku -Location "West US 2" -Publisher "MicrosoftWindowsServer" -Offer "WindowsServer" | Select Skus

Write-Host "Done"

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt7P+1d8qxI9movFeCDG+bAOL
# aKOgggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNzAyMDkxNzU3NDBaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxJMXSX2yDza4
# YoV7fYGLG+XE5KuXS17haubcZNNb85RbiguXlg8mOViEUalyEcEPdY5xfR1b62K7
# Jt3J82RlEfwnVtmin5EXW3hYOYRP87U/pkKiq1MHULcmKO2kReTQmMtJB7Lw7HMB
# g7bsaQzkOqzbgL38cMaowb/Kjo+VR+MCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQO7kzIfSp327hSz/mt29jcKEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQrgjaQlc+9IhF3X9o
# nylYgTAJBgUrDgMCHQUAA4GBAAy7KZBYUA9VbxygZSoCQVZnjgDjcu5tmHnWxqhD
# OS2ZuMoMH38IO1D9fgqc2dvSANyVtvZ9KLPZcBvbos1yprogGvAIHZ5S2LEHvE1f
# cB8ygMkqEmCddMeT7nJx0rU5wUaG8FMB44nA676kC33HIabLVc1CQq7oU0JbR5BO
# j8IcMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEF6p4BzLRSWQS77SgeZDGJswCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FCrZmuSiZSTLncDrdyZJc7j7B1vLMA0GCSqGSIb3DQEBAQUABIGAXD5ayQ63AZf+
# wCJU1+BUFpT34varDofQJb7M5R8aeUZVF80vRh22aM03s4BGp80K1UmPJd82KuSI
# /8d6hX2WeeE8PJJlYC4cDon3Dqz25HF4pMkv+HtwaOhdit/VhU6rJNQVSD8K7OP7
# Qx4AiWhzwsdzac3OrA9mQJhankL70k8=
# SIG # End signature block
