$sleep = 2
write-host "01-Logon"
Start-Sleep $sleep

# enter your logon info
Login-AzureRmAccount -SubscriptionName "Visual Studio Enterprise – MPN"
$colRG = Get-AzureRmResourceGroup | Select-Object -Property ResourceGroupName, Location
write-host "----- Enumeration of Resource Groups -----"

$EnumRG = -1

# Enumerate the resource Group
for($i=0; $i -le $colRG.Count; $i++)
{
$RG = $colRG[$i]
write-host $i, $RG.ResourceGroupName
}

write-host ""
write-host "Enter the number of the resource group you would like to select."
$RGNum = Read-Host
$RGName = $colRG[$RGNum].ResourceGroupName

# Loop through resources in a ResourceGroup
write-host "02-Show contents of $RGName"
Start-Sleep $sleep

$EnumRG = -1
# $listRG = Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq "cmTestRG01" } | Select-Object -Property Name, ResourceType
$listRG = Get-AzureRmResource | Where-Object {$colRG[$RGNum] } | Select-Object -Property Name, ResourceType
foreach ($RG in $listRG  | Where-Object {$_.ResourceType -eq "Microsoft.Compute/virtualMachines"})
{
$EnumRG = $EnumRG + 1

Write-Host $EnumRG $RG.Name ($RG.ResourceType)
}

Write-Host Please input a number
$Result = Read-Host
$RG = $listRG[$Result]
write-host $RG.Name
write-host Done


