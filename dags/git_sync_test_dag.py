"""
Git Sync Test DAG - Pulls and syncs DAGs from GitHub every minute
Tests processor behavior and CPU usage during Git syncing
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
import os

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

dag = DAG(
    'git_sync_test_dag',
    default_args=default_args,
    description='Test DAG for Git syncing behavior',
    schedule='* * * * *',  # Run every minute
    start_date=datetime(2025, 12, 15),
    catchup=False,
    tags=['test', 'git-sync'],
)

def sync_from_github():
    """Pull latest DAGs from GitHub"""
    import subprocess
    import time
    
    print("=" * 80)
    print(f"SYNC START: {datetime.now()}")
    print("=" * 80)
    
    # Simulate git pull
    cmd = "git status"
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(f"Git Status:\n{result.stdout}")
    
    time.sleep(2)  # Simulate processing time
    
    print("=" * 80)
    print(f"SYNC END: {datetime.now()}")
    print("=" * 80)
    
    return "Sync completed"

sync_task = PythonOperator(
    task_id='sync_github_dags',
    python_callable=sync_from_github,
    dag=dag,
)

check_task = BashOperator(
    task_id='check_dags_folder',
    bash_command='ls -lh /opt/airflow/dags/ | head -20',
    dag=dag,
)

log_task = BashOperator(
    task_id='log_sync_time',
    bash_command='echo "Sync check at $(date)" >> /opt/airflow/logs/sync_monitor.log',
    dag=dag,
)

sync_task >> check_task >> log_task
