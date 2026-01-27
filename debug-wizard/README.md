# Debug Wizard (偵錯巫師)

這是專為本專案設計的 **「開發環境診斷醫師」**。它能自動檢測 `GEMINI.md` 中定義的技術堆疊（Grafana, Loki, App Server 等）是否健康運作。

## 🌟 核心設計哲學 (Core Design Philosophy)

本技能不僅僅是一個腳本集合，更實作了針對團隊協作的 **「無摩擦設計」**：

### 1. 雙模組跨平台架構 (Dual-Mode Architecture)
為了適應混合開發環境，我們針對不同 OS 提供了原生實作，而非依賴額外的 Runtime (如 Node.js)：
*   **Windows**: 使用 PowerShell (`.ps1`)，整合 `Test-NetConnection`。
*   **macOS / Linux**: 使用 Bash (`.sh`)，整合 `nc` (Netcat) 與 ANSI 色碼。

### 2. 智慧權限管理 (Automatic Permission Handling)
為了一勞永逸解決 macOS/Linux 腳本常見的 `chmod +x` 權限問題，我們設計了 **「雙重保險機制」**：

*   **🛡️ Git 層級 (Source Level)**：
    所有 `.sh` 腳本在 Git Index 中已被強制標記為可執行 (`100755`)。
    > `git update-index --chmod=+x scripts/diagnose.sh`
    這意味著當隊友 `git clone` 或 `git pull` 檔案時，**天生就具備執行權限**，無需手動修改。

*   **🤖 Agent 層級 (Logic Level)**：
    在 `SKILL.md` 中內建了 **「自我修復協議」**。若 Agent 在執行過程中遭遇 `Permission denied`，它被授權**自動執行** `chmod +x` 並靜默重試，無需中斷對話詢問用戶。

---

## 🚀 使用方式 (Usage)

### Windows 使用者
直接於 PowerShell 執行：
```powershell
./scripts/diagnose.ps1
```

### macOS / Linux 使用者
直接於 Terminal 執行（通常無需 chmod）：
```bash
./scripts/diagnose.sh
```

---

## 📂 檔案內容說明

| 檔案路徑 | 說明 |
| :--- | :--- |
| **`SKILL.md`** | **技能定義檔**。指導 AI 如何使用此工具，包含觸發與自我修復邏輯。 |
| **`scripts/diagnose.ps1`** | **Windows 診斷腳本**。檢查 Docker Service、Container 狀態與 Port 佔用。 |
| **`scripts/diagnose.sh`** | **macOS 診斷腳本**。功能同上，針對 Unix 環境最佳化。 |
