Login-AzureRmAccount -SubscriptionName "VSE MPN"
start-azurermvm -Name "DevApi" -ResourceGroupName "DevApi_Test"

Stop-azurermvm -Name "DevApi" -ResourceGroupName "DevApi_Test"


