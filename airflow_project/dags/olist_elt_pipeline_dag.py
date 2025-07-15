from datetime import datetime, timedelta
from airflow.providers.standard.operators.bash import BashOperator
from airflow.models.dag import DAG




default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': datetime(2024, 1, 1),
}

# Use forward slashes for paths to avoid issues with escape characters in Python.
# This path should point to the directory containing your dbt_project.yml file.
DBT_PROJECT_DIR = 'dbt_project'
# The profiles dir is often the same as the project dir, containing profiles.yml
DBT_PROFILES_DIR = DBT_PROJECT_DIR

with DAG(
    dag_id='olist_elt_pipeline_v1',
    default_args=default_args,
    description='An ELT pipeline for the Olist dataset using dbt',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['dbt', 'olist'],
) as dag:
    # This task runs your dbt models
    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command=f"dbt run --project-dir '{DBT_PROJECT_DIR}' --profiles-dir '{DBT_PROFILES_DIR}'"
    )

    # This task tests your dbt models after they have run
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command=f"dbt test --project-dir '{DBT_PROJECT_DIR}' --profiles-dir '{DBT_PROFILES_DIR}'"
    )

    dbt_run >> dbt_test