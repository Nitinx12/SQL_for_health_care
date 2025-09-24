import pandas as pd
from sqlalchemy import create_engine
import os


conn_string = 'postgresql://postgres:admin@localhost/managementdata'
db = create_engine(conn_string)
conn = db.connect()


files = ['appointments', 'billing', 'doctors', 'patients', 'treatments']
base_path = r"C:\Users\91852\Downloads\SQL projects\HMS project"

for file in files:
    file_path = os.path.join(base_path, f"{file}.csv")
    df = pd.read_csv(file_path)   
    print(type(df))  
    df.to_sql(file, con=conn, if_exists='replace', index=False)
    print(f" Loaded {file}")
