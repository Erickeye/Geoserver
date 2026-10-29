using Geo.Service.Enums;
using Geo.Service.Models;

namespace Geo.API.Middleware
{
    /// <summary>
    /// 攔截未處理例外：記錄 Log，並以 ResultModel 回應（不洩漏內部訊息）。
    /// </summary>
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionMiddleware> _logger;

        public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "未處理的例外 {Method} {Path}", context.Request.Method, context.Request.Path);

                context.Response.StatusCode = StatusCodes.Status200OK;
                await context.Response.WriteAsJsonAsync(ResultModel.Error(ErrorCodeType.SystemError));
            }
        }
    }
}
