from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

with DAG('git_dag_two', start_date=datetime(2025, 1, 1), schedule='@daily') as dag:
    BashOperator(task_id='print_date', bash_command='date')