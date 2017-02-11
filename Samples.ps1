# The name property is aliased to ComputerName as Get-Service the parameter that supports the pipeline input
get-adcomputer -filter * | Select -Property @{name='ComputerName';expression={$_.name}} | Get-Service -name BITS

# for when you need string of names
Get-WmiObject -Class win32_bios -ComputerName (Get-ADComputer -filter * ).name

# run across single computer remotely
Enter-PSSession -ComputerName PCNameHere

# run across multiple computers
Invoke-Command -ComputerName dc, s1, s2 {Get-EventLog -LogName System -Newest 3}

New-SelfSignedCertificate
Get-PSDrive
# recursive search of Certificate drive
dir Cert:\CurrentUser -Recurse -CodeSigningCert -OutVariable a  # -CodeSigningCert is not documented and does not work on my System even though it doesn't error out.
# now I can use $a to access
$a
get-executionPolicy
# returned RemoteSigned
Set-ExecutionPolicy "allsigned"
# try to run unsigned script for hello world test
.\TEst.ps1
#Display contents of Test.ps1 (either of the two lines below)
cat .\Test.ps1
Get-Content .\Test.ps1
Set-AuthenticodeSignature

#cert
New-SelfSignedCertificate

#Using example #4 from New-SelfSignedCertificate
New-SelfSignedCertificate -Type Custom -Subject "CN=Clifford MacKay" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2","2.5.29.17={text}upn=cliff@wws5.com") -KeyUsage DigitalSignature -KeyAlgorithm RSA -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My"

  Get-WmiObject win32_logicaldisk -Filter "DeviceID='c:'"
  # do some math on freespace
  Get-WmiObject win32_logicaldisk -Filter "DeviceID='c:'" | select @{n='freegb';e={$_.freespace / 1gb -as [int]}}

  # [CmdLetBinding()]  # enables parameter attributes
  [Parameter(Mandaroty=$True)] # to make parameter manditory
  [string{}]$ComputerName

  #Help comments
  <#
  .Synopsis
  This is the short expenation
  .Description This is the long description
  .Parameter ComputerName
  This is for remote computers
  .Example
  DiskIndo -computername remote
  This is for a remote computer
  #>

  # CTRL+J for cmdlet snippets
  . .\ReadXMLTest.ps1  # This allows the variables and functions not to be tossed. dot source is the name of the technique

  #----- ----- ----- ----- -----
  #Modules are next

# this allows you to import module
Import-Module .\RDSHDemo.ps1 -Force -Verbose

# use this to dynamically get paths that modules will automotically load from
cat Env:\PSModulePath
# better way to write it
$env:PSModulePath -split ";"

#use the path that starts with users\username. Create the path
# Make sure you put a folder with same name as module, then the file with .psm1 extention

#pipe to clip to send output to the clipboard
"Hello World" | clip

process to find previous commands that have hel in them (For use in command line)
#hel[tab]

#Get a list of preference variables
dir variable:*pref*

#cmdletbinding stuff needed for should process functionality and impact
Function set-stuff{
    [cmdletbinding(SupportsShouldProcess=$True, confirmImpact='Medium')
    param( ...)
    Process {
        if ($psCmdlet.ShouldProcess("$Computername","MESS IT UP SERIOUSLY") {
            Write-Output 'Im changing something right now'
        }
    }

# Getting access to Windward Registry Keys, and values
Get-ChildItem -path 'HKCU:\SOFTWARE\Windward\System Five\' | Select-Object #Name and Property. I should check out the view to see how they did the name to just c:\...
Get-ChildItem -path 'HKCU:\SOFTWARE\Windward\System Five\' | Select-Object -ExpandProperty Property #show the properties (property names)
Get-ChildItem -path 'HKCU:\SOFTWARE\Windward\System Five\' | Select-Object {$_.GetValue("")} #Get company names
Get-ChildItem -path 'HKCU:\SOFTWARE\Windward\System Five\' | Select-Object {$_.Name}
Get-ChildItem -path "HKCU:\SOFTWARE\Windward\System Five\" | Select-Object {$_.Name.Substring(48)} #Get just the path to the data

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwsWMawnZ3BgWJXNVF+HqkZb1
# DeigggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
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
# FK79VuLa9Ze43FYPH8BZhWRnZHW6MA0GCSqGSIb3DQEBAQUABIGANkBlgx5XdMYo
# I4RjlIEe71y3OX9zE9R2NpCKvhtMDLpulqPnVLNOK+bAdMI4jX/N7Qve/WW/aciA
# rP/r1hfFv4cAdI9tMDMBmWawownRCenaI6MArJeWFEZ81/WhtRDIwpqbej5mikPc
# GZQ2rnZmVFL382IDatjnz4qZtyXlDOM=
# SIG # End signature block
