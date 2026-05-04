# Databricks notebook source
# MAGIC %md
# MAGIC # 03 — SparkR + display() + ggplot
# MAGIC
# MAGIC When R code needs cluster-side compute (not just SQL), SparkR is the
# MAGIC native channel. The cluster you're attached to has Spark already; just
# MAGIC initialize the session.

# COMMAND ----------

# Bootstrap
ctx <- dbutils.notebook.getContext()
repo_root <- dirname(dirname(ctx$notebookPath()$getOrElse(NULL)))
source(file.path(repo_root, "utils", "helpers.R"))
source(file.path(repo_root, "utils", "plot_themes.R"))

notebook_env_banner()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Start a Spark session

# COMMAND ----------

library(SparkR)
sparkR.session()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Read a UC table directly

# COMMAND ----------

trips <- sql("SELECT * FROM samples.nyctaxi.trips")
printSchema(trips)
cat("Row count:", nrow(trips), "\n")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Aggregate on the cluster, then collect to R

# COMMAND ----------

top_zips <- sql("
  SELECT
    pickup_zip,
    COUNT(*)             AS n_trips,
    AVG(fare_amount)     AS avg_fare,
    AVG(trip_distance)   AS avg_dist
  FROM samples.nyctaxi.trips
  GROUP BY pickup_zip
  ORDER BY n_trips DESC
  LIMIT 20
")

# display() = native interactive table viewer in the notebook
display(top_zips)

# COMMAND ----------

# Bring the small aggregate result into local R for plotting
top_zips_df <- as.data.frame(top_zips)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Plot with ggplot — renders inline as the cell output

# COMMAND ----------

library(ggplot2)

p <- ggplot(top_zips_df, aes(x = reorder(as.character(pickup_zip), n_trips), y = n_trips)) +
  geom_col(fill = taxi_palette[1]) +
  coord_flip() +
  labs(
    title = "Top 20 Pickup ZIP Codes by Trip Count",
    x = "Pickup ZIP",
    y = "Trips"
  ) +
  theme_taxi()

p

# COMMAND ----------

# MAGIC %md
# MAGIC ## Write a result to a Volume
# MAGIC
# MAGIC The same Volume path works from any compute the user is permitted on —
# MAGIC including the EC2 dev host in Track B (mounted as `/mnt/data/...`).

# COMMAND ----------

# Replace with your catalog/schema/volume
# write.csv(top_zips_df, "/Volumes/main/r_demo/output/top_zips.csv", row.names = FALSE)

# COMMAND ----------

sparkR.session.stop()
