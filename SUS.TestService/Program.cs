using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

var builder = Host.CreateDefaultBuilder(args)
    .UseWindowsService(options =>
    {
        // This is the name that will show in Event Log / SCM metadata
        options.ServiceName = "SUS_TestService";
    })
    .ConfigureServices(services =>
    {
        services.AddHostedService<Worker>();
    });

await builder.Build().RunAsync();
