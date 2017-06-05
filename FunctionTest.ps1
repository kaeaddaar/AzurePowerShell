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

$FrontEndIpPoolName = "cmPsFrontEndIp" # private, naming convention needed
$FrontEndPrivateIp = "10.0.0.5" # private, numbering system needed
Write-Host '$RGFrontEndIp = New-AzureRmLoadBalancerFrontendIpConfig ...'
# private
$RGFrontEndIp = New-AzureRmLoadBalancerFrontendIpConfig -Name $FrontEndIpPoolName -PrivateIpAddress $FrontEndPrivateIp -SubnetId $RGVnet.subnets[0].Id

$BackEndIpPoolName = "cmPsBackEndIp" # private, naming convention needed
Write-host '$RGBackEndAddressPool = New-AzureRmLoadBalancerBackendAddressPoolConfig ...'
# private
$RGBackEndAddressPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BackEndIpPoolName

$InboundNatRuleName1 = "cmPsInboundNatRdp1" # private, naming convention needed
$Inbound1FrontPort = 3441 # private
$InboundNatRuleName2 = "cmPsInboundNatRdp2" # private, naming convention needed
$Inbound2FrontPort = 3442 # private
$BackEndPort = 3389 # private
$InboundProtocol = "Tcp" # private
Write-Host '$RGInboundNatRule1 = New-AzureRmLoadBalancerInboundNatRuleConfig ...'
# private
$RGInboundNatRule1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $InboundNatRuleName1 -FrontendIpConfiguration $RGFrontEndIp -Protocol $InboundProtocol -FrontendPort $Inbound1FrontPort -BackendPort $BackEndPort
WRite-host '$RGInboundNatRule2 = New-AzureRmLoadBalancerInboundNatRuleConfig ...'
# private
$RGInboundNatRule2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $InboundNatRuleName2 -FrontendIpConfiguration $RGFrontEndIp -Protocol $InboundProtocol -FrontendPort $Inbound2FrontPort -BackendPort $BackEndPort

$HealthProbeName = "cmPsHealthProbe" # private
$HealthProbeRequestPath = "./" # private
$HealthProbeProtocol = "http" # private
$HealthProbePort = 80 # private
$HealthProbeIntervalInSeconds = 15 # private
$HealthProbeProbeCount = 2 # private
$LoadBalanceRuleName = "cmPsLoadBalanceRule" # private, naming convention might be needed
$LoadBalanceProtocol = "Tcp" # private
$LoadBalanceFrontEndPort = 80 # private
$LoadBalanceBackEndPort = 80 # private
write-host '$RGHealthProbe = New-AzureRmLoadBalancerProbeConfig'
# private
$RGHealthProbe = New-AzureRmLoadBalancerProbeConfig -Name $HealthProbeName -RequestPath $HealthProbeRequestPath -Protocol $HealthProbeProtocol -Port $HealthProbePort -IntervalInSeconds $HealthProbeIntervalInSeconds -ProbeCount $HealthProbeProbeCount
Write-Host '$RGLoadBalanceRule = New-AzureRmLoadBalancerRuleConfig'
# private
$RGLoadBalanceRule = New-AzureRmLoadBalancerRuleConfig -Name $LoadBalanceRuleName -FrontendIpConfiguration $RGFrontEndIp -BackendAddressPool $RGBackEndAddressPool -Probe $RGHealthProbe -Protocol $LoadBalanceProtocol -FrontendPort $LoadBalanceFrontEndPort -BackendPort $LoadBalanceBackEndPort

$LoadBlancerName = "cmPsLoadBalancer" # private
write-host '$RGLoadBalancer = New-AzureRmLoadBalancer ...'
$RGLoadBalancer = New-AzureRmLoadBalancer -ResourceGroupName $Rg.ResourceGroupName -Name $LoadBlancerName -Location $locName -FrontendIpConfiguration $RGFrontEndIp -InboundNatRule $RGInboundNatRule1 -BackendAddressPool $RGBackEndAddressPool -Probe $RGHealthProbe
  
#$VnetBackEndSubnetName = "cmpsbackendsubnet"
$VnetBackEndSubnetName = $SubnetName
Write-Host '$RGBackEndSubnet = Get-AzureRmVirtualNetworkSubnetConfig ...'
$RGBackEndSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $VnetBackEndSubnetName -VirtualNetwork $RGVnet
$BackEndNic1Name = "cmpsbackendnic1"
$BackEndPrivateIp1 = "10.0.0.6"
Write-Host '$RGBackEndNic1 = New-AzureRmNetworkInterface ...'
$RGBackEndNic1 = New-AzureRmNetworkInterface -ResourceGroupName $RG.ResourceGroupName -Name $BackEndNic1Name -Location $locName -PrivateIpAddress $BackEndPrivateIp1 -Subnet $RGBackEndSubnet -LoadBalancerBackendAddressPool $RGLoadBalancer.BackendAddressPools[0] -LoadBalancerInboundNatRule $RGLoadBalancer.InboundNatRules[0]
$BackEndNic2Name = "cmpsbackendnic2"
$BackEndPrivateIp2 = "10.0.0.7"
Write-Host '$RGBackEndNic1 = New-AzureRmNetworkInterface ...'
$RGBackEndNic1 = New-AzureRmNetworkInterface -ResourceGroupName $RG.ResourceGroupName -Name $BackEndNic2Name -Location $locName -PrivateIpAddress $BackEndPrivateIp2 -Subnet $RGBackEndSubnet -LoadBalancerBackendAddressPool $RGLoadBalancer.BackendAddressPools[0] -LoadBalancerInboundNatRule $RGLoadBalancer.InboundNatRules[1]

$RGBackEndNic1
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
# Trying to use load balancer as network interface
#$myVm = Add-AzureRmVMNetworkInterface -vm $myVm -id $RGLoadBalancer.Id
$myVm = Add-AzureRmVMNetworkInterface -vm $myVm -id $RGBackEndNic1.Id

# 6. Define the name and location of the VM hard disk. The virtual hard disk file is stored in a container. This command creates the disk in a container named vhds/myOsDisk1.vhd in the storage account that you created.
$blobPath = "vhds/myOsDisk1.vhd"
$osDiskUri = $RGStorageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath

# 7. Add the operating system disk information to the VM configuration. Replace The value of $diskName with a name for the operating system disk. Create the variable and add the disk information to the configuration.
$myVm = Set-AzureRmVMOSDisk -VM $myVm -Name "myOsDisk1" -VhdUri $osDiskUri -CreateOption FromImage

#8. Finally, create the virtual machine.
new-azureRmVm -ResourceGroupName $RG.ResourceGroupName -Location $locName -VM $myVm 
# ----- Create a virtual machine ----- end


Write-Host "Done."