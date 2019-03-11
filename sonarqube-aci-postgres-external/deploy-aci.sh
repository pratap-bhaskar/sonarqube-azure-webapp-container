ACI_RESOURCE_GROUP=sonaraci
LOCATION=southeastasia
ACI_STORAGE_ACCOUNT=sonaraci
ACI_FILE_SHARE=sonarqube
ACI_POSTGRES_NAME=sonarqubeaci
ACI_POSTGRES_USERNAME=sonar
ACI_POSTGRES_PASSWORD='Warhorse!23'


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
# Deploy postgres db 
az postgres server create \
    --resource-group $ACI_RESOURCE_GROUP \
    --name $ACI_POSTGRES_NAME \
    --location $LOCATION \
    --admin-user $ACI_POSTGRES_USERNAME \
    --admin-password $ACI_POSTGRES_PASSWORD \
    --sku B_Gen5_1

az postgres db create \
    --name sonar \
    --resource-group $ACI_RESOURCE_GROUP \
    --server-name $ACI_POSTGRES_NAME

az postgres server firewall-rule create \
    --name allAzureIPs \
    --server $ACI_POSTGRES_NAME \
    --resource-group $ACI_RESOURCE_GROUP \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0
# SSL is not supported by ACI instance of docker
az postgres server update --resource-group $ACI_RESOURCE_GROUP --name $ACI_POSTGRES_NAME --ssl-enforcement Disabled

#Deploy arm template for Sonarqube
az group deployment create --name sonarqube --resource-group $ACI_RESOURCE_GROUP \
    --template-file dockeraci.json \
    --parameters storageAccountName=$ACI_STORAGE_ACCOUNT postgresServerName=$ACI_POSTGRES_NAME postgresPassword=$ACI_POSTGRES_PASSWORD

