using Elvia.Configuration;
using Elvia.Configuration.HashiVault;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using System;
using System.Threading.Tasks;

namespace core_demo_api
{
    public static class Program
    {
        public static void Main(string[] args)
        {
            Environment.SetEnvironmentVariable("GITHUB_TOKEN", "");
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.ConfigureAppConfiguration((context, config) => config.AddHashiVaultSecrets());
                    webBuilder.UseStartup<Startup>();
                });
    }
}
