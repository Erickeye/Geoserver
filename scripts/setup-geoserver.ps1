# 用 GeoServer REST API 建立結業專案需要的樣式與圖層（可重複執行，已存在的會先刪除重建）：
#   樣式  taiwan:youbike-bikes     依可借車輛上色（styles/youbike-bikes.sld）
#   圖層  taiwan:youbike           PostGIS 資料表 youbike_stations
#   圖層  taiwan:youbike_nearest   SQL View：離某點最近的 N 個站（參數 lon、lat、n）
# 前提：GeoServer 已有 workspace taiwan 與 PostGIS Store taiwan_postgis，且已執行 import-youbike.ps1。
# 用法：pwsh -File scripts\setup-geoserver.ps1
# 帳密使用 GeoServer 預設值 admin / geoserver（僅限本機學習環境）；
# 若已改過，先設環境變數 GEOSERVER_USER、GEOSERVER_PASSWORD 即可覆寫。

$base      = "http://localhost:8080/geoserver/rest"
$workspace = "taiwan"
$store     = "taiwan_postgis"
$root      = Resolve-Path (Join-Path $PSScriptRoot "..")

$user  = if ($env:GEOSERVER_USER)     { $env:GEOSERVER_USER }     else { "admin" }
$plain = if ($env:GEOSERVER_PASSWORD) { $env:GEOSERVER_PASSWORD } else { "geoserver" }
$auth  = "Basic " + [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("${user}:$plain"))

function Invoke-Rest([string]$Method, [string]$Path, [string]$Body, [string]$ContentType = "text/xml; charset=utf-8") {
    $req = @{
        Uri = "$base$Path"; Method = $Method; UseBasicParsing = $true; SkipHttpErrorCheck = $true
        Headers = @{ Authorization = $auth }
    }
    if ($Body) { $req.Body = [Text.Encoding]::UTF8.GetBytes($Body); $req.ContentType = $ContentType }
    $r = Invoke-WebRequest @req
    if ($r.StatusCode -eq 401) { throw "GeoServer 帳號或密碼不正確 (401)" }
    return $r
}

function Assert-Ok($r, [string]$What) {
    if ($r.StatusCode -ge 400) {
        # 錯誤訊息可能是非文字型別，Content 會是空的，所以直接從原始位元組解碼
        $text = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray())
        $ct = $r.Headers["Content-Type"]
        throw "$What 失敗 ($($r.StatusCode)) [$ct]: $text"
    }
    Write-Host "OK  $What ($($r.StatusCode))"
}

function Esc([string]$s) { [Security.SecurityElement]::Escape($s) }

# 1) 樣式：先 PUT（更新），不存在再 POST（建立）
$sld = Get-Content (Join-Path $root "styles\youbike-bikes.sld") -Raw -Encoding UTF8
$sldType = "application/vnd.ogc.sld+xml"
# 兩步驟：先建立樣式項目（只有名稱與檔名），再把 SLD 內容 PUT 進去
$r = Invoke-Rest GET "/workspaces/$workspace/styles/youbike-bikes.xml"
if ($r.StatusCode -eq 404) {
    $xml = "<style><name>youbike-bikes</name><filename>youbike-bikes.sld</filename></style>"
    Assert-Ok (Invoke-Rest POST "/workspaces/$workspace/styles" $xml) "樣式項目 youbike-bikes (建立)"
}
Assert-Ok (Invoke-Rest PUT "/workspaces/$workspace/styles/youbike-bikes" $sld $sldType) "樣式內容 youbike-bikes (SLD)"

# 2) 刪掉舊的圖層（若存在），之後重建
foreach ($ft in "youbike", "youbike_nearest") {
    $r = Invoke-Rest DELETE "/workspaces/$workspace/datastores/$store/featuretypes/${ft}?recurse=true"
    if ($r.StatusCode -eq 200) { Write-Host "    已刪除舊圖層 $ft" }
}

