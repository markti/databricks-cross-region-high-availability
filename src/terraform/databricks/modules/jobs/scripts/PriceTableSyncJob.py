from pyspark.sql import SparkSession
from pyspark.sql.functions import current_date, col, date_sub, date_add, max, lit
from pyspark.sql import functions as F

# Define the table name
table_name = "test_catalog.test_schema.price_table"
temp_table_name = "test_catalog_temp.test_schema_temp.price_table_temp"

df = spark.table(table_name)
df_temp = spark.table(temp_table_name)

# Get the distinct items by id with the latest updated_on timestamp
df_latest = df.groupBy("id").agg(max("updated_on").alias("date1"))

# Get the rows from the temp table which match the ids and dates are greater than mentioned in df_latest
df_update = df_temp.join(df_latest, (df_temp.id == df_latest.id) & (df_temp.updated_on > df_latest.date1)).select(df_temp["*"])

# Write back the updated rows to the primary table
df_update.write.mode("append").saveAsTable(table_name)
