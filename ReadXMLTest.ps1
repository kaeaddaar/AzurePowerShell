
$sleep = 2
write-host "Enter Y if you would like to enter your credentials, or hit ENTER to continue"
$LogonAgain = Read-Host

if($LogonAgain -eq "Y")
{
# enter your logon info
Login-AzureRmAccount -SubscriptionName "Visual Studio Enterprise – MPN"
}

$colRG = Get-AzureRmResourceGroup | Select-Object -Property ResourceGroupName, Location
$path = "C:\Users\playi\OneDrive\Documents\Settings.XML"

[xml]$Settings = Get-Content $path
[System.Xml.XmlNodeList]$NodeList = $Settings.GetElementsByTagName("Setting")
$SettingValue = ""

getSettingValue "TestSetting2"
write-host $SettingValue

function getSettingValue ([string] $SettingName = "TestSetting")
{
    foreach ($Node in $NodeList)
    {
        [System.Xml.XmlElement]$Elem = $Node
        if($Elem.Id -eq $SettingName)
        {
            $SettingValue = $Elem.InnerText
        }
    }
    $SettingValue
}

