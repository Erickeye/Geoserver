-- ogr2ogr 匯入 youbike_stations 之後執行：補上限制與索引。
-- ogr2ogr 已建立主鍵 id 與 geom 的 GiST 空間索引，這裡補其餘的。

ALTER TABLE youbike_stations
    DROP CONSTRAINT IF EXISTS youbike_stations_sno_key;
ALTER TABLE youbike_stations
    ADD CONSTRAINT youbike_stations_sno_key UNIQUE (sno);

-- 依行政區篩選用
CREATE INDEX IF NOT EXISTS idx_youbike_stations_district
    ON youbike_stations (district);

ANALYZE youbike_stations;
