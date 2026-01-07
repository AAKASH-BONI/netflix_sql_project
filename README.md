# Netflix Movies and TV Shows Data Analysis and Visulaisation using SQL & TABLEAU

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project presents an end-to-end data analytics case study on Netflix’s content catalog, focusing on extracting meaningful business insights from real-world data. The analysis was conducted using SQL for data exploration and transformation, followed by interactive visualizations built in Tableau to communicate insights effectively.

The dataset contains detailed information about Netflix movies and TV shows, including content type, release year, ratings, genres, countries, and descriptions. During the analysis, several real-world data challenges were addressed, such as inconsistent date formats, multi-country values in a single field, and duplicate counting issues, ensuring accurate and reliable results.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE 
    type = 'Movie'
	AND
    release_year = 2020
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
 SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
        COUNT(show_id) AS total_content
    FROM netflix
    GROUP BY 1
	ORDER BY 2 DESC
    LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * FROM netflix
WHERE 
    type = 'Movie'
    AND
	duration = (SELECT MAX (duration) FROM netflix)
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*) as total_content
FROM netflix
WHERE country ILike '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Movies vs TV Shows Added Over Time (Year-wise)

```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
    type,
    COUNT(*) AS total_content
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY year_added ASC, type;
```
**Objective:** Understand Netflix’s content strategy shift over time.


### 17. Identify which countries receive older vs newer content.

```sql
SELECT
    TRIM(country_name) AS country,
    ROUND(
        AVG(
            EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) - release_year
        ), 
        2
    ) AS avg_content_age_years
FROM netflix,
LATERAL unnest(string_to_array(country, ',')) AS country_name
WHERE country IS NOT NULL
  AND date_added IS NOT NULL
GROUP BY country_name
ORDER BY avg_content_age_years ASC;
```
**Objective:** This analysis tells how old the content is when it appears on Netflix, NOT how long Netflix will take to add new content.

### Q18. Rating Distribution by Content Type

```sql
SELECT
    type,
    rating,
    COUNT(*) AS total_count
FROM netflix
WHERE rating IS NOT NULL
GROUP BY type, rating
ORDER BY type, total_count DESC;
```

**Objective:** Ratings overall kiska ky hai 

### Q19. Genre Dominance for Top 5 Content-Producing Countries

```sql
SELECT
    country,
    TRIM(genre) AS genre,
    COUNT(*) AS genre_count
FROM netflix,
LATERAL unnest(string_to_array(listed_in, ',')) AS genre
WHERE country IN (
    SELECT country
    FROM netflix
    WHERE country IS NOT NULL
    GROUP BY country
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
GROUP BY country, genre
ORDER BY country, genre_count DESC;
```

**Objective:** Top 5 countries or vo ky ky mostly dalte hai content

### Q20. “Bad” vs “Good” Content Trend Over Time

```sql
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
    CASE
        WHEN description ILIKE '%kill%'
          OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_count
FROM netflix
WHERE date_added IS NOT NULL
GROUP BY year_added, content_category
ORDER BY year_added ASC;
```
**Objective:** I classified content using keyword-based rules and analyzed how the proportion of sensitive content evolved over time.

### 21. India Content Trend: Movies vs TV Shows Over Time

```sql
SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
    type,
    COUNT(*) AS total_count
FROM netflix
WHERE country ILIKE '%India%'
  AND date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY year_added DESC, total_count DESC;

SELECT * 
FROM netflix
WHERE country ILIKE '%India%'
```

**Objective:** For content originating from India, how has the number of Movies vs TV Shows added to Netflix changed year by year? 
**Objective:** Is there an increasing or decreasing trend?

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Zero Analyst

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/akash-sharma-96a748222/)

Thank you for your support, and I look forward to connecting with you!
