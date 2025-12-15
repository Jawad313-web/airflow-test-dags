# How to Run Airflow 3.1.5

## Quick Start - Step by Step

### Step 1: Create directories in WSL
```powershell
wsl bash -c "mkdir -p ~/airflow_test/{dags_repo,airflow_home/{dags,logs,plugins}}"
```

### Step 2: Initialize Git repository with DAGs
```powershell
wsl bash -c "cd ~/airflow_test/dags_repo && git init && git config user.name 'Test' && git config user.email 'test@test.com'"
```

### Step 3: Create Python virtual environment
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && python3 -m venv venv"
```

### Step 4: Install Airflow 3.1.5 (Takes 5-10 minutes)
```powershell
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && pip install --upgrade pip setuptools wheel && pip install apache-airflow==3.1.5 apache-airflow-providers-git"
```

### Step 5: Initialize database
```powershell
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow db migrate"
```

**After these steps, Airflow 3.1.5 is ready!**

---

## Starting Airflow (After Step 5 Complete)

### ✅ EASIEST WAY - Use Standalone Mode (Single Terminal)

**Single PowerShell Terminal - All-in-One:**
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow standalone"
```

This starts everything (webserver + scheduler + processor) in one terminal.

---

### Alternative: Separate Components (Advanced)

**Terminal 1 - API Server:**
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow api-server"
```

**Terminal 2 - Scheduler:**
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow scheduler"
```

---

## Access Airflow

**Web UI:** http://localhost:8080

**Default Login:**
- Username: admin
- Password: admin

---

## Access Airflow Web UI
Open browser: **http://localhost:8080**

---

## Testing Git DAG Sync

### Run Git sync test:
```bash
wsl bash -c "cd ~/airflow_test && bash test_git_sync.sh"
```

### Monitor processor logs:
```bash
wsl tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log
```

---

## All-in-One Setup Command

Run these 5 PowerShell commands in sequence (wait for each to complete):

```powershell
# 1. Create directories
wsl bash -c "mkdir -p ~/airflow_test/{dags_repo,airflow_home/{dags,logs,plugins}}"

# 2. Init Git
wsl bash -c "cd ~/airflow_test/dags_repo && git init && git config user.name 'Test' && git config user.email 'test@test.com'"

# 3. Create venv
wsl bash -c "cd ~/airflow_test/airflow_home && python3 -m venv venv"

# 4. Install Airflow (TAKES 5-10 MINUTES - WAIT FOR COMPLETION)
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && pip install --upgrade pip setuptools wheel && pip install apache-airflow==3.1.5 apache-airflow-providers-git"

# 5. Init database
wsl bash -c "source ~/airflow_test/airflow_home/venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow db migrate"
```

**Once all 5 commands complete, Airflow is ready!**

---

## Troubleshooting

### If setup fails:
```bash
wsl rm -rf ~/airflow_test
wsl mkdir -p ~/airflow_test
# Then re-run setup
```

### Check if running:
```bash
wsl ps aux | grep airflow
```

### Stop Airflow:
```bash
wsl pkill -f airflow
```

---

## Directory Structure After Setup

```
~/airflow_test/
├── dags_repo/              (Git repository with DAGs)
│   ├── .git/
│   └── dags/
│       ├── sample_dag.py
│       └── monitoring_dag.py
└── airflow_home/           (Airflow installation)
    ├── venv/               (Python virtual environment)
    ├── airflow.db          (SQLite database)
    ├── dags/               (Synced DAGs folder)
    ├── logs/               (Airflow logs)
    └── plugins/            (Custom plugins)
```

---

## What Gets Tested

1. **DAG Processor Behavior**: Watch if DAGs are reprocessed on every sync
2. **Git Integration**: Test syncing DAGs from Git repository
3. **Resource Usage**: Monitor CPU/memory during syncing
4. **Performance**: Baseline before and after optimization

---

## Default Airflow Credentials
- **Username**: `admin`
- **Password**: `admin` (set during first webserver startup)
