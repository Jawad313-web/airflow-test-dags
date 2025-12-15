#!/bin/bash

echo "=========================================="
echo "Testing Client Requirements"
echo "Git DAG Syncing & Processor Behavior"
echo "=========================================="
echo ""

# Export environment
export AIRFLOW_HOME=~/airflow_test/airflow_home
source ~/airflow_test/airflow_home/venv/bin/activate

echo "Step 1: Current DAGs in Airflow"
echo "----"
airflow dags list | head -10
echo ""

echo "Step 2: Git Repository DAGs"
echo "----"
ls -la ~/airflow_test/dags_repo/dags/
echo ""

echo "Step 3: Airflow DAGs Folder"
echo "----"
ls -la ~/airflow_test/airflow_home/dags/
echo ""

echo "Step 4: Check Processor Logs (Last 10 lines)"
echo "----"
if [ -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log ]; then
    tail -10 ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log
else
    echo "Processor log not found yet. Start Airflow first."
fi
echo ""

echo "=========================================="
echo "Testing Steps:"
echo "=========================================="
echo ""
echo "1. BASELINE: Note current DAG count and processor state"
echo ""
echo "2. MODIFY: Change a DAG in the repository"
echo "   cd ~/airflow_test/dags_repo"
echo "   # Edit a DAG file"
echo "   git add ."
echo "   git commit -m 'Modified DAG'"
echo ""
echo "3. SYNC: Copy modified DAGs to Airflow"
echo "   cp ~/airflow_test/dags_repo/dags/* ~/airflow_test/airflow_home/dags/"
echo ""
echo "4. OBSERVE: Check processor behavior"
echo "   tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log"
echo ""
echo "5. MEASURE: CPU usage during processing"
echo "   ps aux | grep airflow"
echo ""
echo "=========================================="
