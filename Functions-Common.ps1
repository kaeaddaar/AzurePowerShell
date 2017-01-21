# Author: Clifford MacKay
# ----- Logon -----

function global:Logon
{
    write-host "Enter Y if you would like to enter your credentials, or hit ENTER to continue"
    $LogonAgain = Read-Host

    if($LogonAgain -eq "Y")
    {
        # enter your logon info
        Login-AzureRmAccount -SubscriptionName "Visual Studio Enterprise – MPN"
    }
}


# ----- get-cmEnumResourceGroup -----

function global:get-cmEnumResourceGroup # Returns the ResourceGroup selected
{
    #Write-Host "Start: get-EnumResourceGroup"
    $colRG = Get-AzureRmResourceGroup
    Write-Host $colRG  | Select-Object -Property ResourceGroupName, Location
    $EnumRG = -1

    # Enumerate the resource Group
    for($i=0; $i -le $colRG.Count - 1; $i++)
    {
        $RG = $colRG[$i]
        write-host $i, $RG.ResourceGroupName
    }

    write-host ""
    write-host "Enter the number of the resource group you would like to select. (Hit ENTER key to get ResourceGroup 0)"
    $RGNum = Read-Host
    $RGName = $colRG[$RGNum].ResourceGroupName
    

    #Write-Host 01 $colRG[$RGNum].ResourceGroupName
    foreach ($RG in $colRG)
    {
        if ($RG.ResourceGroupName -eq $RGName)
        {
            [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]$ReturnResult = $RG
            #Write-Host 02 $RG.ResourceGroupName
        }
    }
    $ReturnResult
    if ($ReturnResult -eq $null) 
    {
        Write-Host "Resource Group Not Found, breaking"
        break
    }
    else 
    {
        if ($ReturnResult.Count -gt 1)
        {
            Write-Host 'More than 1 resource group was returned. Count = '$ReturnResult.Count'. Breaking'
            break
        }
        else
        {
            Write-Host 'Resource Group Found: "'$ReturnResult.ResourceGroupName'"'
        }
    }
    #Write-Host "End: get-cmEnumResourceGroup"
}


# ----- New-cmStorageAccount

function global:New-cmStorageAccount ([Parameter(Mandatory=$true)] [String]$RGName, [string]$StorageName = "cmpsstorageacct", $Kind = "Storage", $SkuName = "Standard_LRS", $RGLoc = "westus2")
{
    # Create a storage account
    NB $StorageName
    $goodName = Get-AzureRmStorageAccountNameAvailability $StorageName
    #write-host 'goodName.NameAvailable = "' $goodName.NameAvailable
    sleep 5
    if ($goodName.NameAvailable)
    {
        $RGStorageAccount = New-AzureRmStorageAccount -ResourceGroupName $RGName -Name $StorageName -Kind Storage -Location $RGLoc -SkuName "Standard_LRS"
    }
    else
    {
        Write-Host "The name $StorageName is not available, proceeding to get it from $RGName. We will break on error. It may be that the storage account is use in another ResourceGroup."
        $RGStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $RGName -Name $StorageName
        NB $RGStorageAccount
    }
    $RGStorageAccount
}


# ----- New-cmVNet -----

Function global:New-cmVNet 
{
    Param
    (   
        [Parameter(Mandatory=$true)] [String]$RGName, 
        [Parameter(Mandatory=$true)] [String]$VNetName, 
        [Parameter(Mandatory=$true)] [String]$SubnetName, 
        [String]$VNetAddressPrefix = "10.0.0.0/16", 
        [String]$SubnetAddressPrefix = "10.0.0.0/24",
        [String]$RGLoc = "westus2"
    )
    

    # Create a subnet
    $RGSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix

    # Create a VNet
    $RGVnet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGName -Location $RGLoc -AddressPrefix $VNetAddressPrefix -Subnet $RGSubnet
    $RGVnet
}


# ----- get-cmValidOption ----- Utility

Function global:get-cmValidOption ($Arr, $PropName, $Default)
{    
    # Purpose: take and arrany, enumerate it, and allow the user to choose an element
    if ($Arr -eq $null) { Break }
    for($i=0; $i -le $Arr.Count - 1; $i++) { write-host $i, $Arr[$i] }
    Write-Host 'Please select a valid option from the list (hit Enter to pick option 0)'
    $Choice = Read-Host
    if ($Arr -eq $null) { Break }

    if ($ReturnResult.Count -gt 1)
    {
        Write-Host 'More than 1 resource group was returned. Count = '$ReturnResult.Count'. Returning the default'
        $Default
    }
    else
    {
        $Arr[$Choice]
    }
}

# ----- Get public ip -----

function global:New-cmPublicIP
{
    Param
    (   

        [Parameter(Mandatory=$true)] [String]$RGName, 
        [Parameter(Mandatory=$true)] $RGVnet, 
        [String]$RGLoc = "uswest2", 
        [String]$RGPublicIPName = "cmPSPublicIP",
        [String]$RGNicName = "cmPSNIC"
    )

# Create a Public IP
$RGPublicIP = New-AzureRmPublicIpAddress -Name $RGPublicIPName -ResourceGroupName $RGName -Location $RGLoc -AllocationMethod Dynamic

#write-host " $RGVnet.Subnets[0].Id = """ + $RGVnet.Subnets[0].Id

# Create a NIC
$RgNIC = New-AzureRmNetworkInterface -Name "cmPSNIC" -ResourceGroupName $RGName -Location $RGLoc -SubnetId $RGVnet.Subnets[0].Id -PublicIpAddressId $RGPublicIP.Id

}

# ----- CNull ----- Purpose: If null initialize to a value (need to test)
Function global:CNull($Anything, $ValueIfNull) { if ($Anything -eq $null) { $Anything = $ValueIfNull } else { $false } }
# ----- NB ----- Purpose: Break on null
Function global:NB ($Anything, $Message = "Breaking") { if ($Anything -eq $null) 
{ Write-Host $Message
break } }