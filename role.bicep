targetScope = 'subscription'

param principalId string

var roleName = 'Resource Group Deleter Role'

resource role 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(roleName)
  properties: {
    roleName: roleName
    assignableScopes: [
      subscription().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.Resources/subscriptions/resourceGroups/delete'
          'Microsoft.Resources/subscriptions/read' // get a list of subscriptions, required to get the default subscription
          'Microsoft.Resources/subscriptions/resourceGroups/read' // get or list resource groups
          'Microsoft.Authorization/locks/read' // get resource locks
        ]
      }
    ]
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, 'Resource Group Deleter')
  properties: {
    roleDefinitionId: role.id
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

output roleId string = role.id
output roleName string = roleName
