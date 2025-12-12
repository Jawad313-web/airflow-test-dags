from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

dag = DAG('hello_from_git', start_date=datetime(2025, 1, 1), schedule=None, catchup=False)

t1 = BashOperator(task_id='say_hi', bash_command='echo "Hello from Git-synced DAG!"', dag=dag)