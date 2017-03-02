<#
    This module has some really cool concepts in it that took me a bit to get right. I really learned some interesting things about
        adding script to objects on the fly etc.
    
    Add-Member-MakeKey-Script: pipe a bunch off hash tables into this to add the Make-Key method.
        * The Make-Key method adds a key if it doesn't exist preventing errors
        * To add a key to a hashtable the same way just use this Syntax: $H."key-name" = "Value1"

    Too bad I didn't figure out that syntax before writing this :)
#>


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


<#
.Synopsis
   Calls Make-Key on any piped object
.DESCRIPTION
   Calls Make-Key on any piped object. 
.EXAMPLE
   This example shows how to make a key on multiple objects that have the make-key property added

   $H = new-object hashtable
   "Key1", "key2", "Key3" | make-key -Obj $H
.EXAMPLE
   Another example of how to use this cmdlet

#>
function global:Make-Key
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # The name of other the hash name to be passed to the Make-Key
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidatePattern("[a-z]*")]
        $Name,
        
        #
        [ValidateNotNull()]
        [PSObject]$Obj
    )

    Begin
    {
    }
    Process
    {
        $Obj.'Make-Key'($Name,"")
    }
    End
    {
    }
}

