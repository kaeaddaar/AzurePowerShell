$Array1 = "One", "Two", "Three", "Four", "Five", "Six", "Seven"
$Array1 | Enum-String | Format-Columnnize -ColumnNum 3

$lstImagePublisher = Get-AzureRmVMImagePublisher -Location "westus2" | Select-Object -expandProperty PublisherName
$lstImagePublisher | Enum-String | Format-Columnnize 3
$intImagePublisher = Read-Host "Pick image publisher from list"
$lstImagePublisher[$intImagePublisher]
cls

# Get the location list
$lstLocation = Get-AzureRmlocation | Select-Object -ExpandProperty Location
# Display the location list
$lstLocation | Enum-String | Format-Columnnize 3
# Wrap picking in a simple function
Function get-PLocation 
{ 
    $lstLocation = Get-AzureRmlocation | Select-Object -ExpandProperty Location
    $lstLocation | Enum-String| Format-Columnnize 3
    $lstLocation.Item((Read-Host -Prompt "Enter Number of Location")).Location
}
# Place function below where you want to get the location
Write-Host "the location is" (Get-PLocation)




($lstLocation = Get-AzureRmlocation | Select-Object -ExpandProperty Location) | Enum-String| Format-Columnnize 3
$lstLocation = $null

Add-Member -InputObject $PSO -Name "test2" -MemberType ScriptMethod -Value {param ($Param1);Write-Host $this.Location + $Param1 + "stuff"} -PassThru

# Lets create a way to track settings, using the previously set settings by default
$HSettings = @{"VmName"="VmTest1"}

# I want to pass a non-blank setting, and if it doesn't exist to add it, else change the setting
# if setting is blank, we can treat things like the portal and enumerate the options

$ScriptToMakeKey = {[CmdletBinding()] param([Parameter(Mandatory=$True, ValueFromPipelineByPropertyName=$true, ValueFromPipeline=$true, Position=0)] [String]$Name)if (-not $this.ContainsKey($Name)) {$this.Add("$Name","") }}
Add-Member -InputObject $HSettings -Name "Make-Key" -MemberType ScriptMethod -Value $ScriptToMakeKey
$HSettings.'Make-Key'("Var1")
$HSettings.var1 = "Hello WOrld"

get-help Add-Member -full
$HSettings | gm

# ----- Time to write some sample code -----
$HSettings = @{"VmName"="TestVm1"}
$HSettings | Add-Member-MakeKeyScript

# Location is needed for Get-AzureRmVmImagePublisher
$HSettings.'Make-Key'("Location")
#if location is blank, grab locations from azure
if ($HSettings.Location.Length -eq 0)
{
    ($lstLocation = Get-AzureRmLocation | Select-Object -ExpandProperty Location) | Enum-String | Format-Columnnize 3
    Read-Host "Press any key to see list of locations"
    $HSettings.Location = $lstLocation.Item((READ-host "Select number of a location"))
}
$HSettings.Location

