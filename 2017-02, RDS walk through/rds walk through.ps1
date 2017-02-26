Write-Output "Press Y to login, or enter to continue"
if((Read-Host) -eq "Y"){ Login-azurermaccount -SubscriptionName "VSE MPN" }

# Track settings
    $H = New-Object hashtable
    $H."ResourceGroup.Name" = "cmRds2017"
    $H."Location"
    $H."AffinityGroup.Name" = $H.'ResourceGroup.Name' + "AG"

# Create a resource group
    $H."ResourceGroup.Name" = "cmRds2017"
    $H."Location" = "westus2"
    # does the resource group exist
<#        
    Get-AzureRmResourceGroup # display all resource groups in my subscription
    get-command *resourcegroup*
    Get-Help Find-AzureRmResourceGroup -full
    Find-AzureRmResourceGroup | Get-Member
#>        
    $RG =  Get-AzureRmResourceGroup | where {$_.ResourceGroupName -eq $H.'ResourceGroup.Name'} # Returns $null if it doesn't find the resource group
    if ($RG -eq $null) { $RG = New-AzureRmResourceGroup -Name $H.'ResourceGroup.Name' -Location $H.Location } # if resource group doesn't exist make a new one

    # did the resource group Create successfully
    Get-AzureRmResourceGroup $H.'ResourceGroup.Name' # This will create a terminating error if the resource group doesn't exist

# Create an affinity group is the classic way, but the resource group replaces this



