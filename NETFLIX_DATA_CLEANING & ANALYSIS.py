#!/usr/bin/env python
# coding: utf-8

# # NETFLIX DATA CLEANING AND ANALYSIS

# In[54]:


# importing all the necessary libraries


# In[55]:


import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


# In[56]:


# Loading Dataset from the local file manager


# In[57]:


df = pd.read_csv(r"D:\Datasets & Projects\Netflix_Project\netflix_titles.csv")


# In[58]:


df.head(5)


# In[59]:


# Installing the odbc driver in python to connect with mssql


# In[60]:


pip install pyodbc


# In[61]:


# connecting to database 


# In[62]:


import pyodbc
try:
    connection = pyodbc.connect('DRIVER={SQL SERVER};'+
                            'Server=HANUMAN\MSSQL;'+
                            'Database=Projects;'+
                            'Trusted_Connection = True')
    print('Connected to Database')
except pyodbc.Error as ex:
    print('Connection Failed')


# In[63]:


# Option 2 to connect with sql 


# In[80]:


import sqlalchemy as sal
engine = sal.create_engine('mssql://HANUMAN\MSSQL/Projects?driver=ODBC+DRIVER+17+FOR+SQL+SERVER')
conn = engine.connect()
print('Connected')


# In[65]:


# appending the new table to the database


# In[ ]:


#df.to_sql('netflix_raw',con=conn, index=False, if_exists= 'replace')
#conn.close()


# In[81]:


df.to_sql('netflix_raw',con=conn, index=False, if_exists= 'append')
conn.close()


# In[67]:


# in sql for some columns it shows ?
# in sql the title name for show_id s5023 it shows ?


# In[68]:


df[df.show_id=='s5023']


# In[69]:


# all the ccolumns in table contains varchar and max range we need to change that


# In[70]:


# we'll check the length of show_id


# In[71]:


max(df.show_id.str.len())


# In[72]:


# The Max length of show_id is 5


# In[73]:


df.columns


# In[74]:


max(df.cast.str.len())


# In[75]:


# In cast there are some null values bcoz we're getting NAN as max, now let's drop the null values


# In[76]:


max(df.cast.dropna().str.len())


# In[77]:


# dropped null values and got the max values for cast


# In[78]:


max(df.description.str.len())


# In[ ]:


# after changing data type and range in sql by creating the other table we should drop the previous Netflix_raw table and append the values by giving the below code


# In[ ]:


#df.to_sql('netflix_raw',con=conn, index=False, if_exists= 'append')
#conn.close()


# In[83]:


df.isna().sum()


# In[ ]:





# In[ ]:




