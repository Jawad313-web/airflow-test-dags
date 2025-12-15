# 🚀 DOCKER STARTUP - COPY & PASTE COMMANDS

## Prerequisites
- Docker Desktop must be installed and running
- You need about 5GB disk space

---

## Quick Start (3 Commands)

### Command 1: Build Docker Image
```powershell
cd c:\Jawad\airflow-git-dag-test
docker-compose build
```
⏱️ Takes 5-10 minutes on first run

**Wait for it to complete!**

---

### Command 2: Start Containers
```powershell
docker-compose up -d
```

Check if running:
```powershell
docker-compose ps
```

Should show:
- `airflow-postgres` ✅ Up
- `airflow-3.1.5` ✅ Up

---

### Command 3: Open Browser
```
http://localhost:8080
```

Login:
- Username: `admin`
- Password: `admin`

---

## Verify Everything Works

### List DAGs
```powershell
docker-compose exec airflow airflow dags list
```

Should show your DAGs!

### Check Logs
```powershell
docker-compose logs -f airflow
```

Press Ctrl+C to exit logs

---

## Stop / Restart Commands

**Stop (keep data):**
```powershell
docker-compose stop
```

**Start again:**
```powershell
docker-compose start
```

**Restart everything:**
```powershell
docker-compose restart
```

**Remove everything:**
```powershell
docker-compose down -v
```

---

## GitHub Setup (After Docker is Running)

### 1. Create GitHub Repo
- Go to https://github.com/new
- Name: `airflow-dags`
- Create repository

### 2. Configure in Airflow UI
- Open http://localhost:8080
- Admin > Connections > + Create
- **Connection ID:** `github_repo`
- **Type:** `Git`
- **Host:** `https://github.com/YOUR_USERNAME/airflow-dags.git`
- Save

### 3. Test Syncing
```powershell
docker-compose exec airflow bash -c "cd /opt/airflow/dags && git pull github main"
```

---

## Troubleshooting

### Docker won't start
```powershell
# Start Docker Desktop application first
# Then try: docker-compose up -d
```

### Port 8080 in use
```powershell
# Change port in docker-compose.yml
# Change: "8080:8080"
# To: "8081:8080"
# Then: docker-compose restart
```

### Database error
```powershell
# Reset everything
docker-compose down -v
docker-compose up -d
```

### Can't login
```powershell
# Recreate admin user
docker-compose exec airflow airflow users create \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com
```

---

## What Happens Next

1. ✅ Airflow 3.1.5 running in Docker
2. ✅ PostgreSQL database running
3. ✅ Webserver on http://localhost:8080
4. ✅ Scheduler auto-syncing DAGs
5. ✅ Processor monitoring DAG changes
6. ✅ Ready to test with GitHub

---

**That's it! You now have Docker + Airflow 3.1.5 + GitHub ready!** 🎉
