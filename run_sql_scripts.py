# This script loads env variables using dotenv()
# And connects to postgres database to drop data_warehouse if it exists


# WARNING: Running this script will drop the entire data_warehouse if it exists.
# All data in the will be permanently deleted. Proceed with caution.


from dotenv import load_dotenv
import psycopg2
import os
from pathlib import Path
from run_shell_script import shell_script
from logging_config import setup_logging
import logging


setup_logging()

logging.info("Running shell script")
shell_script()


load_dotenv()

sql_path = Path("/home/supersanzy/data_warehouse_project/scripts/sql")

conn = psycopg2.connect(
    dbname = os.getenv("TARGET_DB"),
    user = os.getenv("DB_USER"),
    host = os.getenv("DB_HOST"),
    port = os.getenv("DB_PORT"),
    password = os.getenv("DB_PASSWORD")
)
        
conn.autocommit = False
cur = conn.cursor()

try:
    for sql_file in sorted(sql_path.glob("*.sql")):
        logging.info(f"Running {sql_file.name}")
        sql = sql_file.read_text()
        # logging.info(sql)
        logging.debug(f"SQL content:\n{sql}")
        cur.execute(sql)

    conn.commit()
    logging.info("All sql file executed successfully")

except Exception as e:
    conn.rollback()
    logging.error(f"Error occurred. Rolled back changes. Details: {e}")
    raise e


finally:
    cur.close()
    conn.close()
    logging.info("Database connection closed successfully")

