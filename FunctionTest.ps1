#Functions-Common.ps1 needs to be run to create the global functions
# Logon
# getEnumResourceGroup
cls
Write-Host ----- Welcome to the Function Test Powershell Application -----
Write-Host
logon

# Purpose: I want to test creating the functions that would be used to do the RDSH demo
#  - Some functions would be used to gather the info, or load from settings
#  - Some functions would be used to gather the necessary settings
#  - Some functions would be used to create the resources

#Write-Host "Please enter a step to skip to, or hit enter to continue"
#$StepNum = Read-Host
$ErrorActionPreference = "stop"

    #The following test shows how to get the ResourceGroupChosen
    [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]$RG = Get-cmEnumResourceGroup
    $locName = "westus2"
    [Microsoft.Azure.Commands.Management.Storage.Models.PSStorageAccount]$RGStorageAccount = New-cmStorageAccount -RGName $RG.ResourceGroupName -RGLoc $locName

    Write-Host "Create a new VNet"

    $VnetName = "cmPSVnet"
    $SubnetName = "cmPSSubnet"
    $RGVnet = New-cmVNet -RGName $RG.ResourceGroupName -VNetName $VnetName -SubnetName $SubnetName -VNetAddressPrefix "10.0.0.0/16" -SubnetAddressPrefix "10.0.0.0/24"
    $RG2 = Get-AzureRmResourceGroup -Name $RG.ResourceGroupName -Location $locName

    Write-Host "Create a new public IP"

    $PubIpName = "cmPsPublicIp"
    $NicName = "cmPsNic"
    $PublicIpLocName = "westus2" # turns out that uswest2 is not in the list
    $RGPublicIP = New-cmPublicIP -RGName $RG.ResourceGroupName -RGVnet $RGVnet -RGLoc $PublicIpLocName -RGPublicIPName $PubIpName -RGNicName $NicName

Write-Host "Load Balancer begin"

# ----- Create a Load Balancer ----- begin
# https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-get-started-internet-arm-ps
$InputX = @{
    "FrontEndIpName" = "cmPsFrontEndIp"
    "FrontEndPrivateIp" = "10.0.0.5"
    "BackEndIpName" = "cmPsBackEndIp"
    "InboundNatRuleName1" = "cmPsInboundNatRdp1"
    "Inbound1FrontPort" = 3441
    "InboundNatRuleName2" = "cmPsInboundNatRdp2"
    "Inbound2FrontPort" = 3442
    "BackEndPort" = 3389
    "InboundProtocol" = "Tcp"
    "HealthProbeName" = "cmPsHealthProbe"
    "HealthProbeRequestPath" = "./"
    "HealthProbeProtocol" = "http"
    "HealthProbePort" = 80
    "HealthProbeIntervalInSeconds" = 15
    "HealthProbeProbeCount" = 2
    "LoadBalancerName" = "cmPsLoadBalancer"
    "LoadBalanceRuleName" = "cmPsLoadBalanceRule"
    "LoadBalanceProtocol" = "Tcp"
    "LoadBalanceFrontEndPort" = 80
    "LoadBalanceBackEndPort" = 80
    "BackEndNic1Name" = "cmpsbackendnic1"
    "BackEndPrivateIp1" = "10.0.0.6"
    "BackEndNic2Name" = "cmpsbackendnic2"
    "BackEndPrivateIp2" = "10.0.0.7"
}

$RGLoadBalancer = New-cmLoadBalancer -RGName $RG.ResourceGroupName -RGVnet $RGVnet -InputX $InputX

# ----- Create a Load Balancer ----- end


# ----- Create a virtual machine ----- begin
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-create?toc=%2fazure%2fload-balancer%2ftoc.json
$vmName = "cmRDSH"
# 1. Run this command to set the administrator account name and password for the virtual machine.
$cred = Get-Credential -Message "Enter the user name and password of the local admin account for the VM"

# vm size info: https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-sizes?toc=%2fazure%2fvirtual-machines%2fwindows%2ftoc.json

# 2. Create the configuration object for the virtual machine. This command creates a configuration object named myVmConfig that defines the name of the VM and the size of the VM.
$myVm = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_A1"

# Commonly used Windows images: https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-cli-ps-findimage?toc=%2fazure%2fvirtual-machines%2fwindows%2ftoc.json
# Command to get list of servers: azure vm image list westus2 MicrosoftWindowsServer

# 3. Configure operating system settings for the VM. This command sets the computer name, operating system type, and account credentials for the VM.
$myVm = Set-AzureRmVMOperatingSystem -VM $myVm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

# 4. Define the image to use to provision the VM. This command defines the Windows Server image to use for the VM
$myVm = Set-AzureRmVMSourceImage -VM $myVm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version "latest"

# 5. Add the network interface that you created to the configuration.

$myVm = Add-AzureRmVMNetworkInterface -vm $myVm -id $RGBackEndNic1.Id

# 6. Define the name and location of the VM hard disk. The virtual hard disk file is stored in a container. This command creates the disk in a container named vhds/myOsDisk1.vhd in the storage account that you created.
$blobPath = "vhds/myOsDisk1.vhd"
$osDiskUri = $RGStorageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath

# 7. Add the operating system disk information to the VM configuration. Replace The value of $diskName with a name for the operating system disk. Create the variable and add the disk information to the configuration.
$myVm = Set-AzureRmVMOSDisk -VM $myVm -Name "myOsDisk1" -VhdUri $osDiskUri -CreateOption FromImage

#8. Finally, create the virtual machine.
new-azureRmVm -ResourceGroupName $RG.ResourceGroupName -Location $locName -VM $myVm 
# ----- Create a virtual machine ----- end

# Next step is to add the second vm to the second nic, and then scale the code to work for n instances.

Write-Host "Done."
# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVWbylRPfQUATZ4q1qI0/27qY
# f0agggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
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
# FPejqu20rwdNne7Nr4+uk+CnKPEaMA0GCSqGSIb3DQEBAQUABIGALXBxgXTs2iBQ
# McIl4wFdIrPTzVDzDefZUw2i1ycG0LJlnWqbv3diVDkG/X5fOyk65+cXjUADmDEo
# Wv9vxky1EcuzjZKM/9HcDtUn1Z5KYjvOFuhbBQq3zRddoPOg9hEp2jtELJ599lXP
# AbckN6qyeJkQJPVjTMWcb1gBV0k2NUA=
# SIG # End signature block
