# Docker + GitHub Airflow 3.1.5 Setup

## Requirements

- Docker Desktop installed
- GitHub account (for DAG repository)
- Git installed

---

## Quick Start with Docker

### Step 1: Build Docker Image
```bash
cd c:\Jawad\airflow-git-dag-test
docker-compose build
```

### Step 2: Start Airflow
```bash
docker-compose up -d
```

### Step 3: Access Airflow
```
http://localhost:8080
Username: admin
Password: admin
```

### Step 4: Check Logs
```bash
docker-compose logs -f airflow
```

---

## GitHub Integration

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create repository: `airflow-dags`
3. Clone it locally

### Step 2: Push DAGs to GitHub

```bash
cd ~/airflow-dags-repo
git add dags/
git commit -m "Initial DAGs"
git push origin main
```

### Step 3: Configure GitHub Connection in Airflow

In Airflow UI (http://localhost:8080):

1. **Admin > Connections > + Create Connection**
2. Fill in:
   - **Connection ID:** `github_dags`
   - **Connection Type:** `Git`
   - **Host:** `https://github.com/YOUR_USERNAME/airflow-dags.git`
   - **Extra (JSON):**
   ```json
   {
     "ssh_key_path": "/opt/airflow/.ssh/id_rsa",
     "known_hosts_file": "/opt/airflow/.ssh/known_hosts"
   }
   ```

### Step 4: Sync DAGs from GitHub

Option A: Manual sync in Airflow
```bash
# In a DAG, use GitSync operator
from airflow_git_sync import GitSyncOperator

dag = DAG(...)
sync_task = GitSyncOperator(
    task_id='sync_from_github',
    git_conn_id='github_dags',
    repo_name='airflow-dags',
    branch='main',
    dag=dag,
)
```

Option B: Automated cron sync
```bash
# Add to crontab
* * * * * cd /opt/airflow/dags && git pull origin main
```

---

## Docker Commands

### Start Airflow
```bash
docker-compose up -d
```

### Stop Airflow
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f airflow
```

### Restart
```bash
docker-compose restart airflow
```

### Execute Commands
```bash
docker-compose exec airflow airflow dags list
docker-compose exec airflow airflow users list
```

### Remove Everything
```bash
docker-compose down -v
```

---

## Project Structure

```
c:\Jawad\airflow-git-dag-test\
├── Dockerfile              # Airflow Docker image
├── docker-compose.yml      # Docker Compose configuration
├── dags/                   # DAGs folder (synced from GitHub)
├── logs/                   # Airflow logs
├── plugins/                # Custom plugins
└── config/                 # Airflow config files
```

---

## Testing Git Syncing

### Setup:
1. Create GitHub repo with DAGs
2. Configure GitHub connection in Airflow
3. Setup automatic sync (cron or operator)

### Test Scenarios:

**Scenario 1: No Changes**
```bash
# Sync without changing DAGs
# Monitor: CPU usage and processor logs
# Expected: No reprocessing if using smart change detection
```

**Scenario 2: Modify One DAG**
```bash
# Edit one DAG in GitHub
# Push changes
# Sync again
# Monitor: Only modified DAG should reprocess
```

**Scenario 3: Add New DAG**
```bash
# Add new DAG to GitHub
# Push
# Sync
# Monitor: Only new DAG parsed
```

---

## Troubleshooting

### Port Already in Use
```bash
docker kill $(docker ps -q) # Kill all containers
docker-compose up -d
```

### Permission Denied
```bash
sudo docker-compose up -d
```

### Cannot Connect to Docker
```bash
# Make sure Docker Desktop is running
# Windows: Start Docker Desktop app
# Mac/Linux: sudo systemctl start docker
```

### Login Failed
```bash
docker-compose exec airflow airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com
```

---

## Benefits of Docker Setup

✅ **Isolated Environment:** Airflow runs in container
✅ **Easy Deployment:** Single docker-compose command
✅ **GitHub Integration:** Direct repo syncing
✅ **Reproducible:** Same setup everywhere
✅ **Scalable:** Easy to add more services
✅ **Clean System:** No installation mess

---

## Next Steps

1. Install Docker Desktop
2. Create GitHub repository
3. Run `docker-compose up -d`
4. Configure GitHub connection
5. Test DAG syncing
6. Monitor processor behavior
7. Measure optimization benefits
