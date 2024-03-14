using Elvia.Configuration;
using Elvia.Telemetry;
using Elvia.Telemetry.Extensions;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Prometheus;

namespace core_demo_api
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        private IConfiguration _configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddHealthChecks();
            services.AddControllers();
            var instrumentationKey = _configuration.EnsureHasValue("core:kv:appinsights:core:instrumentation-key");
            services.AddStandardElviaTelemetryLogging(instrumentationKey, retainTelemetryWhere: telemetryItem => telemetryItem switch
            {
                DependencyTelemetry d => false,
                _ => true,
            });
        }

        public void Configure(IApplicationBuilder app, IHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseHsts();
            }

            app.UseRouting();
            app.AddStandardElviaAspnetMetrics();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapHealthChecks("/health");
                endpoints.MapDefaultControllerRoute();
                endpoints.MapMetrics();
            });
        }
    }
}
