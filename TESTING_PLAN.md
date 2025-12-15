# Client Requirements - Testing Plan
## Airflow 3.1.5 Git DAG Syncing & Processor Behavior

### Client's Problem:
- Git syncs DAGs every minute
- ALL DAGs reprocessed each time (even if unchanged)
- DAG processor uses high CPU
- Need to optimize this

---

## Phase 1: Setup Git DAG Syncing

### Step 1: Create Git Repository with DAGs
```powershell
# The repository already exists at:
# ~/airflow_test/dags_repo/
# with sample DAGs
```

### Step 2: Configure Airflow to Sync from Git

In Airflow UI (http://localhost:8080):

1. Go to **Admin > Connections**
2. Click **+ Create New Connection**
3. Fill in:
   - **Connection ID:** `git_repo`
   - **Connection Type:** `Git`
   - **Host:** `file:///home/jawad/airflow_test/dags_repo`
   - **Port:** 22
4. Click **Save**

### Step 3: Update airflow.cfg for Git Syncing

Add to airflow.cfg:
```ini
[core]
# Git DAG Bundle Configuration
dag_folder = /home/jawad/airflow_test/airflow_home/dags
dags_folder = /home/jawad/airflow_test/airflow_home/dags

# Monitor DAG processor
min_file_process_interval = 10  # Seconds between DAG scans
dag_file_processor_timeout = 30
```

---

## Phase 2: Monitor DAG Processor Behavior

### Check Current DAG Sources:
```powershell
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow dags list"
```

### Monitor Processor Logs:
```powershell
wsl tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log
```

Look for:
- How often DAGs are parsed
- CPU usage per parse
- "Importing DAG" messages
- File modification detection

---

## Phase 3: Test Git Sync Behavior

### Test 1: Pull Without Changes
```bash
cd ~/airflow_test/airflow_home/dags
git clone file:///home/jawad/airflow_test/dags_repo . 2>/dev/null || git pull

# Watch processor logs - Did it reprocess DAGs?
# Check: Did CPU spike?
```

### Test 2: Modify DAG Content
```bash
cd ~/airflow_test/dags_repo
# Edit dags/sample_dag.py
sed -i 's/sample_dag/sample_dag_modified/g' dags/sample_dag.py
git add dags/sample_dag.py
git commit -m "Modify DAG"

# Now sync in airflow folder
cd ~/airflow_test/airflow_home/dags
git pull

# Check: Processor should only reprocess CHANGED DAGs
# CPU should be lower than Test 1
```

### Test 3: No Changes - Just Re-Pull
```bash
cd ~/airflow_test/airflow_home/dags
git pull

# Check: Processor should SKIP unchanged DAGs
# CPU should be minimal
```

---

## Phase 4: Measure & Compare

### Baseline (Current Behavior):
- Record: DAGs reprocessed per sync
- Record: CPU usage per sync
- Record: Parse time per DAG

### With Git Provider Optimization:
- How many DAGs actually reprocessed?
- CPU usage reduction?
- Parse time optimization?

---

## Expected Results

### WITHOUT Optimization (Current):
```
Every 1 minute sync:
  - 100 DAGs parsed (even if 99 unchanged)
  - CPU spike: 20-30%
  - Total time: 30 seconds
```

### WITH Airflow 3.1.5 + Git Provider (Optimized):
```
Every 1 minute sync:
  - Only changed DAGs parsed (1 out of 100)
  - CPU spike: 2-5%
  - Total time: 2 seconds
```

---

## Commands for Testing

### Start Airflow (if not running):
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow standalone"
```

### Monitor Processor:
```powershell
wsl tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log
```

### Check CPU Usage (in WSL):
```powershell
wsl bash -c "watch -n 1 'ps aux | grep airflow | grep -v grep'"
```

### List DAGs:
```powershell
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow dags list"
```

### Check DAG Import Errors:
```powershell
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow dags list-import-errors"
```

---

## Key Metrics to Track

| Metric | Measure |
|--------|---------|
| **DAGs Parsed per Sync** | How many DAGs are actually reparsed? |
| **CPU Usage** | Peak % during parsing |
| **Parse Duration** | Seconds to parse all DAGs |
| **File Detection** | How does it detect file changes? |
| **Optimization** | % reduction in reprocessing |

---

## Git Provider Benefits (Airflow 3.1.5)

✅ **Smart Change Detection:** Only reprocess modified DAGs
✅ **File Hash Comparison:** Compares file hashes, not timestamps
✅ **SSH Support:** Secure Git authentication via deploy keys
✅ **Efficient Syncing:** Minimal CPU and resource usage
✅ **CI/CD Ready:** Perfect for automated deployments

---

## Next Steps

1. **Setup Git Connection** in Airflow UI (Admin > Connections)
2. **Configure DAG syncing** in airflow.cfg
3. **Run Test 1, 2, 3** above
4. **Monitor logs** and CPU usage
5. **Compare** before/after optimization
6. **Report findings** to client

