import time
import pandas as pd

d = {'col1':[1,2],'col2':[3,4],'col3':[5,6]}
df = pd.DataFrame(data=d)

time.sleep(15)
df.to_csv("test_out.txt",sep="\t")


