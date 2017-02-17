        $Input = @{
            "FrontEndIpName" = "cmPsFrontEndIp"
            "FrontEndPrivateIp" = "10.0.0.5"
            "BackEndIpName" = "cmPsBackEndIp"
            "InboundNatRuleName1" = "cmPsInboundNatRdp1"
            "Inbound1FrontPort" = 3441
            "InboundNatRuleName2" = "cmPsInboundNatRdp2"
            "Inbound2FrontPort" = 3442
            "BackEndPort" = 3389
            "InboundProtocol" = "Tcp"
            "HealthProbeName" = "cmPsHealthProbe"
            "HealthProbeRequestPath" = "./"
            "HealthProbeProtocol" = "http"
            "HealthProbePort" = 80
            "HealthProbeIntervalInSeconds" = 15
            "HealthProbeProbeCount" = 2
            "LoadBalanceRuleName" = "cmPsLoadBalanceRule"
            "LoadBalanceProtocol" = "Tcp"
            "LoadBalanceFrontEndPort" = 80
            "LoadBalanceBackEndPort" = 80
            "BackEndNic1Name" = "cmpsbackendnic1"
            "BackEndPrivateIp1" = "10.0.0.6"
            "BackEndNic2Name" = "cmpsbackendnic2"
            "BackEndPrivateIp2" = "10.0.0.7"
            }

# SIG # Begin signature block
# MIIEMwYJKoZIhvcNAQcCoIIEJDCCBCACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrYP2EeFK5Feg5DHr4ohGQIQi
# 9figggI9MIICOTCCAaagAwIBAgIQXqngHMtFJZBLvtKB5kMYmzAJBgUrDgMCHQUA
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
# FFsc7tHLiEttc4cTU+Ip3oheoxa+MA0GCSqGSIb3DQEBAQUABIGAR2X/YK5S9XwS
# Ws1SRivVdIgFvH3mFCyfAn89/PRgyv6jSN4GvNLUukGVA/ff/sMt0x/lfbd7OWk+
# oitpag/ELD46QtYEuhGHFAtjjCA6/Y1BoN5tNKtp8MPla58Gp8asv1uuH4IN3CCg
# U1Fou3Gz2voKJz7fdDXiiW8taEjlIZM=
# SIG # End signature block
