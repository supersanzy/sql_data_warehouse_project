# This script created a function to automatically change
#   the mode of the script file to be executable.
#   Used the os module to initialize the file path

import os

def shell_script():
    shell_script_path = "/home/supersanzy/data_warehouse_project/scripts/init_db.sh"

    os.system(f"bash {shell_script_path}")
    print("Database initialization script executed successfully!")





