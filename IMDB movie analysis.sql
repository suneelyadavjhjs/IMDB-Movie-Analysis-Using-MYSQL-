create database imdb_sql_proj;
use  imdb_sql_proj;
##### segment 1 #########
-- Ques:1 - -	What are the different tables in the database and how are they connected to each other in the database?
The different tables in the database are 'movie','genre', 'ratings', 'role_mapping', 'director_mapping' and 'names'.

The "genre" table has a foreign key "movie_id" that refers to the "id" column in the "movie" table, indicating that a movie can have multiple genres.
The "ratings" table has a foreign key "movie_id" that refers to the "id" column in the "movie" table, indicating that a movie can have ratings associated with it.
The "role_mapping" table has a foreign key "movie_id" that refers to the "id" column in the "movie" table, indicating that a movie can have multiple roles.
The "role_mapping" table also has a foreign key "name_id" that refers to the "id" column in the "names" table, linking the roles to their respective names.
The "director_mapping" table has a foreign key "movie_id" that refers to the "id" column in the "movie" table, indicating that a movie can have multiple directors.
The "director_mapping" table also has a foreign key "name_id" that refers to the "id" column in the "names" table, linking the directors to their respective names.

-- Ques :2 -	Find the total number of rows in each table of the schema.
select count(*) from movies;
select count(*) from director_maping;
select count(*) from genre;
select count(*) from names;
select count(*) from ratings;
select count(*) from  role_mapping;
-- Ques:3 -	Identify which columns in the movie table have null values.
select * from movies;
select id from movies where id is null or id = ' ';
select title from movies where title is null or title = ' ';
select year from movies where year is null or year = ' ';
select count(*) from movies where date_published is null or date_published = '';
select count(*) from movies where duration is null or duration = '';
select count(*) from movies where country is null or country = '';
select count(*) from movies where worlwide_gross_income is null or worlwide_gross_income = '';
select count(*) from movies where languages is null or languages = '';
select count(*) from movies where production_company = '';

-- #### # worlwide_gross_income, country, languages and production_company has null values in the movies table

-- ####### Segment 2: Movie Release Trends #######
-- Ques-1: - Determine the total number of movies released each year and analyse the month-wise trend.
select year, count(*) as no_of_movies_released from movies
group by year
order by year desc;
#Total_no_of_movies relased in 2019 = 2001, 2018 = 2944 and 2017 = 3052 repestively

select month(date_published) as month, count(*) as number_of_movies from movies
group by month(date_published)
order by month ;

select year,count(title) as movies,month(str_to_date(date_published,'%d/%m/%Y')) as month from movies
 group by year,month(str_to_date(date_published,'%d/%m/%Y'))
 order by 1,3;
 
 Select year,count(title) as movies from movies group by year;
 
-- Ques:--	Calculate the number of movies produced in the USA or India in the year 2019?
select  count(id) from movies where (country = 'USA' OR country = 'India') and year = 2019;
 
-- Segment 3: Production Statistics and Genre Analysis
-- Ques -- Retrieve the unique list of genres present in the dataset.
select distinct(genre) from genre;

-- Ques-- Identify the genre with the highest number of movies produced overall.
select genre,count(movie_id) from genre 
group by genre order by count(movie_id) desc limit 1;

-- Ques--Determine the count of movies that belong to only one genre.  
select count(*) from (
select movie_id,count(genre) as count_of_Movies from genre 
group by movie_id having count(genre) = 1) as a;  

-- Ques-- Calculate the average duration of movies in each genre.
select g.genre, avg(duration) from movies m
right join genre g on g.movie_id = m.id
group by g.genre
order by 2 desc;

-- Ques-- Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
select * from
(select genre, count(movie_id) as no_of_movies,
rank() over (order by count(movie_id) desc) as rnk
from genre
group by genre) t
where genre = 'Thriller';
-- Segment 4: Ratings Analysis and Crew Members

-- Ques-- Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
select min(avg_rating) as min_avg_rating,
max(avg_rating) as max_avg_rating,
min(total_votes) as min_total_votes,
max(total_votes) as max_total_votes,
min(median_rating) as min_median_rating,
max(median_rating) as max_median_rating
from  ratings;	

-- Ques-- Identify the top 10 movies based on average rating.

select * from 
(select title,avg_rating,
rank() over(order by avg_rating desc) as rnk
from movies M left join ratings R
on M.id = R.movie_id 
order by avg_rating desc) t
where rnk < 11;

-- Ques-- Summarise the ratings table based on movie counts by median ratings.
select median_rating, count(movie_id) as movie_count
from ratings
group by median_rating
order by median_rating;

-- Ques-- Identify the production house that has produced the most number of hit movies (average rating > 8).

select production_company,count(movie_id) Number_of_Movies from ratings R inner join movies M
on R.movie_id = M.id where avg_rating > 8 and (production_company is not null 
and production_company != '') group by production_company 
order by count(movie_id) desc limit 1 ;

-- Ques-- Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
select genre, count(id) as no_of_movies from movies M inner join ratings R on M.id = R.movie_id inner join genre G
on M.id = G.movie_id where country = 'USA' and total_votes > 1000 and date_published like '%03/2017'
group by genre order by no_of_movies desc;

-- Ques-- -Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
select title,genre from movies M inner join ratings R on M.id = R.movie_id inner join genre G
 on M.id = G.movie_id where title like 'The %'and avg_rating > 8 ;

