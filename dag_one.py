from airflow import DAG
from airflow.operators.dummy import DummyOperator
from datetime import datetime

DAG('git_dag_one', start_date=datetime(2025, 1, 1), schedule=None)
DummyOperator(task_id='dummy_task', dag=dag)