# Retail Sales Analytics Pipeline (2019–2023, India)

End-to-end ELT pipeline: Snowflake + dbt + Airflow + Plotly Dash, built on the
[Indian Store Data](https://www.kaggle.com/datasets/abuhumzakhan/store-data)
dataset (100K rows, 2019–2023), extending operational analytics work from a
prior retail ETL/dashboard internship.

## Architecture

```
CSV (Kaggle) -> Snowflake (raw) -> dbt (staging -> intermediate -> marts) -> Airflow (daily orchestration) -> Dash dashboard
```

## Setup steps

### 1. Download the dataset
Download `store_sales_data.csv` from Kaggle (link above). Check the real header
row against `snowflake_setup.sql` — adjust column names there if they differ.

### 2. Snowflake
1. Sign up for a [free trial](https://signup.snowflake.com/).
2. Open a SQL worksheet, paste in `snowflake_setup.sql`, run section by section.
3. Use Snowsight's "Load Data" button to upload the CSV into `RAW.STORE_SALES`
   (easiest — no staging/COPY INTO needed).
4. Confirm row count with the sanity-check query at the bottom of the script.

### 3. dbt
```bash
pip install -r requirements.txt
mkdir -p ~/.dbt
cp dbt_retail/profiles_template.yml ~/.dbt/profiles.yml
# edit ~/.dbt/profiles.yml with your real Snowflake account/user/password
cd dbt_retail
dbt debug      # confirms the connection works
dbt run        # builds staging -> intermediate -> marts
dbt test       # runs the schema tests
dbt docs generate && dbt docs serve   # view the lineage graph in your browser
```

### 4. Airflow
```bash
# Easiest path: Astronomer CLI
brew install astro
mkdir airflow_project && cd airflow_project
astro dev init
# copy retail_sales_dag.py into the generated dags/ folder
# copy dbt_retail/ into the project root, add dbt-core + dbt-snowflake to requirements.txt
astro dev start
# open localhost:8080, trigger the DAG
```

### 5. Dashboard
```bash
export SNOWFLAKE_USER=<your_username>
export SNOWFLAKE_PASSWORD=<your_password>
export SNOWFLAKE_ACCOUNT=<your_account_locator>
python dashboard/app.py
# open localhost:8050
```

## Models

| Layer | Model | Purpose |
|---|---|---|
| staging | `stg_store_sales` | Typed, cleaned raw transactions |
| intermediate | `int_sales_enriched` | Adds net sales, profit margin, quarter, 2023 flag |
| marts | `mart_sales_trends_yearly` | YoY revenue/profit/growth, 2019–2023 |
| marts | `mart_sales_by_region_2023` | 2023-only regional breakdown (executive view) |
| marts | `mart_category_performance` | Category/sub-category performance by year |
| marts | `mart_profitability` | Profit margin by category and discount band |

## For the resume / portfolio

> **Retail Sales Analytics Pipeline (2019–2023) | Snowflake, dbt, Airflow, Python, Plotly**
> Built an end-to-end ELT pipeline modeling 100K+ retail transactions into Snowflake via dbt with automated data quality tests; orchestrated daily refresh cycles via Airflow and surfaced YoY revenue, regional, and category trends through an executive-style dashboard — extending operational analytics work from prior ETL/dashboard experience.

For the GitHub README: include a screenshot of the `dbt docs` lineage graph
and a screenshot of the dashboard once it's running.
