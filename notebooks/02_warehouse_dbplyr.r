# Databricks notebook source
# MAGIC %md
# MAGIC # 02 — DBI / dbplyr → SQL Warehouse
# MAGIC
# MAGIC From within a Databricks R notebook you can talk to a SQL Warehouse
# MAGIC using DBI + dbplyr the same way you'd do locally — minus the auth
# MAGIC bookkeeping, since the notebook inherits the user's Databricks identity.

# COMMAND ----------

# Bootstrap: source shared helpers (see notebook 01 for the pattern)
repo_root <- dirname(getwd())
source(file.path(repo_root, "utils", "helpers.R"))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Connect to a SQL Warehouse
# MAGIC
# MAGIC Set `DATABRICKS_HTTP_PATH` (the warehouse's HTTP path) before running.
# MAGIC In a notebook you can stash it as a cluster env var, secret scope, or
# MAGIC widget.

# COMMAND ----------

# Option A — pass http_path explicitly
con <- DBI::dbConnect(
  odbc::databricks(),
  httpPath = "/sql/1.0/warehouses/<your-warehouse-id>"
)

# Option B — pull from env (uses the helper from utils/helpers.R)
# con <- connect_warehouse()

# COMMAND ----------

# MAGIC %md
# MAGIC ## dbplyr — lazy translation to Spark SQL

# COMMAND ----------

library(dplyr)
library(dbplyr)

trips <- tbl(con, in_catalog("samples", "nyctaxi", "trips"))

top_zips <- trips |>
  group_by(pickup_zip) |>
  summarise(
    n_trips  = n(),
    avg_fare = mean(fare_amount, na.rm = TRUE)
  ) |>
  arrange(desc(n_trips)) |>
  head(20)

# Inspect the generated SQL before running
top_zips |> show_query()

# COMMAND ----------

# Pull results to local R
top_zips_df <- top_zips |> collect()
display(top_zips_df)

# COMMAND ----------

# MAGIC %md
# MAGIC ## What this DOESN'T solve
# MAGIC
# MAGIC - **Heavy R compute** — work happens on the Warehouse (SQL only).
# MAGIC   Anything beyond SQL needs SparkR (notebook 03) or a Job.
# MAGIC - **Multi-file source()** — same problem regardless of the connection;
# MAGIC   notebook 01 covers that.
# MAGIC - **Code that runs remotely on a different cluster** — can't see local
# MAGIC   files or ./utils unless you put them in a Volume / Workspace File.

# COMMAND ----------

DBI::dbDisconnect(con)
