Write-Output "Press Y to login, or enter to continue"
if((Read-Host) -eq "Y"){ Login-azurermaccount -SubscriptionName "VSE MPN" }

# Track settings
    $H = New-Object hashtable
<<<<<<< HEAD
    $H."ResourceGroup.Name" = "cmRds2017"
    $H."Location"
=======
    $H."RootName" = "Rds"
    $H."ResourceGroup.Name" = "cm" + $H."RootName" + "2017"
    $H."Location" = "westus2"
    $H."Storage.i" = 0
>>>>>>> origin/master

# Create a resource group
<#        
    Get-AzureRmResourceGroup # display all resource groups in my subscription
    get-command *resourcegroup*
    Get-Help Find-AzureRmResourceGroup -full
    Find-AzureRmResourceGroup | Get-Member
#> 

<#
.Synopsis
   Prepares a resource group using a global hashtable of $H ($Hash overrides $H if passed in as a parameter)
.DESCRIPTION
   Prep-ResourceGroup uses my shortcut for variable names. Maybe creating a code snipped that drops the standard names in would be better. $Hash overrides $H if passed in as a parameter
.EXAMPLE
   $H = New-Object hashtable
   $H.'ResourceGroupName.Name' = "myResourceGroupName"
   $H.'Location' = "westus2"
   $RG = Prep-ResourceGroup
.EXAMPLE
   $Hash2 = @{"ResourceGroupName.Name"="myResourceGroupName"}
   $Hash2."Location" = "westus2"
   $RG = Prep-ResourceGroup -Hash $Hash2
.INPUTS
   $H is a global hashtable that will be used if the $Hash hashtable is not submitted
   $Hash overrides $H if passed in as a parameter
#>       
function Create-ResourceGroup ([hashtable]$Hash) # $Hash overrides $H if passed in as a parameter
{   
    if ($Hash -eq $null) {$Hash = $H}; if ($Hash -eq $null) { throw "hashtable `$H with .'ResourceGroup.Name', and .'Location' required" }
    $RG =  Get-AzureRmResourceGroup | where {$_.ResourceGroupName -eq $Hash.'ResourceGroup.Name'} # Returns $null if it doesn't find the resource group
    if ($RG -eq $null) { $RG = New-AzureRmResourceGroup -Name $Hash.'ResourceGroup.Name' -Location $Hash.Location } # if resource group doesn't exist make a new one

    # did the resource group Create successfully
    Get-AzureRmResourceGroup $Hash.'ResourceGroup.Name' # This will create a terminating error if the resource group doesn't exist
    $RG # returns this variable
}
$RG = Create-ResourceGroup

<#
.Synopsis
   Prepare for ResourceGroup interactions
.DESCRIPTION
   The idea of this function is to do things like identifying and confirming that the appropriate variables are set up for use in the Create-ResourceGroup
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Prep-ResourceGroup
{
    
}

# Create a storage account, an OS Disk, and attach it to the VM $Vm
<#
.Synopsis
   Prepares a Storage account and attaches is to the VM
.DESCRIPTION
   Prepares a Storage account and attaches is to the VM
.EXAMPLE
   Prep-Storage -BlobPath ($H."Storage.Dir" + "/" + $H."Storage.Name" + $H."Storage.DiskType" + $H."Storage.i" + ".vhd")
.INPUTS
   Global Input: $H as hashtable, $Vm as PSVirtualMachine from *-AzureRmVm cmdlets
   $H keys used: "Storage.Name", "Storage.SkuName", "OsDistUri", "OsDisk.Name"
.OUTPUTS
   $StorageAccount
#>
function Create-Storage ($BlobPath = ("vhds" + "/" + $H."RootName" + "OsDisk" + $H."Storage.i" + ".vhd") )
{

    # I do want to use a naming convention for the disks
    $H."Vm.Name" = $H."RootName" + "Vm"
    $H.'Storage.i'++
 
    $H."BlobPath" = $BlobPath

    # Create a storage account
    $H."Storage.Name" = $H."RootName" + "StorageAcct"
    $H.'Storage.Name' = $H.'Storage.Name'.ToLower()
    $H."Storage.SkuName" = "Premium_LRS" #Standard_LRS
    #Get-AzureRmStorageAccountNameAvailability $StorageName
    $goodName = Get-AzureRmStorageAccountNameAvailability $H.'Storage.Name'
    write-host "$goodName.NameAvailable = """ + $goodName.NameAvailable
    Start-Sleep 5
    if ($goodName.NameAvailable)
    {
        $StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $H.RGName -Name $H.'Storage.Name' -Kind Storage -Location $H.Location -SkuName $H.'Storage.SkuName'
    }
    else
    {
        $StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $H.RGName -Name $H.'Storage.Name'
    }

    $StorageAccount
}
Create-Storage -BlobPath ($H."Storage.Dir" + "/" + $H."Storage.Name" + $H."Storage.DiskType" + $H."Storage.i" + ".vhd")

<<<<<<< HEAD
# (Resource Group) Create an affinity group is the classic way, but the resource group replaces this. Won't be creating an affinity group

# Create a new Windows Azure Storage Account


=======
function Create-OsDisk # Attach the OsDisk to a VM
{
    # Global Inputs: $Vm as PSVirtualMachine
    # $H keys: "OsDisk.VhdUri", "OsDisk.Name"
    # Create an OS Disk
    $H."OsDisk.VhdUri" = $StorageAccount.PrimaryEndpoints.Blob.ToString() + $H.BlobPath
    $H."OsDisk.Name" = $H."RootName" + "OsDisk"
    # Attach an OS Disk to a VM
    $VM = Set-AzureRmVMOSDisk -VM $Vm -Name $H.'OsDisk.Name' -VhdUri $H."OsDisk.VhdUri" -CreateOption FromImage
}
>>>>>>> origin/master

# So, after doing all this work with these functions using the hashtable I think the next step is to properly create the functions passing arguments.
#   I think the snippets could be used to automate the passing in of arguments to avoid typing.
#   The cool thing about this style is that early on, while building the code could still use the nested function style to organize sections of code allowing for readability.
#   There would be no need to make the function have proper structure or explain inputs etc. except for the most basic of comments ex: a list of $H keys used
#   This is just another natural progression of the code, this way though other people that I share the code with can use it their standard way instead of getting stuck with the hashtable style


