# Priority 2 Live Demonstration - Two-Folder Sync Architecture

**Date:** December 16, 2025  
**Purpose:** Demonstrate file modification timestamp tracking in action

---

## Your Setup

```
┌────────────────────────┐
│  Git Repo Folder       │
│  (You edit here)       │
│  C:\path\to\git-repo\  │
└────────────┬───────────┘
             │
      ┌──────▼──────┐
      │   Sync      │
      │  Mechanism  │
      │  (Copy)     │
      └──────┬──────┘
             │
┌────────────▼──────────┐
│ Production Dags Folder│
│ (Airflow reads)       │
│ ./dags/               │
└───────────────────────┘
```

---

## Test 1: WITH File Changes (CPU WILL spike)

### Step 1: Make a change in Git Repo folder

**Edit one of your DAGs in the Git Repo:**
```powershell
# Example: Edit git_sync_test_dag.py in your Git repo
notepad C:\path\to\your\git\repo\git_sync_test_dag.py
```

**Make ANY small change:**
```python
# Add a comment at the end of the file
# Priority 2 Test - File changed at 2025-12-16 19:14
```

**Save the file** (this updates mtime = modification time)

---

### Step 2: Open Task Manager and watch CPU

```
Press: Ctrl + Shift + Esc
Watch: CPU % column
```

---

### Step 3: Run your sync mechanism

**Copy the file from Git Repo → Production Dags Folder:**
```powershell
# Your sync command (example)
Copy-Item "C:\path\to\git-repo\git_sync_test_dag.py" -Destination "C:\Jawad\airflow-git-dag-test\dags\git_sync_test_dag.py"

# OR if you use a sync script:
& C:\path\to\your\sync-script.ps1
```

---

### Step 4: Observe CPU Spike

**Expected result:**
```
17:14:10 - CPU: 6% (idle)
17:14:11 - CPU: 6% (idle)
17:14:12 - Sync runs → File copied
17:14:12 - CPU: 52% ↑ (Priority 2 detected change!)
17:14:13 - CPU: 65% (DAG reparsing)
17:14:14 - CPU: 45% (finishing)
17:14:15 - CPU: 7% (back to baseline)
```

**Why spike happened:**
- Sync copied file → mtime changed
- Airflow detected: "mtime different than cached!"
- Airflow reparsed only that DAG ✅
- CPU spike was **necessary**

---

## Test 2: WITHOUT File Changes (CPU WON'T spike)

### Step 1: Run sync again WITHOUT making changes

**Run sync with NO edits to Git Repo:**
```powershell
# Sync again (no changes in source)
Copy-Item "C:\path\to\git-repo\git_sync_test_dag.py" -Destination "C:\Jawad\airflow-git-dag-test\dags\git_sync_test_dag.py" -Force
```

OR if files are identical, sync does nothing.

---

### Step 2: Watch CPU

**Expected result:**
```
17:14:20 - CPU: 7% (idle)
17:14:21 - CPU: 7% (idle)
17:14:22 - Sync runs → No change detected
17:14:22 - CPU: 6% ← NO SPIKE! ✅
17:14:23 - CPU: 7% (nothing to reparse)
17:14:24 - CPU: 7% (Priority 2 skipped reparse!)
```

**Why NO spike:**
- Sync ran but file didn't change
- Airflow checked: "Is mtime same as before?" → YES
- Airflow skipped reparsing ✅
- **Wasted CPU cycle eliminated!**

---

## Test 3: Multiple Syncs (Real-world scenario)

### Scenario: Sync runs 6 times per minute (every 10 seconds)

**Without Priority 2 (old way):**
```
Sync 1 (10:00:00) → File unchanged → Reparse all 4 DAGs → CPU spike 79%
Sync 2 (10:00:10) → File unchanged → Reparse all 4 DAGs → CPU spike 79%
Sync 3 (10:00:20) → File unchanged → Reparse all 4 DAGs → CPU spike 79%
Sync 4 (10:00:30) → File unchanged → Reparse all 4 DAGs → CPU spike 79%
Sync 5 (10:00:40) → File unchanged → Reparse all 4 DAGs → CPU spike 79%
Sync 6 (10:00:50) → File unchanged → Reparse all 4 DAGs → CPU spike 79%

Result: 6 unnecessary CPU spikes = wasted resources!
```

**With Priority 2 (new way):**
```
Sync 1 (10:00:00) → File unchanged → Skip reparse ✅ → CPU 6%
Sync 2 (10:00:10) → File unchanged → Skip reparse ✅ → CPU 6%
Sync 3 (10:00:20) → File unchanged → Skip reparse ✅ → CPU 6%
Sync 4 (10:00:30) → File unchanged → Skip reparse ✅ → CPU 6%
Sync 5 (10:00:40) → File unchanged → Skip reparse ✅ → CPU 6%
Sync 6 (10:00:50) → File HAS change → Reparse that 1 DAG ✅ → CPU spike 50%

Result: 5 CPU spikes avoided, 1 necessary spike = efficient!
```

---

## Complete Demo Script

**Run this to demonstrate both scenarios:**

