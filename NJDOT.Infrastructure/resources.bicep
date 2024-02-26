targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Base Name of Resources')
@minLength(3)
param commonResourceName string

var resourceName = toLower(commonResourceName)

var logAnalyticsName = '${resourceName}log'
var logAnalyticsSKU = 'PerGB2018'
var applicationInsightsName = '${resourceName}insights'

var storageSKU = 'Standard_LRS'
var storageAccountName = '${resourceName}sa'
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
var storageBlobDataContributorRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')

var appServicePlanWebName = '${resourceName}asp'
var appServicePlanWebAppSKU = 'S1'
var appServicePlanWebAppTier = 'Standard'

var minimalApiAppName = '${resourceName}minimalapi'
var webApiAppName = '${resourceName}webapi'
var webAppName = '${resourceName}webapp'

var appServicePlanFuncName = '${resourceName}aspserverless'
var appServicePlanFuncSKU = 'Y1'
var appServicePlanFuncTier = 'Dynamic'
var functionAppName = '${resourceName}func'

var swaSku = 'Standard'
var staticWebAppName = '${resourceName}web'

resource appServicePlanFunc 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanFuncName
  location: location
  sku: {
    name: appServicePlanFuncSKU
    tier: appServicePlanFuncTier
  }
  kind: 'functionapp'
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlanFunc.id
    siteConfig: {
      numberOfWorkers: 1
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
      netFrameworkVersion: 'v8.0'
      remoteDebuggingVersion: 'VS2022'
      managedPipelineMode: 'Integrated'
      cors: {
        allowedOrigins: ['*']
      }
    }
    httpsOnly: true
  }
}

resource appServicePlanWebApps 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanWebName
  location: location
  sku: {
    name: appServicePlanWebAppSKU
    tier: appServicePlanWebAppTier
  }
  kind: 'app'
  properties: {}
}

resource minimalApiWebApp 'Microsoft.Web/sites@2023-01-01' = {
  name: minimalApiAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlanWebApps.id
  }
}

resource webApiApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webApiAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanWebApps.id
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanWebApps.id
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
        }
        table: {
          enabled: true
        }
      }
    }
  }
}

resource storageFunctionAppPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, functionAppName, storageBlobDataContributorRole)
  scope: storageAccount
  properties: {
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRole
  }
}

resource storageMinimalApiWebAppPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, minimalApiAppName, storageBlobDataContributorRole)
  scope: storageAccount
  properties: {
    principalId: minimalApiWebApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRole
  }
}

resource storageWebApiAppPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, webApiAppName, storageBlobDataContributorRole)
  scope: storageAccount
  properties: {
    principalId: webApiApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRole
  }
}

resource storageWebAppPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.id, webAppName, storageBlobDataContributorRole)
  scope: storageAccount
  properties: {
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRole
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: logAnalyticsSKU
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    RetentionInDays: 30
    WorkspaceResourceId: logAnalytics.id
  }
}

resource functionAppConfiguration 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  parent: functionApp
  properties: {
    AzureWebJobsStorage: storageAccountConnectionString
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccountConnectionString
    WEBSITE_CONTENTSHARE: toLower(functionAppName)
  }
  dependsOn: [storageFunctionAppPermissions]
}  

resource minimalApiWebAppConfiguration 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  parent: minimalApiWebApp
  properties: {
    numberOfWorkers: '1'
    AzureWebJobsStorage: storageAccountConnectionString
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    netFrameworkVersion: 'v8.0'
    
  }
  dependsOn: [storageMinimalApiWebAppPermissions]
}

resource webApiAppConfiguration 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  parent: webApiApp
  properties: {
    numberOfWorkers: '1'
    AzureWebJobsStorage: storageAccountConnectionString
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    netFrameworkVersion: 'v8.0'
  }
  dependsOn: [storageWebApiAppPermissions]
}

resource webAppConfiguration 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  parent: webApp
  properties: {
    numberOfWorkers: '1'
    AzureWebJobsStorage: storageAccountConnectionString
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    netFrameworkVersion: 'v8.0'
  }
  dependsOn: [storageWebAppPermissions]
}

resource staticWebApp 'Microsoft.Web/staticSites@2020-12-01' = {
  name: staticWebAppName
  location: location
  sku: {
    name: swaSku
    size: swaSku
  }
  properties: {}

  resource staticWebAppAppSettings 'config' = {
    name: 'appsettings'
    properties: {
      APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
    }
  }
}

output defaultHostname string = staticWebApp.properties.defaultHostname
