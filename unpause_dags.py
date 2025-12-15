#!/usr/bin/env python3
"""
Script to unpause all test DAGs
"""
from airflow.models import DagModel
from sqlalchemy.orm import Session
from airflow.settings import engine

dags_to_unpause = ['git_sync_test_dag', 'github_test_dag_1', 'github_test_dag_2', 'sample_dag']

session = Session(bind=engine)
for dag_id in dags_to_unpause:
    dag = session.query(DagModel).filter(DagModel.dag_id == dag_id).first()
    if dag:
        dag.is_paused = False
        print(f"Unpaused: {dag_id}")
    else:
        print(f"DAG not found: {dag_id}")
session.commit()
session.close()

print("\nAll DAGs unpaused successfully!")
