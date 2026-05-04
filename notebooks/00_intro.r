# Databricks notebook source
# MAGIC %md
# MAGIC # 00 — Native Databricks R Notebook: Intro
# MAGIC
# MAGIC This notebook is a plain `.r` file in source format. Databricks renders
# MAGIC it as a notebook because the first line is `# Databricks notebook source`
# MAGIC and cells are separated by `# COMMAND ----------`.
# MAGIC
# MAGIC The Git folder integration means: edit locally → push → pull in workspace,
# MAGIC or edit in workspace → commit → push from the Git folder UI. Either way,
# MAGIC the file stays a `.r` file in your repo.

# COMMAND ----------

# MAGIC %md
# MAGIC ## Cluster requirements
# MAGIC
# MAGIC R is supported only on **Dedicated access mode** clusters
# MAGIC (Single User or Group). Standard / Shared mode supports SQL + Python only.
# MAGIC
# MAGIC Recommended: DBR ≥ 17.x, UC enabled, jobs allowed.

# COMMAND ----------

# Verify environment
sessionInfo()

# COMMAND ----------

# What's the working directory? In a Git folder, it's the notebook's parent dir.
getwd()

# COMMAND ----------

# What's the notebook's enclosing folder? In a Git folder this is reliable
# across Classic and Serverless and is the cleanest anchor for source() — no
# dbutils dependency, no Spark globals required.
notebook_dir <- getwd()
notebook_dir

# COMMAND ----------

# Anything else you'd want from the notebook context (path, id, api url, token,
# orgId) is *sometimes* exposed as global vars named `spark.databricks.*` —
# but only on Classic Dedicated clusters, not on Serverless R. Print whatever
# is available so you know what you can rely on:
ls(pattern = "^spark|^orgId")

# COMMAND ----------

# MAGIC %md
# MAGIC ## What's next
# MAGIC
# MAGIC | Notebook | What it covers |
# MAGIC | --- | --- |
# MAGIC | `01_setup_and_source.r` | Multi-file R projects: how to `source()` cleanly |
# MAGIC | `02_warehouse_dbplyr.r` | DBI / dbplyr → SQL Warehouse |
# MAGIC | `03_sparkr_analytics.r` | SparkR on `samples.nyctaxi.trips`, `display()`, ggplot |
# MAGIC | `04_packages.r`         | Package management: notebook-scoped vs cluster-scoped |
