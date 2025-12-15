#!/bin/bash

echo "Resetting Airflow database and creating admin user..."

cd ~/airflow_test/airflow_home
source venv/bin/activate
export AIRFLOW_HOME=~/airflow_test/airflow_home

# Delete old database
echo "Removing old database..."
rm -f airflow.db

# Create new database
echo "Creating new database..."
airflow db migrate

# Create admin user
echo "Creating admin user..."
airflow users create \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Login credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Start Airflow with:"
echo "  airflow standalone"
