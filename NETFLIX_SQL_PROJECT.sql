---		NETFLIX DATA CLEANING AND ANALYSIS	---

--- Connecting Python with SQL ---

----------------------------------- DATA CLEANING -------------------------------

select * from netflix_raw order by title

-- some rows contains unidentified values

/*in netflix_raw table there are columns with data type varchar it doesn't allow any foreign keywords,
we need to change the data type to nvarchar and all the columns contains (max) range, for loading it
will take more time, we should change the range by checking each colummns max range */

/* we have already netflix_raw table and now we dropped the table and created again with the changed data types and range
by appending the data from python */

--Handling Foerign keywords By Changing Data Type
select * from netflix_raw where show_id ='s5023'

--Remove Duplicates
select show_id,count(*) from netflix_raw
group by show_id
having count(*)>1

--There is no Duplicate Values in Show_id

---Finding Duplicates Based on Title

select * from netflix_raw 
where Upper(title) in (
select upper(title) from netflix_raw
group by upper(title)
having count(*)>1
)
order by (title)

---some rows getting duplicates
--we're finding duplicates by title and type
select upper(title),type from netflix_raw
group by upper(title),type
having count(*)>1

select * from netflix_raw 
where concat(Upper(title),type) in (
select concat(upper(title),type) from netflix_raw
group by upper(title),type
having count(*)>1
)
order by (title)
-- we find 3 Duplicate Rows

---Dropping the Duplicate Rows 
with CTE as (
select *,ROW_NUMBER()over (Partition by Title, Type Order by show_id) as rn from netflix_raw
)
select show_id,type,title, cast(date_added as date) as date_added,
release_year,Rating,Duration,Description from CTE where rn = 1

---Before we have 8807 rows after dropping Duplicates we have 8804 rows, but it is the temporary process


----- New Tables for genre, Director, Cast, Country

select show_id, trim(value) as director into Netflix_Directors
from netflix_raw
cross apply string_split(director,',')

--- we've created another table for directors
select * from Netflix_Directors


---Creating Table for Genre
select show_id, trim(value) as genre into Netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')

select * from Netflix_genre
select distinct(Genre) from Netflix_genre


--- Creating Table for Cast
select show_id, trim(value) as Cast into Netflix_cast
from netflix_raw
cross apply string_split(cast,',')

select * from Netflix_cast

---- Creating Table for Country

select show_id, trim(Value) as Country
into Netflix_Country
from netflix_raw
cross apply string_split(Country,',')

select * from Netflix_Country

---------------------------------------------------------------------------

---populate missing values in country, duration columns
select * from netflix_raw where country is null

select * from netflix_raw where director = 'Ahishor Solomon'

---Listing all the countries and directors having not null values in countries
select director,Country from Netflix_Country as nc
inner join Netflix_Directors as nd on nc.show_id=nd.show_id
group by director,Country
----------------------------------------------------------------------


insert into Netflix_Country
select show_id,m.Country from netflix_raw nr
inner join (select director,Country from Netflix_Country as nc
inner join Netflix_Directors as nd on nc.show_id=nd.show_id
group by director,Country) m on nr.director = m.director
where nr.country is null
------------------------------------------------------------------------

select * from netflix_raw where duration is null

--we have 3 null values in duration and duration time is inserted in rating column
with CTE as (
select *,ROW_NUMBER()over (Partition by Title, Type Order by show_id)
as rn from netflix_raw
)
select show_id,type,title, cast(date_added as date) as date_added,
release_year,Rating,
case when Duration is null then rating else duration end as duration,
Description 
into Netflix --- Final Table
from CTE

select * from Netflix



------------------------------ DATA ANALYSIS ------------------------------

/*Q.1 For each director count the no.of.movies & Tv showa Created by thtm in seperate columns
for direcctor who have created tv shows and movies both */

SELECT ND.director, COUNT( DISTINCT N.TYPE) AS DIST_TYPE
FROM NETFLIX N
INNER JOIN Netflix_Directors ND
ON N.show_id = ND.show_id
GROUP BY ND.director
ORDER BY DIST_TYPE DESC


SELECT ND.director, COUNT( DISTINCT N.TYPE) AS DIST_TYPE
FROM NETFLIX N
INNER JOIN Netflix_Directors ND
ON N.show_id = ND.show_id
GROUP BY ND.director
HAVING COUNT( DISTINCT N.TYPE)>1
ORDER BY DIST_TYPE DESC

---THERE ARE 83 DIRECTORS WHO DIRECTED BOTH TV SHOWS AND MOVIES

----------------------------------------------------------------------------

-- WE'VE TO CREATE SEPERATE COLUMNS FOR NO.OF.MOVIES & NO.OF.TVSHOWS

