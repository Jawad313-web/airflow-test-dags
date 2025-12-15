#!/usr/bin/env python3

import os
import sys
sys.path.insert(0, '/home/jawad/airflow_test/airflow_home/venv/lib/python3.12/site-packages')

os.environ['AIRFLOW_HOME'] = '/home/jawad/airflow_test/airflow_home'

from airflow import settings
from airflow.security import get_fernet_instance
from airflow.www.security import AppUserModelView
from werkzeug.security import generate_password_hash
import sqlite3

# Create admin user using direct database connection
db_path = '/home/jawad/airflow_test/airflow_home/airflow.db'
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Create user in ab_user table (FAB user model)
from werkzeug.security import generate_password_hash
hashed_password = generate_password_hash('admin')

cursor.execute("""
    INSERT OR REPLACE INTO ab_user 
    (username, password, active, email, first_name, last_name)
    VALUES (?, ?, ?, ?, ?, ?)
""", ('admin', hashed_password, 1, 'admin@example.com', 'Admin', 'User'))

conn.commit()
conn.close()

print("✅ Admin user created/updated successfully!")
print("Username: admin")
print("Password: admin")
