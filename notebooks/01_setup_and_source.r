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
# MAGIC ## Pattern A — anchor on the notebook's own path  (recommended)
# MAGIC
# MAGIC Get the running notebook's full path from `dbutils`, walk up to the repo
# MAGIC root, then build paths from there. **No hard-coded user emails or repo
# MAGIC paths**, so the same code works for any teammate who clones the Git
# MAGIC folder under their own user.

# COMMAND ----------

# Resolve the repo root from the notebook's own path
ctx <- dbutils.notebook.getContext()
notebook_path <- ctx$notebookPath()$getOrElse(NULL)

# notebook_path looks like: /Workspace/Users/you@co.com/R_DBX/notebooks/01_setup_and_source
# We want:                  /Workspace/Users/you@co.com/R_DBX
repo_root <- dirname(dirname(notebook_path))
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
ctx <- dbutils.notebook.getContext()
repo_root <- dirname(dirname(ctx$notebookPath()$getOrElse(NULL)))
source(file.path(repo_root, "utils", "helpers.R"))
# --- End bootstrap ---

# Now the notebook can use shared functions:
notebook_env_banner()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Gotchas
# MAGIC
# MAGIC - **Working directory ≠ repo root.** `getwd()` inside a notebook is the
# MAGIC   notebook's parent folder, not the repo root. Don't rely on relative
# MAGIC   `source("../utils/...")` — use `file.path(repo_root, ...)`.
# MAGIC - **Symlinks in Git folders aren't followed.** If `helpers.R` is a
# MAGIC   symlink, copy it instead.
# MAGIC - **`source()` runs the whole file** every time the cell executes.
# MAGIC   Idempotent helper definitions are fine; helpers that have side effects
# MAGIC   (e.g. setting Spark options) are best wrapped in functions.
# MAGIC - **Workspace path changed?** If your admin migrated `/Workspace/Repos/`
# MAGIC   → `/Workspace/Users/<email>/`, Pattern A still works without changes
# MAGIC   because it derives the path at runtime.