SELECT ND.director,
COUNT( DISTINCT CASE WHEN N.TYPE = 'MOVIE' THEN N.show_id END) AS NO_OF_MOVIES,
COUNT( DISTINCT CASE WHEN N.TYPE = 'TV SHOW' THEN N.SHOW_ID END) AS NO_OF_TVSHOWS
FROM NETFLIX N
INNER JOIN Netflix_Directors AS ND
ON N.show_id = ND.show_id
GROUP BY ND.DIRECTOR
HAVING COUNT(DISTINCT N.TYPE) >1

-------------------------------------------------------------------------

-- Q.2 WHICH COUNTRY HAS HIGHEST NUMBER OF COMEDY MOVIES

SELECT DISTINCT(GENRE) FROM Netflix_genre NG
WHERE NG.genre = 'Comedies'

SELECT TOP 1 NC.Country, COUNT (DISTINCT NG.SHOW_ID) AS NO_OF_MOVIES
FROM NETFLIX_GENRE NG
INNER JOIN Netflix_Country NC ON NC.show_id = NG.show_id
INNER JOIN Netflix N ON N.show_id = NG.show_id
WHERE NG.GENRE='Comedies' AND N.TYPE = 'MOVIE'
GROUP BY NC.Country
ORDER BY NO_OF_MOVIES DESC
-------------------------------------------------------------------------

--Q.3 FOR EACH YEAR (AS PER ADDED TO NETFLIX), WHICH DIRECTOR HAS MAX NO.OF.MOVIES RELEASED

WITH CTE AS (
SELECT ND.director,YEAR(date_added) AS YEAR,
COUNT(DISTINCT N.show_id) AS NO_OF_MOVIES
FROM Netflix_Directors ND
INNER JOIN NETFLIX N ON N.show_id=ND.show_id
WHERE TYPE = 'MOVIE'
GROUP BY ND.director, YEAR(DATE_ADDED)
),
CTE2 AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY NO_OF_MOVIES DESC, DIRECTOR) AS RN
FROM CTE
--ORDER BY YEAR, NO_OF_MOVIES DESC
)
SELECT * FROM CTE2 WHERE RN = 1

--------------------------------------------------------------------------

-----Q.4 WHAT IS THE AVG DURATION OF MOVIES IN EACH GENRE
SELECT * FROM NETFLIX WHERE TYPE = 'MOVIE'

-- DURATION COL IS A VARCHAR D TYPE AND IT CONSISTS 'MIN' WE HAVE TO FIND AVG DURATION
SELECT NG.GENRE, AVG(CAST(REPLACE(duration, ' MIN','')AS INT)) AS AVG_DURATION
FROM NETFLIX N
INNER JOIN Netflix_genre NG ON NG.show_id = N.show_id
WHERE TYPE = 'MOVIE'
GROUP BY NG.genre

--IN THIS WE SEPERATED INT BY CREATING OTHER COLUMN 

-------------------------------------------------------------------------

/*  Q.5 FIND THE LIST OF DIRECTORS WHO HAVE CREATED HORROR & COMEDY MOVIES
BOTH. DISPLAY DIRECTORS NAMES ALOMG WITH NO_OF_COMEDY AND HORROR MOVIES DIRECTED
BY GENRE */

SELECT ND.director,
COUNT(DISTINCT CASE WHEN NG.GENRE = 'COMEDIES' THEN N.SHOW_ID END) AS NO_OF_COMEDY,
COUNT(DISTINCT CASE WHEN NG.GENRE = 'HORROR MOVIES' THEN N.SHOW_ID END) AS NO_OF_HORROR
FROM NETFLIX N
INNER JOIN Netflix_GENRE NG ON N.show_id=NG.show_id
INNER JOIN Netflix_Directors ND ON ND.show_id=N.show_id
WHERE TYPE = 'MOVIE' AND NG.genre IN ('Comedies','Horror Movies')
GROUP BY ND.director
HAVING COUNT(DISTINCT NG.GENRE)=2


SELECT * FROM NETFLIX_GENRE WHERE SHOW_ID IN 
(SELECT SHOW_ID FROM Netflix_Directors WHERE director = 'Kevin Smith')
ORDER BY GENRE


/*  Q.5 FIND THE LIST OF DIRECTORS WHO HAVE CREATED HORROR & COMEDY MOVIES
BOTH. DISPLAY DIRECTORS NAMES ALOMG WITH NO_OF_COMEDY AND HORROR MOVIES DIRECTED
BY GENRE */

SELECT ND.director,
COUNT(DISTINCT CASE WHEN NG.GENRE = 'COMEDIES' THEN N.SHOW_ID END) AS NO_OF_COMEDY,
COUNT(DISTINCT CASE WHEN NG.GENRE = 'HORROR MOVIES' THEN N.SHOW_ID END) AS NO_OF_HORROR
FROM NETFLIX N
INNER JOIN Netflix_GENRE NG ON N.show_id=NG.show_id
INNER JOIN Netflix_Directors ND ON ND.show_id=N.show_id
WHERE TYPE = 'MOVIE' AND NG.genre IN ('Comedies','Horror Movies')
GROUP BY ND.director
HAVING COUNT(DISTINCT NG.GENRE)=2