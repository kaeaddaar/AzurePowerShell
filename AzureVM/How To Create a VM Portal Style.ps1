$HSetting = @{"VmName"="TestVm1"}
$HSetting | Add-Member-MakeKeyScript


# This function handles the displaying of an enumerated list, selecting an option, and saving it to the setting Hash
Function Get-PropFromColObj
{
    Param
    (
        $ColObj,
        $HashSetting,
        $ExpandProperty,
        $NumColumns
    )
    if ($Hash.Location.Length -eq 0)
    {
        ($lstTemp = Get-AzureRmLocation | Select-Object -ExpandProperty $ExpandProperty) | Enum-String | Format-Columnnize $NumColumns
        Read-Host "Press any key to see list of locations"
        $HashSetting."$ExpandProperty" = $lstTemp.Item((READ-host "Select number of a $ExpandProperty"))
    }
}


# Sample use of get-PropFromColObj function
Get-PropFromColObj -ColObj get-azureRMLocation -Hash $HSetting -ExpandProperty "Location" -NumColumns 3

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

Prep-AzureRmVmConfig $HSetting