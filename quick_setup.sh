#!/bin/bash

# Quick Setup for Airflow 3.1.5 - Step by Step

echo "========================================"
echo "Airflow 3.1.5 Quick Setup"
echo "========================================"

# Check if already set up
if [ -d ~/airflow_test/airflow_home/venv ]; then
    echo "Airflow already installed. Skipping installation."
    source ~/airflow_test/airflow_home/venv/bin/activate
    export AIRFLOW_HOME=~/airflow_test/airflow_home
    echo "Environment activated."
    exit 0
fi

echo ""
echo "Step 1: Creating directories..."
mkdir -p ~/airflow_test/{dags_repo,airflow_home/{dags,logs,plugins}}

echo "Step 2: Initializing Git repository..."
cd ~/airflow_test/dags_repo
git init > /dev/null 2>&1
git config user.name "Airflow Test" > /dev/null 2>&1
git config user.email "test@airflow.local" > /dev/null 2>&1

echo "Step 3: Creating sample DAGs..."
mkdir -p dags

cat > dags/sample_dag.py << 'EOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
}

with DAG('sample_dag', default_args=default_args, schedule_interval=timedelta(days=1), catchup=False) as dag:
    task1 = BashOperator(task_id='print_date', bash_command='date')
    task2 = BashOperator(task_id='sleep', bash_command='sleep 5')
    task1 >> task2
EOF

git add dags/ > /dev/null 2>&1
git commit -m "Initial DAGs" > /dev/null 2>&1

echo "Step 4: Setting up Python virtual environment..."
cd ~/airflow_test/airflow_home
python3 -m venv venv

echo "Step 5: Installing Airflow 3.1.5..."
source venv/bin/activate
pip install --upgrade pip setuptools wheel > /dev/null 2>&1
pip install apache-airflow==3.1.5 apache-airflow-providers-git > /dev/null 2>&1

echo "Step 6: Initializing Airflow database..."
export AIRFLOW_HOME=~/airflow_test/airflow_home
airflow db migrate > /dev/null 2>&1

echo ""
echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "To start Airflow, run these commands:"
echo ""
echo "1. Activate environment:"
echo "   cd ~/airflow_test/airflow_home"
echo "   source venv/bin/activate"
echo "   export AIRFLOW_HOME=~/airflow_test/airflow_home"
echo ""
echo "2. Start webserver:"
echo "   airflow webserver --port 8080 &"
echo ""
echo "3. Start scheduler:"
echo "   airflow scheduler &"
echo ""
echo "4. Access Airflow at: http://localhost:8080"
echo "========================================"
