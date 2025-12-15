#!/usr/bin/env python3
import sqlite3
import os
import hashlib
import base64

# Simple password hashing (pbkdf2)
def hash_password(password):
    """Simple password hash similar to werkzeug"""
    salt = b'airflow'
    iterations = 260000
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, iterations, dklen=32)
    return f"pbkdf2:sha256:{iterations}${base64.b64encode(key).decode()}"

# Create admin user using direct database connection
db_path = '/home/jawad/airflow_test/airflow_home/airflow.db'

if not os.path.exists(db_path):
    print(f"Error: Database not found at {db_path}")
    exit(1)

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Hash the password
hashed_password = hash_password('admin')

# Insert admin user into ab_user table
try:
    cursor.execute("""
        INSERT OR REPLACE INTO ab_user 
        (username, password, active, email, first_name, last_name)
        VALUES (?, ?, ?, ?, ?, ?)
    """, ('admin', hashed_password, 1, 'admin@example.com', 'Admin', 'User'))
    
    conn.commit()
    print("✅ Admin user created/updated!")
    print("Username: admin")
    print("Password: admin")
except Exception as e:
    print(f"❌ Error: {e}")
finally:
    conn.close()
