# Airflow 3.1.5 Git DAG Syncing - Processor Behavior Test Guide

## Overview
This test setup validates how Apache Airflow 3.1.5's DAG processor behaves when DAGs are frequently synced from a Git repository. The goal is to understand if the processor reprocesses all DAGs unnecessarily, consuming CPU resources.

## Problem Statement
The client reports:
- Git syncing DAGs every minute
- All DAGs are being reprocessed even if unchanged
- DAG processor is resource-intensive
- High CPU usage with each processing cycle

## Solution: New Git Provider Package
Apache Airflow 3.1.5 introduces the `apache-airflow-providers-git` package which provides:
- Native Git integration without deprecated GSync operator
- SSH authentication support via deploy keys
- Efficient DAG bundle configuration
- Improved security and performance

## Setup Structure

```
~/airflow_test/
├── dags_repo/                    # Git repository for DAGs
│   └── dags/
│       ├── sample_dag.py
│       └── monitoring_dag.py
└── airflow_home/                 # Airflow installation
    ├── venv/                     # Python virtual environment
    ├── airflow.db                # SQLite database
    ├── dags/                     # Synced DAGs folder
    ├── logs/                     # Airflow logs
    └── plugins/                  # Custom plugins
```

## Installation Steps

### 1. Run Setup Script (in WSL)
```bash
wsl bash setup_airflow_3.1.5.sh
```

This will:
- Initialize Git repository with sample DAGs
- Create Python virtual environment
- Install Airflow 3.1.5 and Git provider
- Initialize Airflow database
- Create monitoring and test scripts

### 2. Activate Environment
```bash
cd ~/airflow_test/airflow_home
source venv/bin/activate
export AIRFLOW_HOME=~/airflow_test/airflow_home
```

### 3. Start Airflow Components

**Terminal 1 - Webserver:**
```bash
airflow webserver --port 8080
```
Access at: http://localhost:8080

**Terminal 2 - Scheduler:**
```bash
airflow scheduler
```

**Terminal 3 - Monitor (optional):**
```bash
bash ~/airflow_test/monitor_processor.sh
```

## Key Configuration Settings (airflow.cfg)

### DAG Processor Settings
```ini
[core]
min_file_process_interval = 10       # Minimum seconds between DAG scans
dag_file_processor_timeout = 30      # Timeout for DAG file processor
```

### Performance Tuning
```ini
[scheduler]
max_dagruns_to_create_per_loop = 10
max_tis_per_query = 512
dag_dir_list_interval = 300          # Seconds between DAG directory scans
```

## Testing Procedure

### Test 1: Monitor Initial Processing
```bash
# In Terminal 3, run monitor script
bash ~/airflow_test/monitor_processor.sh

# Watch output for 2-3 minutes to see normal processor behavior
```

### Test 2: Trigger Git Sync (No Changes)
```bash
# Run test script
bash ~/airflow_test/test_git_sync.sh

# Observe if processor reprocesses DAGs
# Check logs: tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log
```

### Test 3: Modify DAG and Resync
```bash
# Edit a DAG in dags_repo/dags/
# Run git commit and push

# Watch processor logs to see if it detects actual changes
# Compare with Test 2 (where no real changes were made)
```

## Key Metrics to Monitor

1. **DAG Parse Time**: How long takes to parse each DAG
2. **Reprocessing Frequency**: How often are unchanged DAGs reprocessed
3. **CPU Usage**: Monitor system CPU when processor runs
4. **Log Output**: Check for "DAG file changed" vs "DAG file unchanged" messages

## Expected Behavior with Airflow 3.1.5 Git Provider

✅ **Optimal Scenario:**
- DAG processor only reprocesses when file hash changes
- Unchanged DAGs are skipped
- Git syncing doesn't trigger unnecessary parsing
- CPU usage remains low between actual DAG changes

❌ **Current Problem (Without Fix):**
- Every sync triggers full DAG reprocessing
- CPU spikes with each minute's sync
- Resource waste on parsing unchanged DAGs

## Logs to Monitor

```bash
# DAG Processor Manager
tail -f ~/airflow_test/airflow_home/logs/dag_processor_manager/dag_processor_manager.log

# Scheduler
tail -f ~/airflow_test/airflow_home/logs/scheduler/

# Web Server
tail -f ~/airflow_test/airflow_home/logs/webserver/

# All logs
tail -f ~/airflow_test/airflow_home/logs/**/*.log
```

## Git Connection Configuration

In Airflow UI:
1. Go to Admin > Connections
2. Create new connection:
   - **Connection ID**: `git_repo`
   - **Connection Type**: `Git`
   - **Host**: `file:///home/jawad/airflow_test/dags_repo` (local) or your GitHub URL
   - **Port**: 22 (for SSH)
   - **Extra**: (JSON with SSH key if using remote repo)

## Performance Baseline

Record these metrics before and after optimization:

| Metric | Baseline | After Optimization |
|--------|----------|-------------------|
| DAGs reprocessed per sync | ? | Ideally 0 |
| Processor CPU time | ? | Lower |
| Average parse time per DAG | ? | Consistent |
| Memory usage | ? | Stable |

## Troubleshooting

### Issue: Airflow won't start
```bash
# Check database
cd ~/airflow_test/airflow_home
airflow db check

# Reset database (careful!)
airflow db reset --yes
```

### Issue: Git connection fails
```bash
# Test git access
git clone file:///home/jawad/airflow_test/dags_repo test_clone
rm -rf test_clone
```

### Issue: High CPU still present
1. Check `min_file_process_interval` in airflow.cfg
2. Verify Git sync script isn't running too frequently
3. Check for syntax errors in DAGs: `airflow dags list-import-errors`

## References

- [Apache Airflow 3.1.5 Docs](https://airflow.apache.org/docs/apache-airflow/3.1.5/)
- [Git Provider Package](https://airflow.apache.org/docs/apache-airflow-providers-git/stable/)
- [DAG Processor Configuration](https://airflow.apache.org/docs/apache-airflow/3.1.5/core-concepts/dags.html#dag-processor)
- [Scheduler Configuration](https://airflow.apache.org/docs/apache-airflow/3.1.5/configurations-ref.html#scheduler)

## Contact & Support

For issues or questions about this test setup, refer to:
- Airflow documentation
- Git provider plugin documentation
- Client requirements and performance benchmarks
