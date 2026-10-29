namespace Geo.Service.Enums
{
    /// <summary>
    /// API 錯誤碼。數值不可重複，新增時往後遞增。
    /// </summary>
    public enum ErrorCodeType
    {
        None = 0,
        InvalidParameter = 1001,
        NotFoundData = 1002,
        SystemError = 9999
    }
}
