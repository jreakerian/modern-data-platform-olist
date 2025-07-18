from __future__ import annotations

import pendulum
from airflow.models.dag import DAG
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator

with DAG(
    dag_id="dbt_cloud_olist_pipeline",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    schedule=None,
    catchup=False,
    doc_md="""
    ### Olist E-commerce dbt Cloud Pipeline
    This DAG triggers a dbt Cloud job to transform the Olist e-commerce data.
    """,
    tags=["dbt-cloud"],
) as dag:
    trigger_dbt_cloud_job = DbtCloudRunJobOperator(
        task_id="trigger_dbt_build_job",
        dbt_cloud_conn_id="dbt_cloud_default",
        job_id=70471823485775,
        check_interval=60,
        timeout=3600,
        wait_for_termination=True,
        trigger_reason=f"Triggered via Airflow by task {{ti.task_id}} in the {{ti.dag_id}} DAG.",
    )