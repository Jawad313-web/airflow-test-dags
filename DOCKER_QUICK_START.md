# Docker + GitHub Setup - Quick Start

## Prerequisites
- ✅ Docker Desktop installed
- ✅ GitHub account
- ✅ Git installed

---

## 1-Minute Setup

### Step 1: Build Docker Image
```powershell
cd c:\Jawad\airflow-git-dag-test
docker-compose build
```

### Step 2: Start Airflow Container
```powershell
docker-compose up -d
```

### Step 3: Access Airflow
```
Browser: http://localhost:8080
User: admin
Pass: admin
```

---

## For GitHub DAG Syncing

### Create GitHub Repo
1. Go to https://github.com/new
2. Create `airflow-dags` repository
3. Push your DAGs to it

### Configure in Airflow UI
1. Admin > Connections > + Create
2. **Connection ID:** `github_dags`
3. **Type:** Git
4. **Host:** `https://github.com/YOUR_USERNAME/airflow-dags.git`

### Auto-Sync DAGs
```powershell
# In container, add to crontab
docker-compose exec airflow crontab -e

# Add this line:
* * * * * cd /opt/airflow/dags && git pull origin main
```

---

## Test DAG Syncing

```powershell
# Push change to GitHub
git push origin main

# DAGs auto-sync every minute
# Monitor: docker-compose logs -f airflow

# Check processor behavior
docker-compose exec airflow tail -f /opt/airflow/logs/dag_processor_manager/dag_processor_manager.log
```

---

## Common Commands

```powershell
# View logs
docker-compose logs -f airflow

# List DAGs
docker-compose exec airflow airflow dags list

# Stop
docker-compose down

# Restart
docker-compose restart airflow
```

---

## That's It! 🎉

Docker + GitHub + Airflow 3.1.5 all set up!
