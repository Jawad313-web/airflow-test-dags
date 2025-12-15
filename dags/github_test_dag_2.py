"""
Test DAG 2 - Hourly task with multiple steps
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'retries': 0,
}

dag = DAG(
    'github_test_dag_2',
    default_args=default_args,
    description='Test DAG 2 from GitHub with hourly schedule',
    schedule_interval='@hourly',
    start_date=datetime(2025, 12, 15),
    catchup=False,
    tags=['github-test'],
)

start_task = BashOperator(
    task_id='start',
    bash_command='echo "Starting GitHub DAG 2"',
    dag=dag,
)

process_task = BashOperator(
    task_id='process',
    bash_command='sleep 5 && echo "Processing complete"',
    dag=dag,
)

end_task = BashOperator(
    task_id='end',
    bash_command='echo "Ending GitHub DAG 2 - $(date)"',
    dag=dag,
)

start_task >> process_task >> end_task
