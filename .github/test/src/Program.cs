using Elvia.Configuration;
using Elvia.Telemetry;
using Elvia.Telemetry.Extensions;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.HttpLogging;
using Prometheus;


var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddHashiVaultSecrets();

builder.Services.AddAuthorization(options =>
{
    var policy = new AuthorizationPolicyBuilder()
        // See https://elvia.atlassian.net/wiki/spaces/DOCELVID/pages/387350880/API-er+Sikre+innkommende+requests
        // for details in setting up authorization
        .RequireClaim("scope", "core.demo-api-machineaccess")
        // .RequireClaim("ad_groups", "16a83654-37f6-4991-9474-ccd372bdfc73")
        .Build();
    options.DefaultPolicy = policy;
});
builder.Services.AddHealthChecks();
builder.Services.AddControllers();
var authority = builder.Configuration.EnsureHasValue("elvid:kv:shared:elvidauthority");
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = authority;
        options.TokenValidationParameters.ValidateAudience = false;
        options.TokenValidationParameters.ValidateIssuer = false;
        options.MapInboundClaims = false;
    });
var instrumentationKey = builder.Configuration.EnsureHasValue("core:kv:appinsights:core:instrumentation-key");
builder.Services.AddStandardElviaTelemetryLogging(instrumentationKey, retainTelemetryWhere: telemetryItem =>
    telemetryItem switch
    {
        DependencyTelemetry d => false,
        _ => true,
    });

builder.Services.AddSwaggerGen();
// builder.Services.AddHttpLogging(logging => { logging.LoggingFields = HttpLoggingFields.RequestHeaders; });

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseHsts();
}
// app.UseHttpLogging();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.AddStandardElviaAspnetMetrics();

app.MapHealthChecks("/health");
app.MapDefaultControllerRoute();
app.MapMetrics();

app.UseSwagger();
app.UseSwaggerUI();

app.Run();