```powershell
Write-Host "=== Priority 2 Live Demonstration ===" -ForegroundColor Green
Write-Host ""

# Get paths
$gitRepoFile = "C:\path\to\your\git\repo\git_sync_test_dag.py"  # EDIT THIS
$dagsFile = "C:\Jawad\airflow-git-dag-test\dags\git_sync_test_dag.py"

Write-Host "Step 1: Make a change in Git Repo" -ForegroundColor Yellow
Read-Host "Edit $gitRepoFile and save. Press Enter when done"

Write-Host "Step 2: Monitoring CPU (watch Task Manager)" -ForegroundColor Yellow
Write-Host "Press Ctrl+Shift+Esc to open Task Manager"
Read-Host "Press Enter when ready to sync"

Write-Host "Step 3: Syncing file (WITH change)..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "HH:mm:ss"
Write-Host "[$timestamp] Syncing..."
Copy-Item $gitRepoFile -Destination $dagsFile -Force
Write-Host "[$timestamp] ✅ File copied - Airflow should detect change and spike CPU!"
Write-Host "Watch CPU in Task Manager - should see spike 50-70% for 2-3 seconds"

Write-Host ""
Write-Host "Step 4: Sync again WITHOUT changes" -ForegroundColor Yellow
Read-Host "Don't edit anything! Just press Enter to sync again"

Write-Host "Step 5: Syncing file (NO change)..." -ForegroundColor Cyan
$timestamp = Get-Date -Format "HH:mm:ss"
Write-Host "[$timestamp] Syncing again..."
Copy-Item $gitRepoFile -Destination $dagsFile -Force
Write-Host "[$timestamp] ✅ File copied (but content identical) - Airflow should SKIP reparse!"
Write-Host "Watch CPU in Task Manager - should stay at baseline 6-7%!"

Write-Host ""
Write-Host "=== Demonstration Complete ===" -ForegroundColor Green
Write-Host "Priority 2 is working if:"
Write-Host "  ✅ Sync 1: CPU spiked (file mtime changed)"
Write-Host "  ✅ Sync 2: CPU stayed low (file content same)"
```

---

## Monitoring Commands

**Check CPU during sync:**
```powershell
# Every 2 seconds, show CPU
for ($i=0; $i -lt 10; $i++) {
    $cpu = (Get-WmiObject win32_processor).LoadPercentage
    $time = Get-Date -Format "HH:mm:ss"
    Write-Host "$time - CPU: $cpu%"
    Start-Sleep -Seconds 2
}
```

**Docker container CPU:**
```powershell
# Live update (every 3 seconds)
while ($true) {
    Clear-Host
    docker stats --no-stream airflow-3.1.5
    Start-Sleep -Seconds 3
}
```

---

## Expected Outcomes

### Success Indicators:

| Test | Sync Action | Expected CPU | Indicator |
|------|-------------|--------------|-----------|
| **Test 1** | File changed | Spike 50-70% | ✅ Priority 2 detected change |
| **Test 2** | File unchanged | Baseline 6-7% | ✅ Priority 2 skipped reparse |
| **Real-world** | 6 syncs/min, no changes | Baseline 6-7% | ✅ Saved 2.4 hrs daily |

### Failure Indicators:

| Test | Sync Action | If you see... | Problem |
|------|-------------|---------------|---------|
| **Test 1** | File changed | No spike | Priority 2 not detecting |
| **Test 2** | File unchanged | Spike 79% | Priority 2 not working |

---

## Recording Results

**Document what you observe:**

```
TEST 1: WITH File Change
─────────────────────────
Time of sync: _________
CPU before:  _________
CPU peak:    _________
Duration:    _________ seconds
Result:      ✅ Spike detected OR ❌ No spike

TEST 2: WITHOUT File Change  
──────────────────────────
Time of sync: _________
CPU level:   _________
Any spike:   ✅ No spike (good!) OR ❌ Yes spike (bad!)
Result:      ✅ Baseline maintained OR ❌ Unexpected spike
```

---

## Troubleshooting

**If Test 1 doesn't show CPU spike:**
- Ensure file modification time changed (check file properties)
- Airflow might be busy with other tasks
- Wait 5 minutes and retry (respect `min_file_process_interval = 10s`)

**If Test 2 shows CPU spike:**
- Check if sync actually copied the file (different mtime)
- File might have changed unintentionally
- Verify sync mechanism doesn't update timestamps unnecessarily

---

## Next Steps

1. **Run both tests** - Document results
2. **Report to client** - Show before/after CPU
3. **Monitor 24 hours** - Confirm pattern holds
4. **Plan Priority 3** - Parallel DAG processing (if needed)

---

**Quick Start:**

```powershell
# 1. Edit file in Git repo
# 2. Press Ctrl+Shift+Esc (Task Manager)
# 3. Copy file: Copy-Item C:\git-repo\dag.py -Destination C:\Jawad\...\dags\dag.py
# 4. Watch CPU spike/stay low
# 5. Repeat without edits
# 6. Document results
```

🎯 **Goal:** Show the client exactly how file modification timestamps eliminate unnecessary CPU spikes!

