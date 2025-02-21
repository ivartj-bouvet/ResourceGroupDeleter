using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Azure;
using Azure.ResourceManager;
using Azure.ResourceManager.Resources;

namespace ResourceGroupDeleter
{
    public class DeleteResourceGroups(IAzureClientFactory<ArmClient> factory, ILogger<DeleteResourceGroups> logger)
    {
        private readonly ArmClient _armClient = factory.CreateClient(ArmClientName);
        public const string ArmClientName = "ArmClient";

        [Function("DeleteResourceGroups")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequest req)
        {
            logger.LogInformation("C# HTTP trigger function processed a request.");

            var subscription = await _armClient.GetDefaultSubscriptionAsync();
            var subscriptionId = subscription.Data.SubscriptionId;
            var tasks = subscription.GetResourceGroups()
                .Where(resourceGroup => !resourceGroup.GetManagementLocks().Any())
                .Select(resourceGroup => resourceGroup.DeleteAsync(Azure.WaitUntil.Started))
                .ToArray();
            Task.WaitAll(tasks);
            return new OkObjectResult("Welcome to Azure Functions!");
        }
    }
}
