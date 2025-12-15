#!/bin/bash

# Setup Airflow 3.1.4 in WSL with Git DAG syncing for testing
# Tests DAG processor behavior when DAGs are synced from Git
set -e

echo "=== Airflow 3.1.4 Git DAG Sync Setup ==="

# Create working directories
AIRFLOW_HOME=$HOME/airflow
DAG_REPO=$HOME/dag_repository
SYNC_INTERVAL=60  # seconds

mkdir -p $AIRFLOW_HOME
mkdir -p $DAG_REPO

# Set environment variable
export AIRFLOW_HOME

echo "1. Setting up Python virtual environment..."
cd $AIRFLOW_HOME
python3 -m venv venv
source venv/bin/activate

echo "2. Installing Airflow 3.1.4 with Git provider..."
pip install --upgrade pip setuptools wheel
pip install apache-airflow==3.1.4
pip install apache-airflow-providers-git

echo "3. Initializing Airflow database..."
airflow db migrate

echo "4. Creating Airflow user..."
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@airflow.local \
    --password admin || echo "Admin user may already exist"

echo "5. Setting up Git repository for DAGs..."
cd $DAG_REPO
git init
git config user.email "airflow@test.local"
git config user.name "Airflow Test"

# Create sample DAG
cat > sample_dag.py << 'DAGEOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'sample_dag_from_git',
    default_args=default_args,
    description='Sample DAG synced from Git',
    schedule_interval=timedelta(days=1),
    catchup=False,
)

task1 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag,
)

task2 = BashOperator(
    task_id='sleep',
    bash_command='sleep 5',
    dag=dag,
)

task1 >> task2
DAGEOF

git add .
git commit -m "Initial DAG commit"

echo "6. Configuring Airflow for optimal DAG processing..."
mkdir -p $AIRFLOW_HOME/dags

# Update Airflow config to reduce unnecessary reprocessing
cat >> $AIRFLOW_HOME/airflow.cfg << 'CONFEOF'

[core]
dags_folder = /root/airflow/dags
dag_ignore_file_syntax = glob
max_active_runs_per_dag = 1
max_active_tasks_per_dagrun = 16
dag_file_processor_timeout = 50

[scheduler]
dag_dir_list_interval = 300
catchup_by_default = False
max_dagruns_to_create_per_loop = 10
min_file_process_interval = 30
CONFEOF

echo "7. Creating DAG sync script..."

cat > $AIRFLOW_HOME/sync_dags_from_git.py << 'SYNCEOF'
#!/usr/bin/env python3
import os, subprocess, time, hashlib, json
from pathlib import Path
from datetime import datetime

AIRFLOW_HOME = os.environ.get('AIRFLOW_HOME')
DAG_REPO = os.path.expanduser('~/dag_repository')
DAGS_FOLDER = os.path.join(AIRFLOW_HOME, 'dags')
STATUS_FILE = os.path.join(AIRFLOW_HOME, 'sync_status.json')

def get_file_hash(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(4096), b""):
            sha256.update(block)
    return sha256.hexdigest()

def load_status():
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE, 'r') as f:
            return json.load(f)
    return {'last_hashes': {}}

def save_status(status):
    with open(STATUS_FILE, 'w') as f:
        json.dump(status, f, indent=2)

def sync_dags():
    os.makedirs(DAGS_FOLDER, exist_ok=True)
    subprocess.run(['git', 'pull'], cwd=DAG_REPO, capture_output=True)
    
    status = load_status()
    old_hashes = status.get('last_hashes', {})
    new_hashes = {}
    changes = False
    
    for file in Path(DAG_REPO).glob('*.py'):
        if not file.name.startswith('_'):
            src, dst = str(file), os.path.join(DAGS_FOLDER, file.name)
            new_hash = get_file_hash(src)
            new_hashes[file.name] = new_hash
            if file.name not in old_hashes or old_hashes[file.name] != new_hash:
                changes = True
            with open(src) as sf, open(dst, 'w') as df:
                df.write(sf.read())
    
    status['last_hashes'] = new_hashes
    status['changes'] = changes
    status['last_sync'] = datetime.now().isoformat()
    save_status(status)
    
    print(f"[{datetime.now()}] Sync complete. Changes: {changes}")

while True:
    sync_dags()
    time.sleep(60)
SYNCEOF

chmod +x $AIRFLOW_HOME/sync_dags_from_git.py

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Run these commands to start Airflow:"
echo "  export AIRFLOW_HOME=\$HOME/airflow"
echo "  source \$AIRFLOW_HOME/venv/bin/activate"
echo ""
echo "Terminal 1: airflow webserver --port 8080"
echo "Terminal 2: airflow scheduler"
echo "Terminal 3: python3 \$AIRFLOW_HOME/sync_dags_from_git.py"
echo ""
echo "Access UI: http://localhost:8080 (admin/admin)"
cd ~/airflow_test/airflow_home
python3 -m venv venv
source venv/bin/activate

# Install Airflow 3.1.5 with Git provider
pip install --upgrade pip
pip install apache-airflow==3.1.5
pip install apache-airflow-providers-git

# Initialize Airflow database
export AIRFLOW_HOME=~/airflow_test/airflow_home
airflow db migrate

echo "Airflow setup complete!"
echo "To start Airflow:"
echo "  cd ~/airflow_test/airflow_home"
echo "  source venv/bin/activate"
echo "  export AIRFLOW_HOME=~/airflow_test/airflow_home"
echo "  airflow standalone"
