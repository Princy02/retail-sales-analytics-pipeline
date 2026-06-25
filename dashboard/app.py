"""
Executive-style Dash dashboard reading directly from the Snowflake marts
built by dbt (mart_sales_trends_yearly, mart_sales_by_region_2023,
mart_category_performance, mart_profitability).

Setup:
  pip install dash plotly snowflake-connector-python pandas

Fill in your Snowflake credentials below, or better: set them as
environment variables (SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ACCOUNT)
and load with os.environ.get(...) instead of hardcoding.
"""

import os
import pandas as pd
import snowflake.connector
import plotly.express as px
from dash import Dash, html, dcc

# ---- Snowflake connection ----
conn = snowflake.connector.connect(
    user=os.environ.get("SNOWFLAKE_USER", "<your_username>"),
    password=os.environ.get("SNOWFLAKE_PASSWORD", "<your_password>"),
    account=os.environ.get("SNOWFLAKE_ACCOUNT", "<your_account_locator>"),
    warehouse="RETAIL_WH",
    database="RETAIL_DB",
    schema="RAW_MARTS",
)

def query(sql):
    df = pd.read_sql(sql, conn)
    df.columns = [c.lower() for c in df.columns]
    return df


df_yearly = query("SELECT * FROM mart_sales_trends_yearly ORDER BY order_year")
df_region = query("SELECT * FROM mart_sales_by_region_2023 ORDER BY total_sales DESC")
df_category = query("SELECT * FROM mart_category_performance WHERE order_year = 2023 ORDER BY total_sales DESC")

# ---- KPI calculations (2023 snapshot) ----
latest = df_yearly[df_yearly["order_year"] == 2023].iloc[0]
total_sales_2023 = latest["total_sales"]
yoy_growth = latest["yoy_growth_pct"]
total_profit_2023 = latest["total_profit"]

# ---- Charts ----
fig_trend = px.line(df_yearly, x="order_year", y="total_sales", markers=True,
                     title="Total Sales by Year (2019–2023)")

fig_region = px.bar(df_region, x="region", y="total_sales", color="city_type",
                     title="2023 Sales by Region & City Type", barmode="group")

fig_category = px.pie(df_category, names="category", values="total_sales",
                       title="2023 Sales Mix by Category")

# ---- App layout ----
app = Dash(__name__)

def kpi_card(title, value):
    return html.Div([
        html.H4(title, style={"margin": "0", "color": "#666"}),
        html.H2(value, style={"margin": "0"}),
    ], style={
        "border": "1px solid #ddd", "borderRadius": "8px", "padding": "16px",
        "flex": "1", "textAlign": "center", "backgroundColor": "#fafafa"
    })

app.layout = html.Div([
    html.H1("Retail Sales Executive Dashboard — 2023", style={"textAlign": "center"}),

    html.Div([
        kpi_card("Total Sales (2023)", f"₹{total_sales_2023:,.0f}"),
        kpi_card("YoY Growth", f"{yoy_growth:.1f}%"),
        kpi_card("Total Profit (2023)", f"₹{total_profit_2023:,.0f}"),
    ], style={"display": "flex", "gap": "16px", "margin": "24px 0"}),

    dcc.Graph(figure=fig_trend),
    dcc.Graph(figure=fig_region),
    dcc.Graph(figure=fig_category),
], style={"maxWidth": "1000px", "margin": "auto", "fontFamily": "Arial"})

if __name__ == "__main__":
    app.run(debug=True)
