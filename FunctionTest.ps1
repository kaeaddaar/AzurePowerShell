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


#The following test shows how to get the ResourceGroupChosen
[Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]$RG = Get-cmEnumResourceGroup
$locName = "westus2"
$RGStorageAccount = New-cmStorageAccount -RGName $RG.ResourceGroupName -RGLoc $locName

$VnetName = "cmPSVnet"
$SubnetName = "cmPSSubnet"
$RGVnet = New-cmVNet -RGName $RG.ResourceGroupName -VNetName $VnetName -SubnetName $SubnetName
$RG2 = Get-AzureRmResourceGroup -Name $RG.ResourceGroupName -Location $locName

$PubIpName = "cmPsPublicIp"
$NicName = "cmPsNic"
$PublicIpLocName = "westus2" # turns out that uswest2 is not in the list
$RGPublicIP = New-cmPublicIP -RGName $RG.ResourceGroupName -RGVnet $RGVnet -RGLoc $PublicIpLocName -RGPublicIPName $PubIpName -RGNicName $NicName

# ----- Create a Load Balancer ----- begin

$FrontEndIpName = "cmPsFrontEndIp"
$FrontEndPrivateIp = "10.0.2.5"
$RGFrontEndIp = New-AzureRmLoadBalancerFrontendIpConfig -Name $FrontEndIpName -PrivateIpAddress $FrontEndPrivateIp -SubnetId $RGVnet.subnets[0].Id

$BackEndIpName = "cmPsBackEndIp"
$RGBackEndAddressPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $BackEndIpName

$InboundNatRuleName1 = "cmPsInboundNatRdp1"
$Inbound1FrontPort = 3441 
$InboundNatRuleName2 = "cmPsInboundNatRdp2"
$Inbound2FrontPort = 3442
$BackEndPort = 3389
$InboundProtocol = "Tcp"
$RGInboundNatRule1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $InboundNatRuleName1 -FrontendIpConfiguration $RGFrontEndIp -Protocol $InboundProtocol -FrontendPort $Inbound1FrontPort -BackendPort $BackEndPort
$RGInboundNatRule2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name $InboundNatRuleName2 -FrontendIpConfiguration $RGFrontEndIp -Protocol $InboundProtocol -FrontendPort $Inbound2FrontPort -BackendPort $BackEndPort

$HealthProbeName = "cmPsHealthProbe"
$HealthProbeRequestPath = "./"
$HealthProbeProtocol = "http"
$HealthProbePort = 80
$HealthProbeIntervalInSeconds = 15
$HealthProbeProbeCount = 2
$LoadBalanceRuleName = "cmPsLoadBalanceRule"
$LoadBalanceProtocol = "Tcp"
$LoadBalanceFrontEndPort = 80
$LoadBalanceBackEndPort = 80
$RGHealthProbe = New-AzureRmLoadBalancerProbeConfig -Name $HealthProbeName -RequestPath $HealthProbeRequestPath -Protocol $HealthProbeProtocol -Port $HealthProbePort -IntervalInSeconds $HealthProbeIntervalInSeconds -ProbeCount $HealthProbeProbeCount
$RGLoadBalanceRule = New-AzureRmLoadBalancerRuleConfig -Name $LoadBalanceRuleName -FrontendIpConfiguration $RGFrontEndIp -BackendAddressPool $RGBackEndAddressPool -Probe $RGHealthProbe -Protocol $LoadBalanceProtocol -FrontendPort $LoadBalanceFrontEndPort -BackendPort $LoadBalanceBackEndPort

$LoadBlancerName = "cmPsLoadBalancer"
$RGLoadBalancer = New-AzureRmLoadBalancer -ResourceGroupName $Rg.ResourceGroupName -Name $LoadBlancerName -Location $locName -FrontendIpConfiguration $RGFrontEndIp -InboundNatRule $RGLoadBalanceRule -BackendAddressPool $RGBackEndAddressPool -Probe $RGHealthProbe

#$VnetBackEndSubnetName = "cmpsbackendsubnet"
$VnetBackEndSubnetName = $SubnetName
$RGBackEndSubnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $VnetBackEndSubnetName -VirtualNetwork $RGVnet
$BackEndNic1Name = "cmpsbackendnic1"
$BackEndPrivateIp1 = "10.0.2.6"
$RGBackEndNic1 = New-AzureRmNetworkInterface -ResourceGroupName $RG.ResourceGroupName -Name $BackEndNic1Name -Location $locName -PrivateIpAddress $BackEndPrivateIp1 -Subnet $RGBackEndSubnet -LoadBalancerBackendAddressPool $RGLoadBalancer.BackendAddressPools[0] -LoadBalancerInboundNatRule $RGLoadBalancer.InboundNatRules[0]
$BackEndNic2Name = "cmpsbackendnic2"
$BackEndPrivateIp2 = "10.0.2.7"
$RGBackEndNic1 = New-AzureRmNetworkInterface -ResourceGroupName $RG.ResourceGroupName -Name $BackEndNic2Name -Location $locName -PrivateIpAddress $BackEndPrivateIp2 -Subnet $RGBackEndSubnet -LoadBalancerBackendAddressPool $RGLoadBalancer.BackendAddressPools[0] -LoadBalancerInboundNatRule $RGLoadBalancer.InboundNatRules[1]

$RGBackEndNic1
# ----- Create a Load Balancer ----- end

Write-Host "Done."