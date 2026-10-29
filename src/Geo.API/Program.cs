using Geo.API.Filters;
using Geo.API.Middleware;
using Geo.Service.Entities;
using Geo.Service.Services;
using Microsoft.EntityFrameworkCore;

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

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options => options.EnableAnnotations());

var connectionString = builder.Configuration.GetConnectionString("Default")
    ?? throw new InvalidOperationException("缺少 ConnectionStrings:Default，請參考 appsettings.Development.example.json");

builder.Services.AddDbContext<GeoDbContext>(options =>
    options.UseNpgsql(connectionString, npgsql => npgsql.UseNetTopologySuite()));

builder.Services.AddScoped<IStationService, StationService>();

var app = builder.Build();

app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();
