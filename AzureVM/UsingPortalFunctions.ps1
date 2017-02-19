$Array1 = "One", "Two", "Three", "Four", "Five", "Six", "Seven"
$Array1 | Enum-String | Format-Columnnize -ColumnNum 3

$lstImagePublisher = Get-AzureRmVMImagePublisher -Location "westus2" | Select-Object -expandProperty PublisherName
$lstImagePublisher | Enum-String | Format-Columnnize 3
$intImagePublisher = Read-Host "Pick image publisher from list"
$lstImagePublisher[$intImagePublisher]
cls

# Get the location list
$lstLocation = Get-AzureRmlocation | Select-Object -ExpandProperty Location
# Display the location list
$lstLocation | Enum-String | Format-Columnnize 3
# Wrap picking in a simple function
Function get-PLocation { $lstLocation.Item((Read-Host "Pick location from list"))}
# Place function below where you want to get the location
Write-Host "the location is" (Get-PLocation)



