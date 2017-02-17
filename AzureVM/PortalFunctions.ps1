# ----- get-cmEnumResourceGroup -----

function global:get-cmEnumResourceGroup # Returns the ResourceGroup selected
{
    #[OutputType ([Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup])]
    Param (
    #[Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup]$RgInput
    $RgInput
    )
    if($RgInput -ne $null) # if we have a good resource group then just pass it back, other code only needed if we dont have one.
    {
        $RgInput
    }
    else #run the rest of the script
    {
        #Get-AzureRmNetworkInterface -ResourceGroupName cmRDSH2 | Format-List -Property Name,ResourceGroupName,Location
        #Write-Host "Start: get-cmEnumResourceGroup"
        $colRG = Get-AzureRmResourceGroup
        #Write-Host $colRG  | Select-Object -Property ResourceGroupName, Location
        $EnumRG = -1

        # Enumerate the resource Group
        for($i=0; $i -le $colRG.Count - 1; $i++)
        {
            $RG = $colRG[$i]
            write-host $i, $RG.ResourceGroupName
        }

        write-host ""
        write-host "Enter the number of the resource group you would like to select or use N to create a new Resource Group. (Hit ENTER key to get ResourceGroup 0)"
        $RGNum = Read-Host
        if ($RGNum -eq "N")
        {
            # create a new resource group
            New-AzureRmResourceGroup
        }
        else
        {
            if (($RGNum -match '^\d+$') -ne $true) # if not a positive integer
            {
                Write-Output "You didn't chose N or a valid integer less than " + $colRG.Count + " exiting."
                break
            }
        }
        if ($RGNum -ge $colRG.Count)
        { 
            Write-Output $RGNum + " is not a valid choice, exiting."
            break
        }
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
}


function global:get-cmEnumArray
{
    [OutputType([string])]
    param
    (
        [parameter(Mandatory=$true)]
        [System.Array]$Arr,
        [string]$ListName = "Array"
    ) 

    if ($Arr -eq $null) {break}# if Array is null then break

    #Write-Host $colRG  | Select-Object -Property ResourceGroupName, Location
    $EnumRG = -1

    # Enumerate the resource Group
    for($i=0; $i -le $Arr.Count - 1; $i++)
    {
        write-host $i, $Arr[$i]."$ListName"
    }

    write-host ""
    write-host "Enter the number of the $ListName you would like to select."
    $ArrNum = Read-Host
    if (($ArrNum -match '^\d+$') -ne $true) # if not a positive integer
    {
        Write-Output "You didn't chose a valid integer less than " + $Arr.Count + " exiting."
        break
    }
    if ($ArrNum -ge $Arr.Count)
    { 
        Write-Output $ArrNum + " is not a valid choice, exiting."
        break
    }
    [String]$Return = $Arr[$ArrNum] | Select -ExpandProperty $ListName
    $Return

}



function global:Get-PLocation # Gets the location as the portal would
{
    [OutputType([string])]
    param
    (
        $LocationInput
    )
    if ($LocationInput -eq $null)
    {
        get-cmEnumArray -Arr (get-AzureRmLocation | Select-Object -Property Location) -ListName Location
    }
    else
    {
        $LocationInput
    }
}


function global:Get-PVMSize # Gets the VMSize as the portal would
{
    [OutputType([string])]
    param
    (
        $VMSizeInput, 
        $LocationAuto
    )
    if ($VMSizeInput -eq $null)
    {
        get-cmEnumArray -Arr ((get-azurermvmsize -Location (Get-PLocation $LocationAuto)) | Select-Object -Property Name) -ListName Name
    }
    else
    {
        $VMSizeInput
    }
}


function global:New-PAzureRmVm
{
    param
    (
        $VmNameInput,
        $RgInput
    )

    if ($RgInput -eq $null)
    {
        get-cmEnumResourceGroup -RgInput $RgInput
        
    }
    
    # Start by getting the config
    

}

function global:New-PAzureRmVmConfig
{
    param
    (
        $VmNameInput,
        $PVmSizeAuto
    )
    
    if ($VmNameInput -eq $null)
    {
        Write-Output "Please enter a VmName"
        $VmNameInput = Read-Host
    }

    if ($VmNameInput.Length -lt 2) {Write-Output "Length must be at least 2 characters. Try again."; $VmNameInput = Read-Host}
    if ($VmNameInput.Length -lt 2) {Write-Output "Length must be at least 2 characters. Breaking."; Break}

    $VmConfig = new-azurermvmconfig -VMName $VmNameInput (Get-PVMSize $PVmSizeAuto) 

}


#Set-AzureRmVMOperatingSystem -VM $VmConfig -ComputerName -Windows -Credential $Cred
function global:Set-PAzureRmVMOperatingSystem
{
    Param
    (
        $VmInput,
        $ComputerNameInput,
        $CredentialInput
    )

    if ($VmInput -eq $null) {New-PAzureRmVmConfig -VmNameInput $ComputerNameInput -PVmSizeAuto $VmSize}
    if (CredentialInput -eq $null) {Get-Credential }

    Set-AzureRmVMOperatingSystem -VM $VmInput -ComputerName $ComputerNameInput -Credential $CredentialInput -Windows
    
}

#get-cmEnumArray -Arr (Get-AzureRmVMImagePublisher -Location (Get-PLocation $Location)) -ListName PublisherName
function global:Get-PAzureRmVmImagePublisher
{
    param
    (
        $LocationInput,
        $PublisherNameInput
    )
    if ($PublisherNameInput -ne $null)
    {
        $PublisherNameInput
    }
    else
    {
        if ($LocationInput -eq $null) {$LocationInput = (Get-PLocation $LocationInput)}
        get-cmEnumArray -Arr (Get-AzureRmVMImagePublisher -Location $LocationInput) -ListName PublisherName
    }
}