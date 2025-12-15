# Docker Setup - Step by Step

## Prerequisites Check

✅ **Required:**
- Docker Desktop installed
- Docker Compose installed
- Git installed

---

## Step-by-Step Setup

### Step 1: Verify Docker Installation
```powershell
docker --version
docker-compose --version
```

Expected output:
```
Docker version 24.x.x
Docker Compose version v2.x.x
```

---

### Step 2: Build Docker Image
```powershell
cd c:\Jawad\airflow-git-dag-test

docker-compose build
```

This will:
- Download Airflow 3.1.5 base image
- Install Git provider
- Create Airflow Docker image
- Takes 5-10 minutes first time

---

### Step 3: Start Airflow + PostgreSQL
```powershell
docker-compose up -d
```

This will:
- Start PostgreSQL database container
- Start Airflow container
- Initialize database
- Create admin user (admin/admin)
- Start webserver and scheduler

Check status:
```powershell
docker-compose ps
```

---

### Step 4: Access Airflow UI
Open browser:
```
http://localhost:8080
```

Login:
- **Username:** `admin`
- **Password:** `admin`

---

### Step 5: Verify DAGs are Loading
```powershell
docker-compose exec airflow airflow dags list
```

You should see:
- `sample_dag`
- `monitoring_dag`
- Example DAGs from Airflow

---

## Troubleshooting

### Port 8080 Already in Use
```powershell
# Find process using port 8080
netstat -ano | findstr :8080

# Kill it
taskkill /PID <PID> /F

# Or change port in docker-compose.yml:
# Change "8080:8080" to "8081:8080"
```

### Docker Daemon Not Running
```powershell
# Start Docker Desktop application
# Or run:
docker ps

# If error, start Docker service
```

### Permission Denied
```powershell
# Run PowerShell as Administrator
# Then try docker-compose commands again
```

### Database Connection Error
```powershell
# Stop and remove containers
docker-compose down -v

# Start fresh
docker-compose up -d
```

### View Logs
```powershell
# All logs
docker-compose logs

# Just Airflow
docker-compose logs airflow

# Follow logs (live)
docker-compose logs -f airflow

# Follow logs last 100 lines
docker-compose logs --tail=100 -f airflow
```

---

## Common Docker Commands

```powershell
# Stop all containers
docker-compose down

# Stop but keep data
docker-compose stop

# Restart
docker-compose restart airflow

# Remove everything including volumes
docker-compose down -v

# Execute command in container
docker-compose exec airflow airflow dags list

# Access container bash
docker-compose exec airflow bash

# View specific logs
docker-compose exec airflow tail -f /opt/airflow/logs/scheduler/*/latest.log
```

---

## GitHub Integration Setup

### Step 1: Create GitHub Repository

Go to https://github.com/new

Create:
- **Repository name:** `airflow-dags`
- **Description:** "Airflow DAGs Repository"
- **Public or Private:** Your choice
- Click **Create repository**

### Step 2: Push Local DAGs to GitHub

```powershell
# Initialize git
cd c:\Jawad\airflow-git-dag-test
git remote add github https://github.com/YOUR_USERNAME/airflow-dags.git
git branch -M main
git add dags/
git commit -m "Initial Airflow DAGs"
git push -u github main
```

### Step 3: Configure GitHub Connection in Airflow

Open http://localhost:8080

1. Click **Admin** menu
2. Click **Connections**
3. Click **+ Create a new connection**
4. Fill in:
   - **Connection ID:** `github_repo`
   - **Connection Type:** `Git`
   - **Host:** `https://github.com/YOUR_USERNAME/airflow-dags.git`
   - **Login:** (leave blank for public repos)
   - **Password:** (leave blank for public repos)
5. Click **Save**

### Step 4: Create a DAG to Sync from GitHub

Create file: `dags/git_sync_dag.py`

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

dag = DAG(
    'git_sync_task',
    default_args=default_args,
    schedule_interval=timedelta(minutes=1),  # Sync every minute
    catchup=False,
)

sync_task = BashOperator(
    task_id='sync_from_github',
    bash_command='cd /opt/airflow/dags && git pull github main || echo "Already up to date"',
    dag=dag,
)
```

### Step 5: Test Syncing

1. Make a change to a DAG in GitHub
2. DAG will auto-sync every minute
3. Monitor logs:
```powershell
docker-compose logs -f airflow | grep git
```

---

## Testing Client Requirements

### Test Scenario 1: No Changes
```powershell
# Monitor logs
docker-compose logs -f airflow

# Re-trigger sync
docker-compose exec airflow bash -c "cd /opt/airflow/dags && git pull"

# Check: Did processor reprocess all DAGs?
# This shows the PROBLEM
```

### Test Scenario 2: Modify DAG
```powershell
# Edit a DAG on GitHub
# Commit and push

# Monitor DAGs being reprocessed
docker-compose logs -f airflow | grep "Importing"

# Check: Did it reprocess only changed DAGs?
# This shows the SOLUTION
```

### Test Scenario 3: Monitor Resources
```powershell
# Watch container stats
docker stats

# Look at CPU/Memory usage during sync
```

---

## Next Steps

1. ✅ Run `docker-compose build`
2. ✅ Run `docker-compose up -d`
3. ✅ Open http://localhost:8080
4. ✅ Create GitHub repository
5. ✅ Configure GitHub connection
6. ✅ Test DAG syncing
7. ✅ Monitor processor behavior

---

## Summary

✅ **Docker:** Airflow 3.1.5 running in container
✅ **Database:** PostgreSQL for data storage
✅ **GitHub:** Ready for DAG syncing
✅ **Scheduler:** Auto-syncs DAGs every minute
✅ **Monitoring:** Logs to track processor behavior
✅ **Testing:** Ready to demonstrate optimization

Everything is set up to test your client's Git syncing scenario!
