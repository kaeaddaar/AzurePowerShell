<#

#>

<#
.Synopsis
   Enumerate strings
.DESCRIPTION
   Enumerate strings
.EXAMPLE
   $lstImagePublisher | Enum-String
.EXAMPLE
   The following example shows how to get locations into a list of locations and output it in columns
($lstLocation = Get-AzureRmlocation | Select-Object -ExpandProperty Location) | Enum-String| Format-Columnnize 3
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
   Get the nth Item from piped objects
.DESCRIPTION
   Get the nth Item from piped objects
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function global:get-nthItem
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [Object]
        $Obj,

        [Parameter(Mandatory=$true,
                   Position=0)]
        [Int]
        $Position
    )

    Begin
    {
        $i = 0
    }
    Process
    {
        if ($i -eq $Position)
        {
            $obj
        }
        $i++        
    }
    End
    {
        
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


# This function handles the displaying of an enumerated list, selecting an option, and saving it to the setting Hash
Function Get-PropFromColObj
{
    Param
    (
        $ColObj,
        $HashSetting,
        $ExpandProperty,
        $NumColumns = 2
    )
    if ($Hash.Location.Length -eq 0)
    {
        ($lstTemp = $ColObj | Select-Object -ExpandProperty $ExpandProperty) | Enum-String | Format-Columnnize $NumColumns
        Read-Host "Press any key to see list of locations"
        $HashSetting.$ExpandProperty = $lstTemp.Item((READ-host "Select number of a $ExpandProperty"))
    }
}

<#
# Sample use of get-PropFromColObj function
Get-PropFromColObj -ColObj get-azureRMLocation -Hash $HSetting -ExpandProperty "Location" -NumColumns 3
#>

function Prep-AzureRmVmConfig
{
    Param
    (
        $HashSetting
    )

    # Need VmName, VmSize, Location
    "VmName", "Location", "VmSize" | Make-Key -Obj $HashSetting
    Get-PropFromColObj -ColObj (Get-Location) -Hash $HashSetting -ExpandProperty "Location" -NumColumns 4
    Get-PropFromColObj -ColObj (Get-AzureRmVMSize -Location $HashSetting.Location) -Hash $HashSetting -ExpandProperty "Name" -NumColumns 4
    $HashSetting
}