-- Segment 5: Crew Analysis
-- Q.17-Identify the columns in the names table that have null values.

select count(*) from names where id is null;
select count(*) from names where name is null;
select count(*) from names where height is null;
select count(*) from names where date_of_birth is null;
select count(*) from names where known_for_movies is null;

-- Determine the top three directors in the top three genres with movies having an average rating > 8
with top_genre as
(select genre,count(G.movie_id) as total_movies from genre G inner join ratings R
on G.movie_id = R.movie_id
where avg_rating > 8
group by genre
order by total_movies desc limit 3)
select 
n.name as top_director, count(m.id) as movie_count
from names n inner join director_mapping dm on dm.name_id = n.id
inner join monies m on m.id = dm.movies_id
inner join genre g on g.movie_id = m.id
inner join ratings r on r.movie_id = m.id
where avg_rating > 8 and genre in 
(select genre from top_genre limit 3)
group by 1
order by movie_count 
limit 3;

-- Ques-- Find the top two actors whose movies have a median rating >= 8.
select name,count(R.movie_id) as Movie_Count  
from role_mapping RM inner join ratings R
on RM.movie_id  = R.movie_id 
inner join names N on N.id = RM.name_id
where median_rating >= 8 and category = 'actor'
group by name
order by count(R.movie_id) desc
limit 2;

-- Ques-- Identify the top three production houses based on the number of votes received by their movies.
select production_company,sum(total_votes)as votes from movies m 
join ratings r on m.id=r.movie_id
where production_company is not null
group by production_company 
order by votes desc limit 3;

-- Ques -- Rank actors based on their average ratings in Indian movies released in India.
select name, actor_rating ,
rank() over(order by actor_rating desc) as avg_rating_rank from (
select  name,avg(avg_rating) as actor_rating
from ratings R inner join movies M
on M.id = R.movie_id inner join role_mapping RM
on M.id = RM.movie_id  inner join names N on N.id = RM.name_id
where country = 'India'  and category = 'actor' 
group by name) A;   

-- Ques-- Identify the top five actresses in Hindi movies released in India based on their average ratings
select name, avg(avg_rating) as average_Rating from names N inner join role_mapping RM
on n.id = RM.name_id inner join movies M 
on M.id = Rm.movie_id inner join ratings R
on R.movie_id = M.id 
where category = 'actress' and  languages = 'Hindi' and country = 'India'
group by name
order by avg(avg_rating) desc 
limit 5;

-- Segment 6: Broader Understanding of Data
-- Ques-- Classify thriller movies based on average ratings into different categories.
select title,avg_rating,
case when avg_rating > 6 then 'Superhit' else 'Flop' end as rating_category
from movies M inner join ratings R
on R.movie_id = M.id inner join genre G
on  G.movie_id = M.id
where genre = 'Thriller'
order by avg_rating desc;

-- Ques-- analyse the genre-wise running total and moving average of the average movie duration.
select genre,avg(duration),sum(duration) from genre G inner join ratings R
 on G.movie_id = R.movie_id inner join movies M
 on M.id = G.movie_id 
 group by genre;
 
 -- Ques-- Identify the five highest-grossing movies of each year that belong to the top three genres.
select * from (
select title,year,worlwide_gross_income,genre,
rank() over(partition by genre,year order by worlwide_gross_income desc) as movie_rank 
from movies M inner join genre G
on M.id = G.movie_id 
where genre in (
select genre from (
select genre,count(movie_id) ,rank() over(order by count(movie_id) desc) as genre_rank 
from movies M inner join genre G
on M.id = G.movie_id 
group by genre) as A
where genre_rank <= 3)) as B
where movie_rank <= 5;

-- Ques-- Determine the top two production houses that have produced the highest number of hits among multilingual movies.
select production_company as production_house,count(title) from movies M inner join ratings R
on M.id = R.movie_id 
where languages like '%,%' and production_company != '' and production_company is not null and
avg_rating > 8
group by production_company
order by count(title)  desc
limit 2;

-- Ques -- Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
select name,count(title) as Movie_Count from names N inner join role_mapping RM
 on N.id = RM.name_id inner join genre G 
 on G.movie_id = RM.movie_id inner join movies M 
 on M.id = RM.movie_id inner join ratings R 
 on R.movie_id = M.id
 where avg_rating > 8 and genre = 'drama' and category = 'actress'
 group by name
 order by count(title) desc
 limit 3;
 
 -- Ques--Retrieve details for the top nine directors based on the number of movies, 
 -- including average inter-movie duration, ratings, and more.
select name as directors,count(title) as movies,
round(avg(avg_rating),2) as average_rating,round(avg(median_rating),2) as median_rating from names N 
inner join director_maping DM
on N.id = DM.name_id inner join ratings R 
on R.movie_id = DM.movie_id inner join movies M 
on M.id = R.movie_id
group by name
order by count(title) desc
limit 9;

-- Segment 7: Recommendations
-- Ques --Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
select genre,round(avg(avg_rating),2)  from genre G inner join ratings R
 on G.movie_id = R.movie_id inner join movies M 
 on M.id = G.movie_id
 where country = 'India' 
 group by genre
 order by avg(avg_rating) desc;
 
 -- movies should focus on producing the Crime movies.


 








