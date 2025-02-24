targetScope = 'subscription'

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

output roleId string = role.id
output roleName string = roleName
