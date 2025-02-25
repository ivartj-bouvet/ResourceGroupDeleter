using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Azure;
using Azure.ResourceManager;
using Azure.ResourceManager.Resources;
using Microsoft.Extensions.Logging;

namespace ResourceGroupDeleter
{
    public class DeleteResourceGroups(IAzureClientFactory<ArmClient> factory, ILogger<DeleteResourceGroups> logger)
    {
        private readonly ArmClient _armClient = factory.CreateClient(ArmClientName);
        public const string ArmClientName = "ArmClient";

        [Function("DeleteResourceGroups")]
        public void Run([TimerTrigger("0 0 0 * * Sun")] TimerInfo timerInfo)
        {
            var subscription = _armClient.GetDefaultSubscription();
            var subscriptionId = subscription.Data.SubscriptionId;
            var resourceGroups = subscription.GetResourceGroups().ToArray();
            logger.LogInformation("seeing the following resource groups: {}", resourceGroups.Select(resourceGroup => resourceGroup.Data.Name).Aggregate((a, b) => $"{a}, {b}"));
            resourceGroups.AsParallel()
                .ForAll(resourceGroup =>
                {
                    if (resourceGroup.GetManagementLocks().Any())
                    {
                        logger.LogInformation("resource group {} has one or more locks; not deleting", resourceGroup.Data.Name);
                        return;
                    }
                    else
                    {
                        logger.LogInformation("resource group {} has no locks; deleting", resourceGroup.Data.Name);
                        Task.Run(() => resourceGroup.Delete(Azure.WaitUntil.Completed));
                    }
                });
        }
    }
}
