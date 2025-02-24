param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'asp${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

var storageConnection = 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: 'func${uniqueString(resourceGroup().id)}'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com' // to allow testing endpoints from portal
        ]
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageConnection
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageConnection
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(resourceGroup().name)
        }
        {
          name: 'WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED'
          value: '1'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
          // 2025-02-21 Ivar:
          // Some issues with deploying code appeared to disappear when using
          // APPINSIGHTS_INSTRUMENTATIONKEY instead of the recommended
          // APPLICATIONINSIGHTS_CONNECTION_STRING.
        }
      ]
    }
  }
}

module roleModule 'role.bicep' = {
  name: 'resourcegroupdeleter'
  scope: subscription()
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().name, 'Resource Group Deleter')
  properties: {
    roleDefinitionId: roleModule.outputs.roleId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  location: 'norwayeast'
  name: 'log${uniqueString(resourceGroup().name)}'
  properties: {
    retentionInDays: 30
    sku: {
      name: 'pergb2018' // pay as you go
    }
  }
}

resource applicationInsights 'microsoft.insights/components@2020-02-02' = {
  kind: 'web'
  location: 'norwayeast'
  name: 'appi${uniqueString(resourceGroup().name)}'
  properties: {
    Application_Type: 'web'    
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'lock${uniqueString(resourceGroup().name)}'
  properties: {
    level: 'CanNotDelete'
  }
}
