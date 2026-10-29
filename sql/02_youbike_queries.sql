-- 練習查詢：一次貼一句到 pgAdmin 執行。
-- 範例點：臺北 101（經度 121.5645, 緯度 25.0340）。注意 ST_MakePoint 是 (經度, 緯度)。

-- 1) 各行政區站數與目前可借車輛
SELECT district, COUNT(*) AS stations, SUM(bikes) AS bikes
FROM youbike_stations
WHERE active = 1
GROUP BY district
ORDER BY stations DESC;

-- 2) 離 101 最近的 5 個站，距離（公尺）——兩段式，與 GeoServer 的 youbike_nearest 相同
--    內層 ORDER BY geom <-> 點 是 KNN：吃 GiST 空間索引，不必排序全部站點。
--    但 <-> 在 geometry 上以「度」計算，緯度 25 度時東西向約高估 10%，排序未必等於公尺距離，
--    所以內層多抓 3 倍候選（LIMIT 15），外層再用 geography 算出的公尺距離重排，取前 5。
SELECT * FROM (
  SELECT name, district, bikes, docks,
         round(ST_Distance(geom::geography,
               ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)::geography)) AS dist_m
  FROM youbike_stations
  WHERE active = 1
  ORDER BY geom <-> ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)
  LIMIT 15
) candidates
ORDER BY dist_m
LIMIT 5;

-- 2b) 對照：單段 KNN（只用「度」排序），和 2) 比較名次是否不同
SELECT name, round(ST_Distance(geom::geography,
       ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)::geography)) AS dist_m
FROM youbike_stations
WHERE active = 1
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)
LIMIT 5;

-- 3) 看是否真的用到索引（資料量小時規劃器也可能選全表掃描）
EXPLAIN ANALYZE
SELECT name FROM youbike_stations
ORDER BY geom <-> ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)
LIMIT 5;

-- 4) 站點落在哪個鄉鎮（與 towns 做空間關聯），檢查 district 欄位是否一致
SELECT t.countyname, t.townname, COUNT(*) AS stations
FROM youbike_stations s
JOIN towns t ON ST_Intersects(t.geom, s.geom)
GROUP BY t.countyname, t.townname
ORDER BY stations DESC
LIMIT 10;

-- 5) 500 公尺內有車可借的站
SELECT name, bikes
FROM youbike_stations
WHERE active = 1 AND bikes > 0
  AND ST_DWithin(geom::geography,
        ST_SetSRID(ST_MakePoint(121.5645, 25.0340), 4326)::geography, 500)
ORDER BY bikes DESC;
