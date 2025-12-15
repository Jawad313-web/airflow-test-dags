"""
Test DAG 1 - Simple daily task
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

dag = DAG(
    'github_test_dag_1',
    default_args=default_args,
    description='Test DAG 1 from GitHub',
    schedule_interval='@daily',
    start_date=datetime(2025, 12, 15),
    catchup=False,
    tags=['github-test'],
)

task1 = BashOperator(
    task_id='print_hello',
    bash_command='echo "Hello from GitHub DAG 1 - $(date)"',
    dag=dag,
)

task2 = BashOperator(
    task_id='print_date',
    bash_command='date',
    dag=dag,
)

task1 >> task2
