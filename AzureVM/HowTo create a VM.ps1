﻿# this is what I want to create
get-help New-AzureRmVM

# Pick a name:
$VmName = "AD"

# I need to use New-AzureRmVmConfig to get a PSVirtualMachine object
get-help New-AzureRmVMConfig

# Other cmdlets can be used to configure the vm object.
get-help Set-AzureRmVMOperatingSystem
get-help Set-AzureRmVMSourceImage
get-help Add-AzureRmVMNetworkInterface
get-help Set-AzureRmVMOSDisk

#Set-AzureRmVmOperatingSystem needs the vm via -vm, -windows, computername via -computername, credentials via -credential
get-help Get-Credential

$Cred = get-credential -Message "Enter the new vm's username and password"
get-help Get-AzureRmAvailabilitySet

# We need the Resource Group that we are going to use to be created, or to be selected
$RG = get-cmEnumResourceGroup

# get-AzureRmAvailabilitySet needs a resourcegroupname via -resourcegroupname, and can take the availability set name via -Name


#New-AzureRmVmConfig ----- begin
New-AzureRmVMConfig -VMName $VmName -VMSize "Standard_A2" 
    get-command *vmsize*
    get-help Get-AzureRmVMSize # needs resourcegroupname, or location. I want to use location, but i need a list of locations

    get-command *location*
    get-help Get-AzureRmLocation
    Get-AzureRmLocation | Select-Object -Property Location
    $ArrLoc = get-AzureRmLocation | Select-Object -Property Location
    get-cmEnumArray -Arr $ArrLoc -ListName Location

    get-azurermvmsize -Location (Get-PLocation $PLocation)
 New-AzureRmVMConfig -VMName $VmName -VMSize (Get-PVMSize $PVmSize)
$VmConfig = new-azurermvmconfig -VMName $VmName (Get-PVMSize $PVmSize) 
#New-AzureRmVmConfig ----- end





