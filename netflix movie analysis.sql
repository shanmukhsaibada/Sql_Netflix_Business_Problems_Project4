--netflix Project
drop table if exists netflix;
create table netflix
(
	show_id	varchar(6),
	type 	varchar(10),
	title	varchar(150),
	director varchar(210),
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year	int,
	rating	varchar(10),
	duration varchar(15),	
	listed_in	varchar(100),	
	description varchar(250)
);

--CHECKING THE DATA IF THE EXPORT WAS SUCCESFULL OR NOT 

select
count(*) as total_rows 
from netflix;

-- EXPLORING THE DATA
select
distinct type
from netflix;

-- CHECKING THE UNIQUE DIRECTORS 
select 
distinct director 
from netflix;

-- Solving the 15 BUsiness Problems in real_time 

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select 
	distinct type,
	count(type) as movies_shows
	from netflix
group by 1;


--2. Find the most common rating for movies and TV shows
select type,
rating
from
(
	select type,  
	rating, 
	count(rating) as common_rating,
	Rank() over(partition by type order by count(rating)desc)as ranking 
	from netflix
	group by 1, 2
	order by 1,3 desc
) as t1 
where 
	ranking = 1 ;


--3. List all movies released in a specific year (e.g., 2020)

select type, title, release_year
from netflix
where release_year = 2020;



-- 4. Find the top 5 countries with the most content on Netflix
select
	unnest(string_to_array(country, ','))  as new_country,
	count(show_id) as most_content
	from netflix 
	group by 1
	order by 2 desc
	limit 5;

--5. Identify the longest movie

SELECT *
	FROM netflix
	WHERE type = 'Movie'
	and duration is not null
	ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

-- 6. Find content added in the last 5 years
 
 select 
	date_added,type, title 
	from netflix
	where  to_date(date_added, 'Month DD,YYYY') >= current_date - interval '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


select type , director, title  from netflix 
where director like '%Rajiv Chilaka%';

-- NOT ACCURATE AS WE HAVE MULTIPLE DIRECTORS SO WE USED UNNEST AND STRINGTOARRAY FUNCTION 

SELECT *
	FROM (
	SELECT 
	type,
	title,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix ) AS t
WHERE director_name = 'Rajiv Chilaka';

--or 
select  	
	type,
	title,
	director
	from netflix 
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

select 
	duration, type, title
	from netflix 
	where type = 'TV Show'
	and split_part(duration ,' ', 1):: numeric > 5;




--9. Count the number of content items in each genre
select 
	unnest(string_to_array(listed_in, ',')) as genre,
	count(*) as total_content
	from netflix
	group by 1;



/*10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
*/


select 
	extract(year from TO_DATE(date_added, 'Month DD,YYYY')) as year ,
	count(date_added),
	count(date_added)::numeric/(select count(date_added) from netflix
	where country = 'India')::numeric * 100 as avg_content
	from netflix
	where country = 'India'
Group by 1  ;

--11. List all movies that are documentaries

select 
	type,
	title,
	unnest(string_to_array(listed_in,' ,'))as genre
	from netflix
	where listed_in ilike '%Documentaries' and type = 'Movie';

--or 

SELECT * 
	FROM netflix
	WHERE listed_in LIKE '%Documentaries';

--12. Find all content without a director

Select * from netflix
where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix 
where casts like '%Salman Khan%'
and release_year > extract (year from current_date) - 10;



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


select 
	unnest(string_to_array(casts , ',')) as actors,
	count(casts) as most_appeared
	from netflix
	where country ilike '%India'
	group by 1
	order by most_appeared desc
	limit 10;



/*
15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each catego
*/

with new_table
as 
(
	Select
	*,
	Case 
	when 
	description ilike '%kill%' or
	description ilike '%Violence%' then 'BAD_CONTENT'
	ELSE 'GOOD_CONTENT'
	end category
	from netflix
)

select
	category,
	count(category) as total_content
	from new_table
	group by 1;