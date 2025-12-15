FROM apache/airflow:3.1.5-python3.12

# Install Git provider and additional dependencies
RUN pip install --no-cache-dir apache-airflow-providers-git apache-airflow==3.1.5

# Set working directory
WORKDIR /opt/airflow

# Create required directories
RUN mkdir -p /opt/airflow/dags /opt/airflow/logs /opt/airflow/plugins /opt/airflow/.ssh

# Copy any initial DAGs if they exist (will be mounted in docker-compose)
# COPY dags/ /opt/airflow/dags/

# Expose ports
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

# Default command
CMD ["airflow", "standalone"]
