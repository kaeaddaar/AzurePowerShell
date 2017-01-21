#Requires -RunAsAdministrator
 Param (
 [Parameter(Mandatory=$true)]
 [String] $ResourceGroup,

 [Parameter(Mandatory=$true)]
 [String] $AutomationAccountName,

 [Parameter(Mandatory=$true)]
 [String] $ApplicationDisplayName,

 [Parameter(Mandatory=$true)]
 [String] $SubscriptionId,

 [Parameter(Mandatory=$true)]
 [SecureString] $CertPlainPassword,

 [Parameter(Mandatory=$false)]
 [int] $NoOfMonthsUntilExpired = 12
 )
 # Sample usage of above parameters
 # .\New-AzureClassicRunAsAccount.ps1 -ResourceGroup <ResourceGroupName>
 #-AutomationAccountName <NameofAutomationAccount> `
 #-ApplicationDisplayName <DisplayNameofAutomationAccount> `
 #-SubscriptionId <SubscriptionId> `
 #-CertPlainPassword "<StrongPassword>"

 Login-AzureRmAccount
 Import-Module AzureRM.Resources
 Select-AzureRmSubscription -SubscriptionId $SubscriptionId

 #set the sleep time after comments
 $SleepTime = 3
 Write-Host "01-AfterLogon"
 Start-Sleep $SleepTime

 $CurrentDate = Get-Date
 $EndDate = $CurrentDate.AddMonths($NoOfMonthsUntilExpired)
 $KeyId = (New-Guid).Guid
 $CertPath = Join-Path $env:TEMP ($ApplicationDisplayName + ".pfx")

 Write-Host "02-After Variables set"
 Start-Sleep $SleepTime

 $Cert = New-SelfSignedCertificate -DnsName $ApplicationDisplayName -CertStoreLocation cert:\LocalMachine\My -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider"

 $CertPassword = ConvertTo-SecureString $CertPlainPassword -AsPlainText -Force
 Export-PfxCertificate -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) -FilePath $CertPath -Password $CertPassword -Force | Write-Verbose

 Write-Host "03-After Cert pwd before PFX Cert"
 Start-Sleep $SleepTime


 $PFXCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList @($CertPath, $CertPlainPassword)
 $KeyValue = [System.Convert]::ToBase64String($PFXCert.GetRawCertData())

 Write-Host "04-Before KeyCredential"
 Start-Sleep $SleepTime

 $KeyCredential = New-Object  Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADKeyCredential
 $KeyCredential.StartDate = $CurrentDate
 $KeyCredential.EndDate= $EndDate
 $KeyCredential.KeyId = $KeyId
 $KeyCredential.Type = "AsymmetricX509Cert"
 $KeyCredential.Usage = "Verify"
 $KeyCredential.CertValue = $KeyValue

 Write-Host "04a-Before New-AzureRmADApplication"
 Start-Sleep $SleepTime


 # Use Key credentials
 $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $KeyId) -KeyCredentials $keyCredential

 Write-Host "05-after New-AzureRmADApplication, before New-AzureRMADServicePrincipal"
 Start-Sleep $SleepTime


 New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId | Write-Verbose
 Get-AzureRmADServicePrincipal | Where-Object {$_.ApplicationId -eq $Application.ApplicationId} | Write-Verbose

 Write-Host "06-Before While Loop"
 Start-Sleep $SleepTime


 $NewRole = $null
 $Retries = 0;
 While ($NewRole -eq $null -and $Retries -le 6)
 {
    # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
    Start-Sleep 5
    New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
    Start-Sleep 10
    $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
    $Retries++;
 }

 Write-Host "07-After while loop"
 Start-Sleep $SleepTime


 # Get the tenant id for this subscription
 $SubscriptionInfo = Get-AzureRmSubscription -SubscriptionId $SubscriptionId
 $TenantID = $SubscriptionInfo | Select-Object TenantId -First 1

 Write-Host "08-before create of automation resources"
 Start-Sleep $SleepTime


 # Create the automation resources
 New-AzureRmAutomationCertificate -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccountName -Path $CertPath -Name AzureRunAsCertificate -Password $CertPassword -Exportable | write-verbose

 # Create a Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
 $ConnectionAssetName = "AzureRunAsConnection"
 Remove-AzureRmAutomationConnection -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccountName -Name $ConnectionAssetName -Force -ErrorAction SilentlyContinue
 $ConnectionFieldValues = @{"ApplicationId" = $Application.ApplicationId; "TenantId" = $TenantID.TenantId; "CertificateThumbprint" = $Cert.Thumbprint; "SubscriptionId" = $SubscriptionId}
 New-AzureRmAutomationConnection -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccountName -Name $ConnectionAssetName -ConnectionTypeName AzureServicePrincipal -ConnectionFieldValues $ConnectionFieldValues
On your computer, start Windows PowerShell from the Start screen with elevated user rights.

 Write-Host "09-Done"
 Start-Sleep $SleepTime

