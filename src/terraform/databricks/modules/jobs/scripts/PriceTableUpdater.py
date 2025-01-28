from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date, col, date_sub, date_add, max, lit

# Define the table name
input_table = dbutils.widgets.get("input_table")
output_table = dbutils.widgets.get("output_table")
job_type = dbutils.widgets.get("job_type")

df = spark.table(input_table)
# Get the distinct items by id with the latest updated_on timestamp
df_latest = df.groupBy("id").agg(max("updated_on").alias("latest_update"))

# Join back with the original table to get the full record with the latest update
df_distinct_latest = df.join(df_latest, (df.id == df_latest.id) & (df.updated_on == df_latest.latest_update)).select(df["*"])

# Increase the price by 10 for each record and set a new updated_by date
df_new = df_distinct_latest.withColumn("price", col("price") + 10).withColumn("updated_on", date_add(col("updated_on"), 1)).withColumn("updated_by", lit(job_type))
# Append the updated data as new rows to the same table
df_new.write.mode("append").saveAsTable(output_table)