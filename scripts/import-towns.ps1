# 把 data/taiwan/towns.gpkg 匯入 PostGIS（資料庫 taiwan、資料表 public.towns）
# 用法：powershell -File scripts\import-towns.ps1
# 密碼執行時才輸入，不寫在檔案裡。

$ogr2ogr = "C:\Program Files\QGIS 3.44.15\bin\ogr2ogr.exe"
$psql    = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$source  = Join-Path $PSScriptRoot "..\data\taiwan\towns.gpkg"

$secure = Read-Host "postgres 密碼" -AsSecureString
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

try {
    # -overwrite 會先刪掉舊的 towns 表；欄位名稱預設轉小寫、建立 GiST 空間索引
    & $ogr2ogr -f PostgreSQL "PG:host=localhost port=5432 dbname=taiwan user=postgres" `
        $source -nln public.towns -overwrite `
        -nlt PROMOTE_TO_MULTI -lco GEOMETRY_NAME=geom -lco FID=id
    if ($LASTEXITCODE -ne 0) { throw "ogr2ogr 失敗 ($LASTEXITCODE)" }

    & $psql -h localhost -U postgres -d taiwan -c "SELECT COUNT(*) AS towns FROM public.towns;"
}
finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
