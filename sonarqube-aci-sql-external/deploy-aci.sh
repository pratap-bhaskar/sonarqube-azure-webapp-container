ACI_RESOURCE_GROUP=sonaraci
LOCATION=southeastasia
ACI_STORAGE_ACCOUNT=sonaraci
ACI_FILE_SHARE=sonarqube
ACI_SQL_SERVER=sonarqubeaci
ACI_SQL_USERNAME=sonar
ACI_SQL_PASSWORD='Warhorse!23'


az group create -n $ACI_RESOURCE_GROUP --location $LOCATION 
# Create the storage account for fileshare
az storage account create \
    --name $ACI_STORAGE_ACCOUNT \
    --resource-group $ACI_RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS
# Create the file share for sonar
az storage share create --name sonarqubeconf --account-name $ACI_STORAGE_ACCOUNT
az storage share create --name sonarqubedata --account-name $ACI_STORAGE_ACCOUNT
az storage share create --name sonarqubelogs --account-name $ACI_STORAGE_ACCOUNT
az storage share create --name sonarqubeextensions --account-name $ACI_STORAGE_ACCOUNT
# Deploy sql db 
az sql server create \
    --resource-group $ACI_RESOURCE_GROUP \
    --name $ACI_SQL_SERVER \
    --location $LOCATION \
    --admin-user $ACI_SQL_USERNAME \
    --admin-password $ACI_SQL_PASSWORD

az sql db create \
    --name sonar \
    --resource-group $ACI_RESOURCE_GROUP \
    --server $ACI_SQL_SERVER \
    --service-objective S0 \
    --collation SQL_Latin1_General_CP1_CS_AS

az sql server firewall-rule create \
    --name allAzureIPs \
    --server $ACI_SQL_SERVER \
    --resource-group $ACI_RESOURCE_GROUP \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

#Deploy arm template for Sonarqube
az group deployment create --name sonarqube --resource-group $ACI_RESOURCE_GROUP \
    --template-file dockeraci.json \
    --parameters storageAccountName=$ACI_STORAGE_ACCOUNT sqlServerName=$ACI_SQL_SERVER sqlPassword=$ACI_SQL_PASSWORD

