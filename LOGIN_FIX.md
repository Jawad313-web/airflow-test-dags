## 401 Unauthorized - Fixed

### ✅ Solution: Use `airflow standalone`

The `airflow standalone` command **automatically creates an admin user and sets a password**.

When you run:
```powershell
wsl bash -c "cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow standalone"
```

It will show output like:
```
standalone | WARNING: The user-provided admin password is not displayed here for security. 
standalone | The generated password is: xxxxxxxxxx
```

**Copy that password from the terminal output and use it!**

---

## If Password Doesn't Work:

### Method 1: Reset Database & Use Standalone
```powershell
wsl bash -c "rm -f ~/airflow_test/airflow_home/airflow.db && cd ~/airflow_test/airflow_home && source venv/bin/activate && export AIRFLOW_HOME=~/airflow_test/airflow_home && airflow standalone"
```

### Method 2: Check Terminal Output for Password
When `airflow standalone` starts, **look for the generated password in the terminal**.

Example:
```
standalone | WARNING: The user-provided admin password is not displayed here for security. 
standalone | The generated password is: abc123def456
```

Use: 
- **Username:** admin
- **Password:** abc123def456 (copy from your terminal output)

---

## Login Steps:

1. Run `airflow standalone` command above
2. **Wait for it to say "Airflow is ready"**
3. Open http://localhost:8080
4. **Check the terminal output for the auto-generated password**
5. Login with:
   - Username: `admin`
   - Password: (copy from terminal)

---

## Why This Happens:

Airflow 3.1.5 changed user management. The `airflow users create` command no longer works. Instead, `airflow standalone` automatically handles admin user creation with a secure generated password.

