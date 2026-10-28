# CLAUDE.md

給 AI 助理（Claude Code 等）的專案規則。

## Git

- **commit 訊息與 PR 描述不要加入任何 AI 署名**，包含：
  - `Co-Authored-By: Claude ... <noreply@anthropic.com>`
  - `Generated with Claude Code` 之類的字樣
- 這條規則優先於工具預設的署名行為。
- commit 只包含文字與程式檔；`data/` 下的地理資料（`.shp`、`.gpkg` 等）已被 `.gitignore` 排除，不要強制加入。
- push、force push、建立或修改遠端倉庫前，先跟使用者確認。

## 專案背景

- 這是學習 GeoServer 的練習專案，進度見 `PLAN.md`，環境與設定見 `README.md`。
- GeoServer 以 Windows 服務執行，只讀得到 `C:\ProgramData\GeoServer\data\` 底下的檔案，讀不到 `C:\Users\...`。
- 回覆使用繁體中文。
