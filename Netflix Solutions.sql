-- Netflix Project 

DROP TABLE IF EXISTS netflix
CREATE TABLE netflix
(
   show_id	VARCHAR(6),
   type	    VARCHAR(10),
   title	VARCHAR(150),
   director	VARCHAR(208),
   casts	    VARCHAR(1000),
   country	VARCHAR(150),
   date_added	VARCHAR(50),
   release_year	 INT,
   rating	VARCHAR(10),
   duration	VARCHAR(15),
   listed_in	VARCHAR(100),
   description  VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) AS total_content
FROM netflix;

SELECT DISTINCT TYPE
FROM netflix;


-- 15 Business Problems and Solutions

-- 1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type

-- Objective: Determine the distribution of content types on Netflix.

 SELECT
 type,
 rating
 FROM
 
 (
 SELECT 
        type,
        rating,
        COUNT(*),
		RANK() OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY 1, 2
) as t1

WHERE
   ranking = 1

-- Objective: Identify the most frequently occurring rating for each type of content.


-- 3. List All Movies Released in a Specific Year (e.g., 2020)

-- things to find 
-- filter for 2020
-- only movies

SELECT * 
FROM netflix
WHERE 
    type = 'Movie'
	AND
    release_year = 2020

-- Objective: Retrieve all movies released in a specific year.

-- Find the Top 5 Countries with the Most Content on Netflix

 SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
        COUNT(show_id) AS total_content
    FROM netflix
    GROUP BY 1
	ORDER BY 2 DESC
    LIMIT 5;

-- Objective: Identify the top 5 countries with the highest number of content items.

-- 5. Identify the Longest Movie

SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND
	duration = (SELECT MAX (duration) FROM netflix)

-- Objective: Find the movie with the longest duration.


-- 6. Find Content Added in the Last 5 Years

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Objective: Retrieve content added to Netflix in the last 5 years.


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- = USE KRSKTE THE BUT PEHLE LIKE KIYE KUKI KAFI DIRECTER COLAB ME BHI WORK KRTE HAI
-- OR ILIKE SE AGRRKHI SMALL LETTER HO YA UPPER NICHE TOH SIRF WORDS SE SMJH LEGA

-- Objective: List all content directed by 'Rajiv Chilaka'.

-- 8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

  -- ISME NA DURATION YANI SESSION KO ALGG KIYE KI TV SHOW ME KITNE SEASON HAI OR 1 ISLIYE KI AGRR HI I AM ASE LIKHE 
  --TOH 1 SE HI MILEGA MEANS SPACE SE JO ALGG HORE UNKA IDEA

-- Objective: Identify TV shows with more than 5 seasons.

-- 9. Count the Number of Content Items in Each Genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

-- Objective: Count the number of content items in each genre.

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

SELECT 
      EXTRACT (YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	  COUNT(*) AS yearly_content,
	  ROUND(
      COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ='India')::numeric*100
	  ,2) as avg_content_per_year
FROM netflix
WHERE country ='India'
GROUP BY 1
ORDER BY 3 DESC
	  
-- Objective: Calculate and rank years by the average number of content releases by India.	  

-- 11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';

-- Objective: Retrieve all movies classified as documentaries.

-- 12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

-- Objective: List content that does not have a director.

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
  
-- Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) as total_content
FROM netflix
WHERE country ILike '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1;

-- Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise.
--Count the number of items in each category.

