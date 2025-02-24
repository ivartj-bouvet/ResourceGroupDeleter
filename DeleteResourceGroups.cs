using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Azure;
using Azure.ResourceManager;

namespace ResourceGroupDeleter
{
    public class DeleteResourceGroups(IAzureClientFactory<ArmClient> factory)
    {
        private readonly ArmClient _armClient = factory.CreateClient(ArmClientName);
        public const string ArmClientName = "ArmClient";

        [Function("DeleteResourceGroups")]
        public async Task Run([TimerTrigger("0 0 0 * * Sun")] TimerInfo timerInfo)
        {
            var subscription = await _armClient.GetDefaultSubscriptionAsync();
            var subscriptionId = subscription.Data.SubscriptionId;
            var tasks = subscription.GetResourceGroups()
                .Where(resourceGroup => !resourceGroup.GetManagementLocks().Any())
                .Select(resourceGroup => resourceGroup.DeleteAsync(Azure.WaitUntil.Completed))
                .ToArray();
            await Task.WhenAll(tasks);
        }
    }
}
