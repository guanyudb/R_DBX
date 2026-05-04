# Databricks notebook source
# MAGIC %md
# MAGIC # 01 — Multi-file R Projects: `source()` Done Right
# MAGIC
# MAGIC The most common stumbling block when moving from a local R project into
# MAGIC a Databricks notebook is **how to share helper code across files**. In a
# MAGIC plain RStudio project, you'd just run `source("utils/helpers.R")` from
# MAGIC the project root. Inside a notebook, the working directory and the
# MAGIC project root aren't the same thing — and there's no `.Rproj` to anchor
# MAGIC paths. This notebook shows three patterns that work, and which one to
# MAGIC pick.
# MAGIC
# MAGIC Repo layout this notebook assumes:
# MAGIC
# MAGIC ```
# MAGIC R_DBX/
# MAGIC ├── notebooks/
# MAGIC │   ├── 00_intro.r
# MAGIC │   └── 01_setup_and_source.r   ← we are here
# MAGIC └── utils/
# MAGIC     ├── helpers.R               ← what we want to source
# MAGIC     └── plot_themes.R
# MAGIC ```

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pattern A — anchor on the notebook's working directory  (recommended)
# MAGIC
# MAGIC In a Databricks Git folder, `getwd()` returns the notebook's enclosing
# MAGIC directory. Walk up from there to the repo root, then build paths from
# MAGIC there. **No hard-coded user emails or repo paths**, no `dbutils`
# MAGIC dependency — works on Classic *and* Serverless R compute.
# MAGIC
# MAGIC (R notebooks don't expose a `dbutils` object, and the
# MAGIC `spark.databricks.notebook.path` global is only injected on some
# MAGIC runtimes — `getwd()` is the portable choice.)

# COMMAND ----------

# getwd() returns: /Workspace/Users/you@co.com/R_DBX/notebooks
# We want:         /Workspace/Users/you@co.com/R_DBX
repo_root <- dirname(getwd())
cat("Repo root:", repo_root, "\n")

# Now source helpers from a known relative location
source(file.path(repo_root, "utils", "helpers.R"))
source(file.path(repo_root, "utils", "plot_themes.R"))

# Verify the helpers loaded
notebook_env_banner()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pattern B — hard-code the Git folder path  (simplest, least portable)
# MAGIC
# MAGIC If your team agrees on a fixed location for the Git folder (e.g.,
# MAGIC `/Workspace/Shared/R_DBX`), you can just hard-code it. Loses portability
# MAGIC across users.

# COMMAND ----------

# Replace with your actual workspace path
# repo_root <- "/Workspace/Users/you@yourco.com/R_DBX"
# source(file.path(repo_root, "utils", "helpers.R"))

# COMMAND ----------

# MAGIC %md
# MAGIC ## Pattern C — store helpers in a Volume  (best for shared team libraries)
# MAGIC
# MAGIC Volumes are governed by Unity Catalog and are visible to **any** compute
# MAGIC the user is permitted on. Drop your shared helpers into a Volume once,
# MAGIC then source from there. Survives Git folder churn.

# COMMAND ----------

# Replace with your catalog/schema/volume
# helpers_path <- "/Volumes/main/r_demo/code/helpers.R"
# source(helpers_path)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Bootstrap snippet to put at the top of every notebook
# MAGIC
# MAGIC Once you decide on a pattern, drop a 3-line preamble at the top of each
# MAGIC notebook so the rest of the cells just call functions:

# COMMAND ----------

# --- Bootstrap (copy this into every notebook) ---
repo_root <- dirname(getwd())
source(file.path(repo_root, "utils", "helpers.R"))
# --- End bootstrap ---

# Now the notebook can use shared functions:
notebook_env_banner()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Gotchas
# MAGIC
# MAGIC - **No `dbutils` in R.** Don't try `dbutils.notebook.getContext()` (R
# MAGIC   reads the dots as one function name → *could not find function*) or
# MAGIC   `dbutils$notebook$getContext()` (→ *object 'dbutils' not found*).
# MAGIC   R notebooks don't expose `dbutils` at all.
# MAGIC - **`spark.databricks.notebook.path` isn't always there.** On some
# MAGIC   runtimes (Serverless R, certain DBR versions) the `spark.databricks.*`
# MAGIC   globals aren't injected. `getwd()` is the portable fallback.
# MAGIC - **Working directory ≠ repo root.** `getwd()` is the notebook's parent
# MAGIC   folder, not the repo root. Walk up with `dirname()` instead of using
# MAGIC   relative `source("../utils/...")`.
# MAGIC - **Symlinks in Git folders aren't followed.** If `helpers.R` is a
# MAGIC   symlink, copy it instead.
# MAGIC - **`source()` runs the whole file** every time the cell executes.
# MAGIC   Idempotent helper definitions are fine; helpers that have side effects
# MAGIC   (e.g. setting Spark options) are best wrapped in functions.
# MAGIC - **Workspace path changed?** If your admin migrated `/Workspace/Repos/`
# MAGIC   → `/Workspace/Users/<email>/`, Pattern A still works without changes
# MAGIC   because it derives the path at runtime.
