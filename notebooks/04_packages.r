# Databricks notebook source
# MAGIC %md
# MAGIC # 04 — Package Management in Native R Notebooks
# MAGIC
# MAGIC Notebooks don't use `renv`. Instead Databricks gives you two scopes:
# MAGIC
# MAGIC | Scope | Where it lives | When to use |
# MAGIC | --- | --- | --- |
# MAGIC | **Notebook-scoped** | `install.packages()` from inside the notebook; ephemeral | Quick experiments, one-off deps |
# MAGIC | **Cluster-scoped**  | Cluster UI → Libraries → Install | Shared by all users / notebooks on that cluster |
# MAGIC | **UC Volume** *(advanced)* | Pre-built `.libPaths()` pointing at a Volume | Pinning versions across runs |

# COMMAND ----------

# MAGIC %md
# MAGIC ## Notebook-scoped install (fastest)

# COMMAND ----------

# Run once at the top of a notebook; takes ~10-30 seconds the first time
install.packages(c("dplyr", "ggplot2", "DBI", "odbc", "dbplyr"))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Cluster-scoped install (recommended for shared deps)
# MAGIC
# MAGIC Open the cluster UI → Libraries tab → Install new → CRAN → enter
# MAGIC package name. Restart the cluster. Every user gets it without
# MAGIC re-installing.
# MAGIC
# MAGIC Or do it programmatically via brickster:
# MAGIC
# MAGIC ```r
# MAGIC brickster::db_libraries_install(
# MAGIC   cluster_id = "xxxx-yyyy-zzzz",
# MAGIC   libraries  = list(libraries_cran(package = "brickster"))
# MAGIC )
# MAGIC ```

# COMMAND ----------

# MAGIC %md
# MAGIC ## Verify what's loaded
# MAGIC
# MAGIC Useful when debugging "this package works on my laptop but not in the
# MAGIC notebook" — cluster-scoped libraries land at a different path than
# MAGIC notebook-scoped ones.

# COMMAND ----------

cat("Library paths:\n")
print(.libPaths())

cat("\nKey packages:\n")
for (pkg in c("dplyr", "ggplot2", "SparkR", "brickster", "DBI", "odbc")) {
  v <- tryCatch(packageVersion(pkg), error = function(e) NA)
  cat(sprintf("  %-12s %s\n", pkg, ifelse(is.na(v), "<not installed>", as.character(v))))
}

# COMMAND ----------

# MAGIC %md
# MAGIC ## Why `renv` doesn't fit here
# MAGIC
# MAGIC `renv` snapshots a project's R library on disk and locks versions in
# MAGIC `renv.lock`. In a Databricks notebook the library is **on the cluster**,
# MAGIC not in the project — so the snapshot doesn't survive cluster restarts
# MAGIC or transfers between users.
# MAGIC
# MAGIC The Databricks-native equivalent is **cluster-scoped libraries**
# MAGIC (pinned via cluster policy) or **UC Volumes** holding pre-built
# MAGIC `.libPaths()` directories that you point R at on session start.
# MAGIC
# MAGIC If you need true `renv` semantics, that's a Track B (EC2) workflow,
# MAGIC not a notebook workflow.
