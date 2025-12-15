#!/bin/bash
# Initialize Airflow DB
cd ~/airflow_test/airflow_home
source venv/bin/activate
export AIRFLOW_HOME=~/airflow_test/airflow_home
airflow db migrate
echo "Database initialized!"
