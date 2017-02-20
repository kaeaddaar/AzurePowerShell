
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


# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkiOmVuQSJ4AHkPr3KP58p6SY
# duKgggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNzAyMDkxNzU3NDBaFw0zOTEyMzEyMzU5NTlaMBoxGDAWBgNVBAMTD1Bvd2Vy
# U2hlbGwgVXNlcjCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAxJMXSX2yDza4
# YoV7fYGLG+XE5KuXS17haubcZNNb85RbiguXlg8mOViEUalyEcEPdY5xfR1b62K7
# Jt3J82RlEfwnVtmin5EXW3hYOYRP87U/pkKiq1MHULcmKO2kReTQmMtJB7Lw7HMB
# g7bsaQzkOqzbgL38cMaowb/Kjo+VR+MCAwEAAaN2MHQwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwXQYDVR0BBFYwVIAQO7kzIfSp327hSz/mt29jcKEuMCwxKjAoBgNVBAMT
# IVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdIIQrgjaQlc+9IhF3X9o
# nylYgTAJBgUrDgMCHQUAA4GBAAy7KZBYUA9VbxygZSoCQVZnjgDjcu5tmHnWxqhD
# OS2ZuMoMH38IO1D9fgqc2dvSANyVtvZ9KLPZcBvbos1yprogGvAIHZ5S2LEHvE1f
# cB8ygMkqEmCddMeT7nJx0rU5wUaG8FMB44nA676kC33HIabLVc1CQq7oU0JbR5BO
# j8IcMYIBYDCCAVwCAQEwQDAsMSowKAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENl
# cnRpZmljYXRlIFJvb3QCEF6p4BzLRSWQS77SgeZDGJswCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FKLhUd8KmpFUOUP1clKNhfwr9spRMA0GCSqGSIb3DQEBAQUABIGAmYXHEXz51zBl
# jpuTyRfe9nce02h3YK3QjxkKWVry+fHVjLwBCAFo9R+2GGi5lhpig1j5j+SdW1fM
# uZbmLXC0X6g8z7BUssL8QnV2WnMNYCikFEhi4x+dUVeUtcdqoabXTIZiTlhjyiuc
# 1oU98dhVjWcSTBCaCBEjMRKMxKMS3P8=
# SIG # End signature block
