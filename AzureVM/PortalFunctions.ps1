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


<#
.Synopsis
   Enumerate strings
.DESCRIPTION
   Enumerate strings
.EXAMPLE
   Example of how to use this cmdletget
.EXAMPLE
   Another example of how to use this cmdlet
#>
function global:Enum-String
{
    [CmdletBinding()]
    [Alias("E-S")]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $Name
    )

    Begin
    {
        $Arr = New-Object System.Collections.ArrayList
        $i = 0
    }
    Process
    {
        $T = $Arr.Add(" " + $i + " " + $Name)
        $i++        
    }
    End
    {
        $Arr
    }
}


<#
.Synopsis
   Get the nth Item
.DESCRIPTION
   Get the nth Item
.EXAMPLE
   Example of how to use this cmdletget
.EXAMPLE
   Another example of how to use this cmdlet
#>
function global:get-nthItem
{
    [CmdletBinding()]
    [Alias("E-S")]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $Name
    )

    Begin
    {
        $Arr = New-Object System.Collections.ArrayList
        $i = 0
    }
    Process
    {
        $T = $Arr.Add(" " + $i + " " + $Name)
        $i++        
    }
    End
    {
        $Arr
    }
}


<#
.Synopsis
   Enumerate strings
.DESCRIPTION
   Enumerate strings
.EXAMPLE
   Get-AzureRmVMImagePublisher -Location "westus2" | Select-Object -expandProperty PublisherName | Enum-String | Format-Columnnize -ColumnNum 3
.EXAMPLE
    $Array1 = "One", "Two", "Three", "Four", "Five", "Six", "Seven"
    $Array1 | Enum-String | Format-Columnnize -ColumnNum 3
Results:
    Col0     Col1    Col2    
    ----     ----    ----    
     0 One    1 Two   2 Three
     3 Four   4 Five  5 Six  
     6 Seven                 
#>
function global:Format-Columnnize
{
    [CmdletBinding()]
    [Alias("F-C")]
    [OutputType([string])]
    Param
    (
        # Name is the default column to match by for piping
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [String]
        $Name,

        # ColumnNum is the number of columns you want to use in the table
        [Parameter(Mandatory=$true,
                   Position=0)]
        $ColumnNum

    )

    Begin
    {
        $Arr = New-Object System.Collections.ArrayList
        $Row = New-Object psobject
        $i = 0
        $i2 = 0
    }
    Process
    {
        if ($i2 -ge $ColumnNum) 
        {
            $i2 = 0
            $T = $Arr.Add($Row)
            $Row = New-Object psobject
        }
        Add-Member -InputObject $Row -MemberType NoteProperty -Name "Col$i2" -Value $Name
        $i2++
        $i++        
    }
    End
    {
        While ($i2 -lt $ColumnNum)
        {
            Add-Member -InputObject $Row -MemberType NoteProperty -Name "Col$i2" -Value ""
            $i2++
        }
        if ($i2 = $ColumnNum) 
        { 
            $T = $Arr.Add($Row)
        }
        $Arr
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


<#
function global:Get-PLocation # Gets the location as the portal would
{
    [OutputType([string])]
    param
    (
        [ref]$LocationInput
    )
    [string]$Loc = $LocationInput.Value
    if ($Loc -eq $null) # Null won't happen due to ref type, but leaving it in, incase we change things
    {
        $Loc = get-cmEnumArray -Arr (get-AzureRmLocation | Select-Object -Property Location) -ListName Location
    }
    elseif ($Loc.Length -eq 0)
    {
        $Loc = get-cmEnumArray -Arr (get-AzureRmLocation | Select-Object -Property Location) -ListName Location
    }
    $Loc
    $LocationInput.Value = $Loc
}
#>


function global:Get-PLocation # Gets the location as the portal would
{
    [OutputType([string])]
    param
    (
        $LocationInput
    )

    if ($LocationInput -eq $null) # Null won't happen due to ref type, but leaving it in, incase we change things
    {
        $LocationInput = get-cmEnumArray -Arr (get-AzureRmLocation | Select-Object -Property Location) -ListName Location
    }
    elseif ($LocationInput.Length -eq 0)
    {
        $LocationInput = get-cmEnumArray -Arr (get-AzureRmLocation | Select-Object -Property Location) -ListName Location
    }
    $LocationInput
}


function global:Get-PVMSize # Gets the VMSize as the portal would
{
    [OutputType([string])]
    param
    (
        $VMSizePassThru, 
        $LocationAuto
    )
    if ($VMSizePassThru -eq $null)
    {
        $VMSizePassThru = get-cmEnumArray -Arr ((get-azurermvmsize -Location (Get-PLocation $LocationAuto)) | Select-Object -Property Name) -ListName Name
    }
    elseif ($VMSizePassThru.Length -eq 0)
    {
        $VMSizePassThru = get-cmEnumArray -Arr ((get-azurermvmsize -Location (Get-PLocation $LocationAuto)) | Select-Object -Property Name) -ListName Name
    }
    $VMSizePassThru
}


function global:New-PAzureRmVm
{
    param
    (
        $VmNameInput,
        $RgPassThru
    )

    if ($RgPassThru -eq $null)
    {
        get-cmEnumResourceGroup -RgInput $RgPassThru
    }
    elseif($RgPassThru.GetType() -ne "Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.PSResourceGroup")
    {
        get-cmEnumResourceGroup -RgInput $RgPassThru
    }
    
    if ($VmNameInput -eq $null)
    {
        $VmNameInput = Read-Host "Enter the VM Name"
    }
    elseif ($VmNameInput.length -eq 0)
    {
        $VmNameInput = Read-Host "Enter the VM Name"
    }

    # Start by getting the config
    $VmCfg = New-PAzureRmVm -VmNameInput $VmNameInput -RgPassThru $RgPassThru

    $VmCfg = Set-PAzureRmVMOperatingSystem -VmInput $VmCfg -ComputerNameInput $VmNameInput
    

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

    $VmConfig = new-azurermvmconfig -VMName $VmNameInput (Get-PVMSize ([ref]$PVmSizeAuto)) 

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
        $PublisherNamePassThru,
        $LocationAuto
    )
    if ($PublisherNamePassThru -ne $null)
    {
        $PublisherNamePassThru
    }
    else
    {
        if ($LocationInput -eq $null) {$LocationInput = (Get-PLocation $LocationAuto)}
        get-cmEnumArray -Arr (Get-AzureRmVMImagePublisher -Location $LocationAuto) -ListName PublisherName
    }
}