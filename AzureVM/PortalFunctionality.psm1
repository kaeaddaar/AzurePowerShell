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


<#
.Synopsis
   Adds a function to a hash table
.DESCRIPTION
   Makes a key in a hash table. Supports pipeline and makes sure the key exists before we start setting them
.EXAMPLE
   $HashVar = @{"Key1"="Val1"}
   Add-Member-MakeKeyScript -Hash $HashVar
   $HashVar.'Key2' = "Val2"
   $HashVar
Results: 
Name                           Value                                                                                           
----                           -----                                                                                           
Key1                           Val1                                                                                            
Key2                           Val2                                                                                            

.EXAMPLE
   $HashVar = @{"Key1"="Val1"}
   $HashVar2 = @{"Key1"="Val1"}
   ($HashVar2, $HashVar) | Add-Member-MakeKeyScript
   $HashVar2.'Key2' = "Val2"
   $HashVar.'Key2' = "Val2"
   $HashVar2
   $HashVar
Results: 
Name                           Value                                                                                           
----                           -----                                                                                           
Key1                           Val1                                                                                            
Key2                           Val2                                                                                            
Key1                           Val1                                                                                            
Key2                           Val2                                                                                            

#>
Function global:Add-Member-MakeKeyScript
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$True, 
                     ValueFromPipelineByPropertyName=$true,
                     ValueFromPipeline=$true, 
                     Position=0)]
        [Hashtable]$Hash
    )
    Begin
    {
        $ScriptToMakeKey = {[CmdletBinding()] param([Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Position=0)] [String]$Name)if (-not $this.ContainsKey($Name)) {$this.Add("$Name","") }}
    }

    Process
    {
        if (-not(Get-Member -inputobject $Hash -name "Make-Key" -Membertype ScriptMethod))
        {
            Add-Member -InputObject $Hash -Name "Make-Key" -MemberType ScriptMethod -Value $ScriptToMakeKey
        }
    }

    End {$ScriptToMakeKey = $null}
}


