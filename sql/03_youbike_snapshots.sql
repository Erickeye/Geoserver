-- 階段 4：歷史快照。可重複執行。
-- 只在可借／可還數量有變動時才寫一筆，避免每分鐘 1800 列的資料量；
-- recorded_at 用來源資料的更新時間，主鍵 (sno, recorded_at) 讓重複抓到同一版資料時不會重複寫入。

CREATE TABLE IF NOT EXISTS youbike_snapshots (
    sno         varchar     NOT NULL,
    bikes       integer     NOT NULL,
    docks       integer     NOT NULL,
    recorded_at timestamptz NOT NULL,
    CONSTRAINT youbike_snapshots_pkey PRIMARY KEY (sno, recorded_at)
);

-- 清舊資料（依時間刪除）用
CREATE INDEX IF NOT EXISTS idx_youbike_snapshots_recorded_at
    ON youbike_snapshots (recorded_at);
