using Geo.Service.Enums;

namespace Geo.Service.Models
{
    /// <summary>
    /// API 統一回傳格式；HTTP 一律 200，成敗看 IsSuccess。
    /// </summary>
    public class ResultModel<T>
    {
        public bool IsSuccess { get; set; }
        public ErrorCodeType ErrorCode { get; set; }
        public string? ErrorMessage { get; set; }
        public T? Data { get; set; }

        public static ResultModel<T> Success(T data) => new()
        {
            IsSuccess = true,
            ErrorCode = ErrorCodeType.None,
            Data = data
        };

        public static ResultModel<T> Error(ErrorCodeType errorCode, string? message = null) => new()
        {
            IsSuccess = false,
            ErrorCode = errorCode,
            ErrorMessage = message ?? errorCode.ToString()
        };
    }

    /// <summary>
    /// 不帶資料的 ResultModel。
    /// </summary>
    public class ResultModel : ResultModel<object>
    {
        public static ResultModel Success() => new()
        {
            IsSuccess = true,
            ErrorCode = ErrorCodeType.None
        };

        public new static ResultModel Error(ErrorCodeType errorCode, string? message = null) => new()
        {
            IsSuccess = false,
            ErrorCode = errorCode,
            ErrorMessage = message ?? errorCode.ToString()
        };
    }
}
