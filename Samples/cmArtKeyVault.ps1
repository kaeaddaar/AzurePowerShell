if ($LoggedIn -ne $true) { Login-AzureRmAccount }
if ($LoggedIn -ne $true) { Import-Module .\AzurePowerShell\AzureVM\PortalFunctionality.psm1 }
$LoggedIn = $true

$List = Get-AzureKeyVaultSecret -VaultName cmArtKeyVault | Select-Object -Property "Name"

$list | Enum-String

$VaultName = "cmartkeyvault"
$Num = Read-Host -Prompt "Select number of item to view, or choose A to add"
if ($Num -eq "A")
{
    $NewName = Read-Host -Prompt "Choose a new name to Add"
    $Secret =  Get-AzureKeyVaultKey -VaultName $VaultName | where {$_.Name -eq $NewName}
    if ($Secret -ne $null)
    {
        Write-Host "failed"
    }
    else
    {
        $SecretValue = Read-Host "Enter your secret"
        (Set-AzureKeyVaultSecret -VaultName $VaultName -Name $NewName -SecretValue (ConvertTo-SecureString $SecretValue -AsPlainText -Force))
    }
}
else
{
    (Get-AzureKeyVaultSecret -VaultName $VaultName -Name ($List[$Num]).Name).SecretValueText
}

#----- sample of how to get null when item doesn't exist in collection-----
#    $RG =  Get-AzureRmResourceGroup | where {$_.ResourceGroupName -eq $Hash.'ResourceGroup.Name'} # Returns $null if it doesn't find the resource group
#    if ($RG -eq $null) { $RG = New-AzureRmResourceGroup -Name $Hash.'ResourceGroup.Name' -Location $Hash.Location } # if resource group doesn't exist make a new one
