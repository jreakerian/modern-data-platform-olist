from __future__ import annotations

import logging
from datetime import timedelta

import pendulum
from airflow.models.dag import DAG
from airflow.models import Variable
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.operators.python import PythonOperator
from airflow.utils.task_group import TaskGroup

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Failure callback
# ---------------------------------------------------------------------------

def _on_failure_callback(context: dict) -> None:
    """Log structured failure context for every task failure in this DAG."""
    ti = context.get("task_instance")
    exception = context.get("exception")
    logger.error(
        "Task failure — task_id=%s | dag_id=%s | execution_date=%s | exception=%s",
        ti.task_id if ti else "unknown",
        ti.dag_id if ti else "unknown",
        context.get("execution_date", "unknown"),
        exception,
    )


# ---------------------------------------------------------------------------
# Success notification callable
# ---------------------------------------------------------------------------

def _notify_pipeline_success(**context) -> None:
    """Log a pipeline-level success message with execution context."""
    logger.info("Pipeline completed successfully for %s", context["ds"])


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

EXTERNAL_TABLES = [
    "olist_orders_dataset",
    "olist_order_items_dataset",
    "olist_order_payments_dataset",
    "olist_order_reviews_dataset",
    "olist_customers_dataset",
    "olist_sellers_dataset",
    "olist_products_dataset",
    "olist_geolocation_dataset",
    "product_category_name_translation",
]

DEFAULT_ARGS = {
    "owner": "analytics_engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "execution_timeout": timedelta(hours=2),
    "on_failure_callback": _on_failure_callback,
}

# ---------------------------------------------------------------------------
# DAG definition
# ---------------------------------------------------------------------------

with DAG(
    dag_id="olist_elt_pipeline",
    schedule="0 6 * * *",
    start_date=pendulum.datetime(2023, 1, 1, tz="UTC"),
    catchup=False,
    max_active_runs=1,
    tags=["dbt-cloud", "olist", "elt", "production"],
    default_args=DEFAULT_ARGS,
    doc_md="""\
### Olist E-commerce ELT Pipeline

**Owner:** Analytics Engineering
**Schedule:** Daily at 06:00 UTC

#### Pipeline overview

| Step | Task / Group | Description |
|------|-------------|-------------|
| 1 | `check_source_data_landed` | S3 sensor that waits for new CSV files in the `bronze/` prefix of the `project-ecommerce-lakehouse` bucket. |
| 2 | `refresh_external_tables` | Task group that issues `ALTER EXTERNAL TABLE … REFRESH` for each of the 9 Olist source tables in Snowflake. |
| 3 | `check_source_freshness` | Triggers a dbt Cloud job to run `dbt source freshness`, validating that upstream data is recent enough. |
| 4 | `run_dbt_build` | Triggers the main dbt Cloud build job (`dbt build`) to materialize staging, intermediate, and mart models. |
| 5 | `run_dbt_test` | Triggers a dbt Cloud job dedicated to running `dbt test` for data-quality assertions. |
| 6 | `generate_elementary_report` | Triggers a dbt Cloud job that generates the Elementary observability report. |
| 7 | `notify_pipeline_success` | Logs a success message. Has a 2-hour SLA to ensure the full pipeline completes on time. |

#### Connections required
- **`aws_default`** — AWS credentials with `s3:ListBucket` / `s3:GetObject` on the landing bucket.
- **`snowflake_default`** — Snowflake connection with rights to refresh external tables in `OLIST_LAKEHOUSE.RAW_BRONZE`.
- **`dbt_cloud_default`** — dbt Cloud API token (set via the dbt Cloud provider connection).

#### Airflow Variables
| Variable | Default | Purpose |
|----------|---------|---------|
| `dbt_cloud_source_freshness_job_id` | `70471823485775` | dbt Cloud job for source freshness |
| `dbt_cloud_build_job_id` | `70471823485775` | dbt Cloud job for `dbt build` |
| `dbt_cloud_test_job_id` | `70471823485775` | dbt Cloud job for `dbt test` |
| `dbt_cloud_elementary_job_id` | `70471823485775` | dbt Cloud job for Elementary report |
""",
) as dag:

    # 1 — Wait for source data in S3 ----------------------------------------
    check_source_data_landed = S3KeySensor(
        task_id="check_source_data_landed",
        bucket_key="bronze/*.csv",
        wildcard_match=True,
        bucket_name="project-ecommerce-lakehouse",
        aws_conn_id="aws_default",
        timeout=3600,
        poke_interval=300,
        mode="reschedule",
    )

    # 2 — Refresh all Snowflake external tables ------------------------------
    with TaskGroup(group_id="refresh_external_tables") as refresh_external_tables:
        for table_name in EXTERNAL_TABLES:
            SQLExecuteQueryOperator(
                task_id=f"refresh_{table_name}",
                conn_id="snowflake_default",
                sql=f"ALTER EXTERNAL TABLE OLIST_LAKEHOUSE.RAW_BRONZE.{table_name} REFRESH;",
            )

    # 3 — dbt source freshness check ----------------------------------------
    check_source_freshness = DbtCloudRunJobOperator(
        task_id="check_source_freshness",
        dbt_cloud_conn_id="dbt_cloud_default",
        job_id=int(
            Variable.get("dbt_cloud_source_freshness_job_id", default_var=70471823485775)
        ),
        trigger_reason="Source freshness check triggered by Airflow",
    )

    # 4 — dbt build ----------------------------------------------------------
    run_dbt_build = DbtCloudRunJobOperator(
        task_id="run_dbt_build",
        dbt_cloud_conn_id="dbt_cloud_default",
        job_id=int(
            Variable.get("dbt_cloud_build_job_id", default_var=70471823485775)
        ),
        check_interval=60,
        timeout=3600,
        wait_for_termination=True,
        trigger_reason="dbt build triggered by Airflow daily pipeline",
    )

    # 5 — dbt test -----------------------------------------------------------
    run_dbt_test = DbtCloudRunJobOperator(
        task_id="run_dbt_test",
        dbt_cloud_conn_id="dbt_cloud_default",
        job_id=int(
            Variable.get("dbt_cloud_test_job_id", default_var=70471823485775)
        ),
        trigger_reason="dbt test triggered by Airflow daily pipeline",
    )

    # 6 — Elementary observability report ------------------------------------
    generate_elementary_report = DbtCloudRunJobOperator(
        task_id="generate_elementary_report",
        dbt_cloud_conn_id="dbt_cloud_default",
        job_id=int(
            Variable.get("dbt_cloud_elementary_job_id", default_var=70471823485775)
        ),
        trigger_reason="Elementary report generation",
    )

    # 7 — Success notification -----------------------------------------------
    notify_pipeline_success = PythonOperator(
        task_id="notify_pipeline_success",
        python_callable=_notify_pipeline_success,
        sla=timedelta(hours=2),
    )

    # --- Dependencies -------------------------------------------------------
    (
        check_source_data_landed
        >> refresh_external_tables
        >> check_source_freshness
        >> run_dbt_build
        >> run_dbt_test
        >> generate_elementary_report
        >> notify_pipeline_success
    )
