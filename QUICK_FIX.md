## AIRFLOW 3.1.5 - ERROR FIX & QUICK START

### ❌ Error Fixed
The `airflow webserver` command was **removed in Airflow 3.1.5**.

**Solution:** Use `airflow standalone` instead

---

## ✅ CORRECT STARTUP COMMAND

**One-Line Command (Copy & Paste):**
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow standalone"
```

**What this does:**
- Starts webserver on http://localhost:8080
- Starts scheduler
- Starts DAG processor
- All in ONE terminal

---

## Access Airflow

- **URL:** http://localhost:8080
- **User:** admin
- **Pass:** admin (or will be generated and shown in terminal)

---

## For Testing

Once Airflow is running, you can:

1. **View DAGs:** Go to DAGs section
2. **Monitor Processor:** Check scheduler logs for DAG reprocessing behavior
3. **Test Git Sync:** Run sync tests and monitor CPU usage

---

## Summary of Changes Made

| File | Fix |
|------|-----|
| README.md | Updated to use `airflow standalone` |
| HOW_TO_RUN.md | Removed deprecated `webserver` command |
| START_WEBSERVER.sh | Now calls `airflow api-server` |

---

## Airflow 3.1.5 New Commands

- ✅ `airflow standalone` - Everything in one (easiest)
- ✅ `airflow api-server` - REST API server
- ✅ `airflow scheduler` - Scheduler only
- ✅ `airflow dag-processor` - DAG processor only
- ❌ `airflow webserver` - REMOVED (deprecated)

---
