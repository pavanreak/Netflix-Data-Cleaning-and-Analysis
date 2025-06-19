# Netflix-Data-Cleaning-and-Analysis
Cleaned and analyzed Netflix dataset using SQL and Python to remove duplicates, normalize fields, handle missing data, and extract insights about genres, directors, and content trends.


# 📊 Netflix Data Cleaning and Analysis Project

This project involves cleaning, transforming, and analyzing the Netflix dataset using **SQL** and **Python** to uncover insights about content types, directors, genres, and viewing patterns.

---

## 🛠 Tools Used

- SQL Server  
- Python (Jupyter Notebook)
- Pandas
- pyodbc
- Microsoft SQL Server Management Studio (SSMS)

---

## 📁 Dataset

The dataset contains details of Netflix content such as:
- Title
- Type (Movie/TV Show)
- Director
- Cast
- Country
- Date Added
- Release Year
- Duration
- Genre (Listed In)

---

## 🔧 Project Steps

### 1. Data Cleaning (SQL)
- Handled incorrect data types (`varchar ➝ nvarchar`)
- Removed duplicate entries using `ROW_NUMBER()`
- Normalized multivalued columns (Genre, Country, Director, Cast) using `STRING_SPLIT()`
- Filled missing values for `country` and `duration`
- Created a final cleaned table: `Netflix`

### 2. Data Analysis (SQL)
- Directors who made both Movies and TV Shows
- Country with the highest number of Comedy Movies
- Year-wise top director by number of releases
- Average movie duration by genre
- Directors who directed both Comedy & Horror genres

---

## 📌 Project Highlights

- Reduced data inconsistency by cleaning foreign characters
- Used SQL Window Functions, Joins, and Aggregations
- Converted unstructured fields into structured tables
- Answered 5 business questions with SQL analysis


