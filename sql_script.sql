-- Count the no of Movies vs Tv shows
SELECT
	type,
	COUNT(*) AS Total_content
FROM netflix
GROUP BY type

-- find the most common ratings for movies and TV shows
SELECT
type,
rating
FROM
	(
	SELECT
		type,
		rating,
		COUNT(*) AS total_rating,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
	) t
WHERE ranking = 1

--List all movies release in a specific year (ex. 2020)
SELECT*
FROM netflix
	WHERE type = 'Movie'
	AND 
	release_year = '2020'

--find the top 5 countries with the most content on Netflix
SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) AS New_country,
	COUNT(*) AS Total_content
FROM netflix
GROUP BY New_country
ORDER BY Total_content DESC
LIMIT 5

--identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
AND 
duration = (SELECT MAX(duration) FROM netflix)

-- find the content added in the last five years
SELECT*
FROM netflix
WHERE TO_DATE(date_added,'Month DD,YYYY')>=  CURRENT_DATE - INTERVAL '5 years'

-- find all the Movies/TV shows by director 'Rajiv Chilaka'
SELECT*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


-- list TV shows more than 5 seasons
SELECT*
FROM netflix
WHERE type = 'TV Show'
AND
SPLIT_PART(duration,' ', 1) ::numeric > 5 

--Count  the no of content in each genre

SELECT
UNNEST(STRING_TO_ARRAY(listed_in,',')) AS genre,
COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1

--Find each year and  the average number of  content release in india on netflix
--return top 5 year with highest avg content release

SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric*100,2)as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY  3 DESC
LIMIT 5

--List all movies that are Documentaries
SELECT*
FROM netflix
WHERE listed_in ILIKE 'Documentaries'

--find all the content without a director
SELECT*
FROM netflix
WHERE director IS NULL

--Find how many movies actor 'Salman khan' appeared in last 15 years

SELECT*
FROM netflix
WHERE casts ILIKE '%Salman khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE)-15

-- find the top 10 actors who have appeared in the highest no of movies produced in india


SELECT
	UNNEST(STRING_TO_ARRAY(casts,',')) AS actor,
	COUNT(*) AS Total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10


-- Categorize the content based on the presence of the keyword 	'kill' and 'violence' in the 
--description field .label the content containing these keyword as 'Bad' and all other content
-- as 'good' Count how many items fall into these Category


WITH new_table AS (
SELECT
*,
	CASE 
	WHEN description ILIKE '%Kill%' OR
		 description ILIKE '%Violence%' THEN 'Bad Content'
		 ELSE 'Good Content'
	END Category
FROM netflix
)
SELECT
	Category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY Category



