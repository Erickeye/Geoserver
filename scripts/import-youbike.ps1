# 把 data/youbike/youbike_immediate.json 匯入 PostGIS（資料庫 taiwan、資料表 public.youbike_stations）
# 用法：pwsh -File scripts\import-youbike.ps1 [-Refresh]
#   -Refresh  先重新下載最新的 JSON（資料每分鐘更新，匯入的是當下快照）
# 密碼執行時才輸入，不寫在檔案裡。

param([switch]$Refresh)

$ogr2ogr = "C:\Program Files\QGIS 3.44.15\bin\ogr2ogr.exe"
$psql    = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$root    = Resolve-Path (Join-Path $PSScriptRoot "..")
$dataDir = Join-Path $root "data\youbike"
$json    = Join-Path $dataDir "youbike_immediate.json"
$geojson = Join-Path $dataDir "youbike.geojson"
$url     = "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json"

New-Item -ItemType Directory -Force $dataDir | Out-Null
if ($Refresh -or -not (Test-Path $json)) {
    Invoke-WebRequest $url -OutFile $json -UseBasicParsing
}

python -I (Join-Path $PSScriptRoot "youbike_to_geojson.py") $json $geojson
if ($LASTEXITCODE -ne 0) { throw "轉換 GeoJSON 失敗" }

$secure = Read-Host "postgres 密碼" -AsSecureString
$env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
$env:PGCLIENTENCODING = "UTF8"

try {
    # -overwrite：重建資料表；自動建 id 主鍵與 geom 的 GiST 空間索引
    & $ogr2ogr -f PostgreSQL "PG:host=localhost port=5432 dbname=taiwan user=postgres" `
        $geojson -nln public.youbike_stations -overwrite `
        -nlt POINT -lco GEOMETRY_NAME=geom -lco FID=id
    if ($LASTEXITCODE -ne 0) { throw "ogr2ogr 失敗 ($LASTEXITCODE)" }

    & $psql -h localhost -U postgres -d taiwan -v ON_ERROR_STOP=1 -f (Join-Path $root "sql\01_youbike_indexes.sql")
    if ($LASTEXITCODE -ne 0) { throw "建立索引失敗 ($LASTEXITCODE)" }

    & $psql -h localhost -U postgres -d taiwan -c "SELECT COUNT(*) AS stations, SUM(bikes) AS bikes FROM public.youbike_stations;"
}
finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:\PGCLIENTENCODING -ErrorAction SilentlyContinue
}
