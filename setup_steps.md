# Setup Steps — Native Databricks R Notebook with Git Folder

End-to-end walkthrough. Assumes you have:
- A Databricks workspace with Unity Catalog enabled
- Permission to create clusters or use serverless compute
- The repo `git@github.com:guanyudb/R_DBX.git` available

## 1. Push these files to R_DBX

From this directory:

```bash
cd /Users/guanyu.chen/Documents/Projects/R-Demo/demos/08_native_notebook
./push_to_r_dbx.sh
```

The script clones R_DBX to a sibling temp folder, copies `notebooks/` and
`utils/` over, commits, and pushes. Re-runnable.

If you'd rather do it by hand:

```bash
git clone git@github.com:guanyudb/R_DBX.git /tmp/R_DBX
cp -R notebooks utils /tmp/R_DBX/
cd /tmp/R_DBX
git add .
git commit -m "Add native R notebook demo"
git push
```

## 2. Connect Git in your Databricks workspace (one-time)

If GitHub isn't already connected:

1. Top-right user menu → **Settings** → **Linked accounts** → **Git
   integration**.
2. Provider: **GitHub**. Use a Personal Access Token (Settings → Developer
   settings → Personal access tokens → classic, scope `repo`).
3. Save.

## 3. Create the Git folder in your workspace

1. Workspace sidebar → **Workspace** → **+ Add** → **Git folder**.
2. Git repository URL: `https://github.com/guanyudb/R_DBX.git`
   (or `git@github.com:guanyudb/R_DBX.git` if you've set up SSH).
3. Git provider: GitHub. Branch: `main`.
4. Click **Create Git folder**.

The folder lands at `/Workspace/Users/<your-email>/R_DBX/`.

## 4. Provision a compatible cluster

R workloads need **Dedicated access mode**:

- **Single User** mode → 1:1 cluster per user. Simplest, but expensive at scale.
- **Group access mode** → multiple users in a group share one Dedicated
  cluster. Same R capabilities; better cost.
- **Standard / Shared mode** → SQL + Python only. R cells will fail.

Cluster spec:

| Setting | Value |
| --- | --- |
| Cluster mode | Dedicated (Single User or Group) |
| DBR version | 17.x or later |
| Node type | Anything with ≥ 16 GB RAM |
| Unity Catalog | Enabled |
| Allow jobs | Yes |

## 5. Open and run the notebooks

1. Navigate to `/Workspace/Users/<your-email>/R_DBX/notebooks/`.
2. Open `00_intro.r` → click **Connect** → pick the cluster from step 4.
3. Run cells (Shift+Enter or Run all).
4. Move on to `01_setup_and_source.r` — this is the centerpiece, showing how
   to source files cleanly across notebooks.
5. Continue through `02`–`04`.

## 6. Edit → commit → push (round trip)

Two equivalent paths:

**A. Edit in the workspace UI:**
1. Modify cells in the notebook UI.
2. Sidebar → Git icon (the branch arrow) → **Commit & Push**.
3. Changes appear in R_DBX on GitHub.

**B. Edit locally:**
1. Edit `.r` files in your local clone of R_DBX.
2. `git push`.
3. In the workspace: Git icon → **Pull**.

The `.r` files round-trip — Databricks reads `# Databricks notebook source`
and renders cells; on push it serializes back to the same source format.

## 7. Common gotchas

- **R cells fail with "language not supported"** → cluster is Standard mode.
  Switch to Dedicated.
- **`source()` can't find the file** → see notebook 01 for the path-anchoring
  pattern.
- **Symlinks in the Git folder** aren't followed; use real files.
- **Cluster restart wipes notebook-scoped packages**. Move shared deps to
  cluster-scoped libraries (notebook 04).
- **`dbutils.notebook.getContext()` returns NULL on serverless** — context
  retrieval differs between Classic and Serverless. Check both before
  shipping a bootstrap.
