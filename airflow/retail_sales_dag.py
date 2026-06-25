"""
Airflow DAG: orchestrates the dbt run + test cycle for the retail pipeline.

Setup (local, via Astronomer CLI - easiest path):
  1. brew install astro          (or see astronomer.io/docs/astro/cli/install-cli)
  2. astro dev init               (run inside a new folder, e.g. retail_pipeline/airflow)
  3. Copy this file into the generated `dags/` folder
  4. Make sure dbt-core + dbt-snowflake are installed in the Airflow environment
     (add to requirements.txt: dbt-core, dbt-snowflake)
  5. astro dev start
  6. Open localhost:8080, trigger the DAG manually or wait for the schedule
"""

from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Path to your dbt project INSIDE the Airflow container/environment.
# If running astro dev, mount or copy dbt_retail/ into the project and adjust this path.
DBT_PROJECT_DIR = "/usr/local/airflow/dbt_retail"
DBT_PROFILES_DIR = "/usr/local/airflow/.dbt"

default_args = {
    "owner": "princy",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="retail_sales_dbt_pipeline",
    default_args=default_args,
    description="Run dbt models + tests for the retail sales pipeline",
    schedule_interval="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["retail", "dbt", "snowflake"],
) as dag:

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt run --profiles-dir {DBT_PROFILES_DIR}",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt test --profiles-dir {DBT_PROFILES_DIR}",
    )

    dbt_run >> dbt_test
