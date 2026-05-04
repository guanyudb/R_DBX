# Demo 08 — Native Databricks Notebook for R (with Git folders)

Demonstrates **Option 1 / Stage 1** from the deck: native Databricks R
notebooks, attached to a cluster, code under a Git folder.

## What's in here

```
notebooks/
  00_intro.r                # what this demo is, environment check
  01_setup_and_source.r     # multi-file projects via source() — the awkward part made clean
  02_warehouse_dbplyr.r     # DBI / dbplyr → SQL Warehouse
  03_sparkr_analytics.r     # SparkR on samples.nyctaxi.trips, display(), ggplot
  04_packages.r             # install.packages, librarian, notebook-scoped vs cluster-scoped libs
utils/
  helpers.R                 # sourceable helpers (used by 01_setup_and_source.r)
  plot_themes.R             # shared ggplot theme
setup_steps.md              # clone R_DBX → Git folder → cluster → run notebooks
push_to_r_dbx.sh            # one-shot: push these files to the R_DBX GitHub repo
```

## File format

All `.r` files in `notebooks/` are **Databricks notebook source format**:
- First line is `# Databricks notebook source` — Databricks recognizes this
  marker and renders the file as a notebook with cells.
- Cells are separated by `# COMMAND ----------`.
- Markdown cells use `# MAGIC %md` prefix on each line.

You can edit them locally as plain `.r` files and they round-trip to the
Databricks notebook UI cleanly.

## How to use

1. Push this folder's contents to `git@github.com:guanyudb/R_DBX.git`
   (see `push_to_r_dbx.sh` or `setup_steps.md`).
2. In your Databricks workspace → **Workspace** → **+ Add** → **Git folder**
   → paste the R_DBX URL.
3. Attach a cluster:
   - **Standard mode**: SQL + Python only (R cells will fail) — *not enough*.
   - **Dedicated mode (Single user OR Group)**: full R support ✅
   - DBR ≥ 17.x recommended.
4. Open `notebooks/00_intro.r` and start running cells.

See `setup_steps.md` for the full walkthrough.

## What this shows (vs. doesn't)

**Native notebooks give you (Advantages from the deck):**
- Zero infrastructure — runs entirely in the workspace
- Native Databricks Assistant for R code-gen in the notebook UI
- Direct access to UC catalogs, Volumes, cluster compute
- Built-in sharing, comments, Git folder integration
- Lowest setup cost

**They don't give you (Limitations from the deck):**
- VS Code, Positron, RStudio (workspace UI only)
- Quarto authoring fidelity
- Native R debugger / radian / httpgd
- Smooth multi-file project ergonomics — `source()` works but the path
  bookkeeping is what notebook 01 makes explicit
- `renv` (uses cluster-scoped or notebook-scoped libraries instead)
