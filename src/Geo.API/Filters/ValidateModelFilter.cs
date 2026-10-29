using Geo.Service.Enums;
using Geo.Service.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Geo.API.Filters
{
    /// <summary>
    /// 全域驗證 Filter：DataAnnotations 驗證失敗時回傳 ResultModel（HTTP 200）。
    /// </summary>
    public class ValidateModelFilter : IActionFilter
    {
        public void OnActionExecuting(ActionExecutingContext context)
        {
            if (context.ModelState.IsValid)
            {
                return;
            }

            var message = string.Join("; ", context.ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage));

            context.Result = new OkObjectResult(
                ResultModel.Error(ErrorCodeType.InvalidParameter, message));
        }

        public void OnActionExecuted(ActionExecutedContext context)
        {
        }
    }
}
