using Geo.API.Filters;
using Geo.API.HealthChecks;
using Geo.API.BackgroundServices;
using Geo.API.Middleware;
using Geo.Service.Entities;
using Geo.Service.Options;
using Geo.Service.Services;
using Microsoft.AspNetCore.ResponseCompression;
using Microsoft.EntityFrameworkCore;
using System.IO.Compression;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers(options =>
    {
        options.Filters.Add<ValidateModelFilter>();
    })
    .ConfigureApiBehaviorOptions(options =>
    {
        // 關閉預設的 400 自動回應，交給 ValidateModelFilter 統一格式
        options.SuppressModelStateInvalidFilter = true;
    });

// 回應壓縮：Brotli／gzip，預設會壓 application/json；用 Fastest 降低 CPU 成本
// 預設不在 HTTPS 下壓縮（避免 BREACH）；目前回應都是公開資料，若之後要啟用再評估
builder.Services.AddResponseCompression();
builder.Services.Configure<BrotliCompressionProviderOptions>(options => options.Level = CompressionLevel.Fastest);
builder.Services.Configure<GzipCompressionProviderOptions>(options => options.Level = CompressionLevel.Fastest);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options => options.EnableAnnotations());

var connectionString = builder.Configuration.GetConnectionString("Default")
    ?? throw new InvalidOperationException("缺少 ConnectionStrings:Default，請參考 appsettings.Development.example.json");

builder.Services.AddDbContext<GeoDbContext>(options =>
    options.UseNpgsql(connectionString, npgsql => npgsql.UseNetTopologySuite()));

builder.Services.AddScoped<IStationService, StationService>();
builder.Services.AddSingleton<ISyncStatusTracker, SyncStatusTracker>();

builder.Services.AddHealthChecks().AddCheck<SyncHealthCheck>("sync");

builder.Services.Configure<YouBikeOptions>(builder.Configuration.GetSection(YouBikeOptions.SectionName));
builder.Services.AddHttpClient<IYouBikeSyncService, YouBikeSyncService>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});

if (builder.Configuration.GetValue("YouBike:Enabled", true))
{
    builder.Services.AddHostedService<YouBikeRefreshService>();
}

var app = builder.Build();

// 放在最前面，連 ExceptionMiddleware 產生的錯誤回應也會被壓縮
app.UseResponseCompression();

app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