# 範圍只是宣告用，不影響查詢結果（涵蓋臺北市即可）
$bbox = "<minx>121.40</minx><maxx>121.70</maxx><miny>24.90</miny><maxy>25.30</maxy><crs>EPSG:4326</crs>"

# 3) 圖層 youbike：發佈整張資料表
$xml = @"
<featureType>
  <name>youbike</name>
  <nativeName>youbike_stations</nativeName>
  <title>$(Esc 'YouBike 站點')</title>
  <srs>EPSG:4326</srs>
  <projectionPolicy>FORCE_DECLARED</projectionPolicy>
  <enabled>true</enabled>
  <nativeBoundingBox>$bbox</nativeBoundingBox>
  <latLonBoundingBox>$bbox</latLonBoundingBox>
</featureType>
"@
Assert-Ok (Invoke-Rest POST "/workspaces/$workspace/datastores/$store/featuretypes" $xml) "圖層 youbike"

# 4) 圖層 youbike_nearest：SQL View。
#    兩段式：內層 ORDER BY geom <-> 點 是 KNN（用 GiST 索引快速挑出候選），
#    但 <-> 在經緯度上以「度」計算，緯度 25 度時東西向約高估 10%，所以多抓 3 倍候選，
#    外層再用 geography 算出的公尺距離重新排序、取前 N 個。
#    id 當主鍵（不能用 geom，否則 GeoServer 會把幾何當主鍵而解析失敗）。
$sql = @"
SELECT * FROM (
  SELECT id, sno, name, district, bikes, docks, total, active,
         round(ST_Distance(geom::geography,
               ST_SetSRID(ST_MakePoint(%lon%, %lat%), 4326)::geography)) AS dist_m,
         geom
  FROM youbike_stations
  WHERE active = 1
  ORDER BY geom <-> ST_SetSRID(ST_MakePoint(%lon%, %lat%), 4326)
  LIMIT %n%*3
) candidates
ORDER BY dist_m
LIMIT %n%
"@
$xml = @"
<featureType>
  <name>youbike_nearest</name>
  <nativeName>youbike_nearest</nativeName>
  <title>$(Esc 'YouBike 最近的 N 個站')</title>
  <srs>EPSG:4326</srs>
  <projectionPolicy>FORCE_DECLARED</projectionPolicy>
  <enabled>true</enabled>
  <nativeBoundingBox>$bbox</nativeBoundingBox>
  <latLonBoundingBox>$bbox</latLonBoundingBox>
  <metadata>
    <entry key="JDBC_VIRTUAL_TABLE">
      <virtualTable>
        <name>youbike_nearest</name>
        <sql>$(Esc $sql)</sql>
        <escapeSql>false</escapeSql>
        <keyColumn>id</keyColumn>
        <geometry><name>geom</name><type>Point</type><srid>4326</srid></geometry>
        <parameter><name>lon</name><defaultValue>121.5645</defaultValue><regexpValidator>^-?[\d.]+$</regexpValidator></parameter>
        <parameter><name>lat</name><defaultValue>25.0340</defaultValue><regexpValidator>^-?[\d.]+$</regexpValidator></parameter>
        <parameter><name>n</name><defaultValue>5</defaultValue><regexpValidator>^\d{1,3}$</regexpValidator></parameter>
      </virtualTable>
    </entry>
  </metadata>
</featureType>
"@
Assert-Ok (Invoke-Rest POST "/workspaces/$workspace/datastores/$store/featuretypes" $xml) "圖層 youbike_nearest (SQL View)"

# 5) 兩個圖層都套用 youbike-bikes 樣式
foreach ($layer in "youbike", "youbike_nearest") {
    $xml = "<layer><defaultStyle><name>${workspace}:youbike-bikes</name></defaultStyle></layer>"
    Assert-Ok (Invoke-Rest PUT "/layers/${workspace}:$layer" $xml) "$layer 預設樣式"
}

Write-Host ""
Write-Host "完成。驗證（不需密碼）："
Write-Host "  http://localhost:8080/geoserver/taiwan/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=taiwan:youbike&maxFeatures=3&outputFormat=application/json"
