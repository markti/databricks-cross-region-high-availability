data "databricks_current_user" "main" {
}

resource "databricks_notebook" "main_notebook" {
  source   = "${path.module}/scripts/PriceTableUpdater.py"
  path     = "${data.databricks_current_user.main.home}/PriceTableUpdater"
  language = "PYTHON"
}

# Create the databricks job.
resource "databricks_job" "updater_job" {
  name        = "Price_Table_Updater_Job"
  description = "This is a job to update the price table."

  task {
    task_key = "Price_Table_Updater_task"

    existing_cluster_id = var.cluster_id

    notebook_task {
      notebook_path = databricks_notebook.main_notebook.path
      base_parameters = {
        "input_table"  = var.input_table
        "output_table" = var.output_table
        "job_type"     = var.job_type
      }
    }
  }
}

# Create the sync notebook in primary region
resource "databricks_notebook" "prim_sync_notebook" {
  count    = var.is_primary ? 1 : 0
  source   = "${path.module}/scripts/PriceTableSyncJob.py"
  path     = "${data.databricks_current_user.main.home}/PriceTableSyncJob"
  language = "PYTHON"
}