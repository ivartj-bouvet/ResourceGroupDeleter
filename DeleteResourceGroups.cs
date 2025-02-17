using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ResourceGroupDeleter
{
    public class DeleteResourceGroups
    {
        private readonly ILogger<DeleteResourceGroups> _logger;

        public DeleteResourceGroups(ILogger<DeleteResourceGroups> logger)
        {
            _logger = logger;
        }

        [Function("DeleteResourceGroups")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");
            return new OkObjectResult("Welcome to Azure Functions!");
        }
    }
}
