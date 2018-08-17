import sys
import logging
from pyspark.sql import SparkSession


def get_files_and_store(spark, url, directory):  # type: (SparkSession,str,str) -> None

    logging.info("Downloading the file: %s", url)
    df = spark.read.text(url)
    df.spark.write.format("txt").mode("append").save(directory)


def parse_files_and_store_parquet(spark, directory):  # type: (SparkSession,str) -> None

    for file in directory:
        df = spark.read.parquet(file)
        # Apply parsse to each log
        rdd_df = df.rdd.map(parse_access_log_line)
        # filter the words in the  black list
        df_filtered = spark.createDataFrame(rdd_df)
        df_filtered.spark.write.format("parquet").mode("append").save(directory)


def parse_access_log_line(): 
    print ("parsing")


def get_spark_session():
    spark = SparkSession.builder \
        .master('local') \
        .appName('file processor') \
        .config("spark.cores.max", "2") \
        .getOrCreate()
    return spark


def download_files(spark, list_url, directory): # type: (SparkSession,str,str) -> None
    for url_file in list_url:
        get_files_and_store(spark, list_url, directory)


def get_20_host_by_access(spark, directory_parquet, directory_json):# type: (SparkSession,str,str) -> None

    parquet_files_df = spark.read.parquet(directory_parquet)
    spark.registerDataFrameAsTable(parquet_files_df, "tempTable")
    # Query the table using spark.sql
    newdf = spark.sql("select * from tempTable")

    spark.dropTempTable("tempTable")
    newdf.spark.write.format("json").mode("append").save(directory_json)


def main(args):
    spark = get_spark_session()
    black_list = ['google', 'yahoo']
    directory_text_files = "tests/files_txt/"
    directory_parquet = "tests/files_parquet/"
    directory_json = "tests/files_parquet/"

    list_url = ["https://github.com/juanpampliega/datasets/raw/master/http_access_200304.log.gz",
                "https://github.com/juanpampliega/datasets/raw/master/http_access_200306.log.gz",
                "https://github.com/juanpampliega/datasets/raw/master/http_access_200307.log.gz"]

    # Exercise 1
    download_files(spark, list_url, directory_text_files)
    # Exercise 2
    parse_files_and_store_parquet(spark, directory_parquet, black_list)
    # Exercise 3
    get_20_host_by_access(spark,directory_parquet,directory_json)


def run():
    logging.basicConfig(filename='LOG-sendReport.log', level=logging.INFO, format='%(asctime)s %(message)s')
    logging.info('Started')
    main(sys.argv[1:])


if __name__ == "__main__":
    run()
