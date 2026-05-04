# Shared helper functions — sourced by notebooks/01_setup_and_source.r
# This file lives in the Git folder alongside the notebooks; in a Databricks
# Git folder it's available at /Workspace/Users/<email>/R_DBX/utils/helpers.R
# (or /Workspace/Repos/<email>/R_DBX/utils/helpers.R on older workspaces).

# Connect to the SQL Warehouse via DBI
connect_warehouse <- function(http_path = NULL) {
  if (is.null(http_path)) {
    http_path <- Sys.getenv("DATABRICKS_HTTP_PATH", unset = NA)
    if (is.na(http_path)) {
      stop("Set DATABRICKS_HTTP_PATH or pass http_path explicitly")
    }
  }
  DBI::dbConnect(
    odbc::databricks(),
    httpPath = http_path
  )
}

# Quick descriptive stats helper for a Spark/dbplyr query
quick_summary <- function(query) {
  query |>
    dplyr::summarise(
      n        = dplyr::n(),
      avg_fare = mean(fare_amount, na.rm = TRUE),
      avg_dist = mean(trip_distance, na.rm = TRUE)
    ) |>
    dplyr::collect()
}

# Pretty-print "what cluster am I on?" for the top of every notebook
notebook_env_banner <- function() {
  cat("===================================================\n")
  cat("  R version:    ", R.version.string, "\n")
  cat("  Hostname:     ", Sys.info()[["nodename"]], "\n")
  cat("  SPARK_HOME:   ", Sys.getenv("SPARK_HOME", "<unset>"), "\n")
  cat("  CPU cores:    ", parallel::detectCores(), "\n")
  cat("  .libPaths[1]: ", .libPaths()[1], "\n")
  cat("===================================================\n")
}
