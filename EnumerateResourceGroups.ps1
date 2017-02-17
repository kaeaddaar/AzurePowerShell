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



# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4gyFEtqQrHkYB3Oo89GUF0QL
# GrKgggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
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
# FI+6iasVIC8u8UaZlHIYT1FkU6R7MA0GCSqGSIb3DQEBAQUABIGAgGZgK2p3XRus
# jzCxVG/M6a56bnGXkF0TAsGWa+nOpB3BL+djeSWkUcS4CMzDQ0eWUY9gnCAEdGA0
# L67KFXIYzm9/enacX0QISLJLsnswe9jQNc/FyyjVODNxGM8z5OwByOYLmyRtuH+R
# +Wp6e95RMKo1KZP2pYH9CDWryj75bes=
# SIG # End signature block
