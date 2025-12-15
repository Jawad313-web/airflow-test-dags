#!/bin/bash

# Airflow 3.1.5 Git DAG Syncing and Processor Behavior Test
# This script tests how the DAG processor behaves when DAGs are synced from Git

set -e

echo "=========================================="
echo "Airflow 3.1.5 Git DAG Sync Test Setup"
echo "=========================================="

# Create directories
mkdir -p ~/airflow_test/{dags_repo,airflow_home,dags_repo/{dags,logs}}
cd ~/airflow_test

# Initialize Git repository for DAGs
echo -e "\n1. Initializing Git repository for DAGs..."
cd dags_repo
git init
git config user.name "Airflow Test"
git config user.email "test@airflow.local"

# Create initial DAG
echo -e "\n2. Creating initial sample DAG..."
mkdir -p dags
cat > dags/sample_dag.py << 'DAGEOF'
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
    'sample_dag',
    default_args=default_args,
    description='Sample DAG from Git Repository',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['git-synced'],
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

# Create another DAG
cat > dags/monitoring_dag.py << 'DAGEOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
}

dag = DAG(
    'monitoring_dag',
    default_args=default_args,
    description='Monitoring DAG',
    schedule_interval=timedelta(hours=1),
    catchup=False,
    tags=['monitoring', 'git-synced'],
)

check_task = BashOperator(
    task_id='check_system',
    bash_command='echo "System check at $(date)" && df -h | head -5',
    dag=dag,
)

check_task
DAGEOF

# Commit to Git
git add dags/
git commit -m "Initial commit: Add sample and monitoring DAGs"

echo -e "\n3. Creating initial Git commit with DAGs"
git log --oneline

# Create Airflow home
echo -e "\n4. Setting up Airflow environment in airflow_home..."
cd ~/airflow_test/airflow_home

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Airflow 3.1.5 with Git provider
echo -e "\n5. Installing Apache Airflow 3.1.5 and Git provider..."
pip install --quiet --upgrade pip setuptools wheel
pip install --quiet apache-airflow==3.1.5
pip install --quiet apache-airflow-providers-git

# Create Airflow directories
mkdir -p dags logs plugins

# Initialize database
echo -e "\n6. Initializing Airflow database..."
export AIRFLOW_HOME=~/airflow_test/airflow_home
airflow db migrate

# Create Airflow connections (for Git)
echo -e "\n7. Creating Git connection in Airflow..."
airflow connections add 'git_repo' \
    --conn-type 'git' \
    --conn-host 'file:///home/jawad/airflow_test/dags_repo' \
    --conn-port '22' \
    2>/dev/null || echo "Connection may already exist"

# Create monitoring script
echo -e "\n8. Creating DAG processor monitoring script..."
cat > ~/airflow_test/monitor_processor.sh << 'MONITOREOF'
#!/bin/bash

AIRFLOW_HOME=~/airflow_test/airflow_home
export AIRFLOW_HOME

echo "=========================================="
echo "DAG Processor Behavior Monitor"
echo "=========================================="
echo "Monitoring DAG processor with 10-second intervals"
echo "Watch for repeated processing of unchanged DAGs"
echo ""

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Checking DAG processor..."
    
    # Count DAGs in airflow_home/dags
    dag_count=$(find $AIRFLOW_HOME/dags -name "*.py" -type f | wc -l)
    echo "  - DAGs in local folder: $dag_count"
    
    # Show recent logs from DAG processor
    if [ -f "$AIRFLOW_HOME/logs/dag_processor_manager/dag_processor_manager.log" ]; then
        echo "  - Recent processor activity:"
        tail -n 3 "$AIRFLOW_HOME/logs/dag_processor_manager/dag_processor_manager.log" 2>/dev/null | sed 's/^/    /'
    fi
    
    # Show Airflow DB stats
    echo "  - DAG runs in DB: $(python3 -c "from airflow.models import DagRun; from airflow import settings; from sqlalchemy import func; session = settings.Session(); print(session.query(func.count(DagRun.id)).scalar())" 2>/dev/null || echo 'N/A')"
    
    echo ""
    sleep 10
done
MONITOREOF

chmod +x ~/airflow_test/monitor_processor.sh

# Create sync test script
echo -e "\n9. Creating Git DAG sync test script..."
cat > ~/airflow_test/test_git_sync.sh << 'SYNCEOF'
#!/bin/bash

REPO_DIR=~/airflow_test/dags_repo
DAGS_DIR=~/airflow_test/airflow_home/dags
AIRFLOW_HOME=~/airflow_test/airflow_home
export AIRFLOW_HOME

echo "=========================================="
echo "Git DAG Sync Test"
echo "=========================================="
echo ""

# Test 1: Initial pull
echo "TEST 1: Initial Git pull (no changes)"
echo "----"
cd $DAGS_DIR
git clone file://$REPO_DIR . 2>/dev/null || git pull 2>/dev/null || echo "First clone..."
echo "DAGs synced. Count: $(ls *.py 2>/dev/null | wc -l)"
echo ""

# Test 2: Modify DAG in repository (without changing logic)
echo "TEST 2: Modifying DAG in repository (whitespace change only)"
echo "----"
cd $REPO_DIR
sed -i "s/tags=\['git-synced'\]/tags=['git-synced']  # Modified/g" dags/sample_dag.py
git add dags/sample_dag.py
git commit -m "Minor change to sample_dag" || echo "No changes to commit"
echo "Repository updated"
echo ""

# Test 3: Second pull
echo "TEST 3: Second Git pull (check if DAGs are reprocessed)"
echo "----"
cd $DAGS_DIR
git pull 2>/dev/null || echo "Pull completed"
echo "DAGs synced again. Count: $(ls *.py 2>/dev/null | wc -l)"
echo ""

# Test 4: Pull without changes
echo "TEST 4: Third Git pull (no actual changes in DAG content)"
echo "----"
cd $DAGS_DIR
git pull 2>/dev/null || echo "Pull completed (no changes)"
echo "Check if processor reprocesses DAGs unnecessarily..."
echo ""

echo "=========================================="
echo "Test completed. Monitor processor logs."
echo "=========================================="
SYNCEOF

chmod +x ~/airflow_test/test_git_sync.sh

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Start Airflow webserver:"
echo "   cd ~/airflow_test/airflow_home"
echo "   source venv/bin/activate"
echo "   export AIRFLOW_HOME=~/airflow_test/airflow_home"
echo "   airflow webserver --port 8080 &"
echo ""
echo "2. Start Airflow scheduler:"
echo "   cd ~/airflow_test/airflow_home"
echo "   source venv/bin/activate"
echo "   export AIRFLOW_HOME=~/airflow_test/airflow_home"
echo "   airflow scheduler &"
echo ""
echo "3. Monitor DAG processor:"
echo "   bash ~/airflow_test/monitor_processor.sh"
echo ""
echo "4. Run Git sync test:"
echo "   bash ~/airflow_test/test_git_sync.sh"
echo ""
echo "Web UI: http://localhost:8080"
echo "=========================================="
