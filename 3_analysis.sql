-- categories: amount listed, likes, amount sold
SELECT
	DISTINCT(product_category),
	COUNT(*) AS listings,
	SUM(product_like_count) AS likes,
	COUNT(CASE sold WHEN TRUE THEN 1 END) AS total_sold
FROM wip
GROUP BY product_category
ORDER BY total_sold DESC;

-- products: amount listed, likes, amount sold
SELECT
	DISTINCT(product_subcat),
	COUNT(*) AS listings,
	SUM(product_like_count) AS likes,
	COUNT(CASE sold WHEN TRUE THEN 1 END) AS total_sold
FROM wip
GROUP BY product_subcat
ORDER BY total_sold DESC;

-- categories: percentage liked to sold, percentage sold to listed
SELECT
	product_category,
	ROUND((sold::numeric / likes * 100),2) AS likes_rate,
	ROUND((sold::numeric / not_sold * 100),2) AS sell_rate
FROM (
	SELECT
		DISTINCT(product_category),
		COUNT(product_like_count) AS likes,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS sold,
		COUNT(CASE sold WHEN FALSE THEN 1 END) AS not_sold
	FROM wip
	GROUP BY product_category
) 
ORDER BY sell_rate DESC;

-- products: percentage liked to sold, percentage sold to listed
SELECT
	product_subcat,
	ROUND((sold::numeric / likes * 100),2) AS likes_rate,
	ROUND((sold::numeric / not_sold * 100),2) AS sell_rate
FROM (
	SELECT
		DISTINCT(product_subcat),
		COUNT(product_like_count) AS likes,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS sold,
		COUNT(CASE sold WHEN FALSE THEN 1 END) AS not_sold	
	FROM wip
	GROUP BY product_subcat
) 
ORDER BY sell_rate DESC;

-- What is the average number sold?
SELECT
	ROUND(AVG(total_sold),0)
FROM (
	SELECT
		DISTINCT(product_subcat),
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS total_sold
	FROM wip
	GROUP BY product_subcat
); -- 361

-- products having sold the avg or more: percentage liked to sold, percentage sold to listed
SELECT
	product_subcat,
	ROUND((amt_sold::numeric / likes * 100),2) AS likes_rate,
	ROUND((amt_sold::numeric / amt_not_sold * 100),2) AS sell_rate
FROM (
	SELECT
		DISTINCT(product_subcat),
		COUNT(product_like_count) AS likes,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS amt_sold,
		COUNT(CASE sold WHEN FALSE THEN 1 END) AS amt_not_sold	
	FROM wip
	GROUP BY product_subcat	
) 
WHERE amt_sold >= 361
ORDER BY sell_rate DESC;

-- brands: top 100 by amount sold
SELECT
	DISTINCT(brand_name),
	COUNT(CASE sold WHEN TRUE THEN 1 END) AS items_sold
FROM wip
GROUP BY brand_name
ORDER BY items_sold DESC
LIMIT 100;

-- brands: top 100 by amount listed
SELECT
	DISTINCT(brand_name),
	COUNT(product_id) AS amt_listed
FROM wip
GROUP BY brand_name
ORDER BY amt_listed DESC
LIMIT 100;

-- What is the like and sell rate for top 100 selling brands?
SELECT
	brand_name,
	amt_sold,
	ROUND((amt_sold::numeric / NULLIF(likes, 0) * 100),2) AS likes_rate,
	ROUND((amt_sold::numeric / NULLIF(amt_not_sold, 0) * 100),2) AS sell_rate
FROM (
	SELECT
		DISTINCT(brand_name),
		COUNT(product_like_count) AS likes,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS amt_sold,
		COUNT(CASE sold WHEN FALSE THEN 1 END) AS amt_not_sold	
	FROM wip
	GROUP BY brand_name
) subquery
ORDER BY amt_sold DESC
LIMIT 100;

-- top 100 brands best selling category
WITH cte AS (
	SELECT
		brand_name,
		product_category,
		COUNT(product_like_count) AS likes,
		COUNT(CASE WHEN sold THEN 1 END) AS amt_sold,
		COUNT(CASE WHEN NOT sold THEN 1 END) AS amt_not_sold	
	FROM wip
	GROUP BY brand_name, product_category
),
best_category AS (
	SELECT
		brand_name,
		product_category,
		amt_sold,
		likes,
		amt_not_sold,
		ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY amt_sold DESC) AS rank
	FROM cte
)
SELECT
	brand_name,
	product_category,
	amt_sold,
	ROUND((amt_sold::numeric / NULLIF(likes, 0) * 100), 2) AS likes_rate,
	ROUND((amt_sold::numeric / NULLIF(amt_not_sold, 0) * 100), 2) AS sell_rate
FROM best_category
WHERE rank = 1
ORDER BY amt_sold DESC
LIMIT 100;

-- top 100 brands best selling product
WITH cte AS (
	SELECT
		brand_name,
		product_subcat,
		COUNT(product_like_count) AS likes,
		COUNT(CASE WHEN sold THEN 1 END) AS amt_sold,
		COUNT(CASE WHEN NOT sold THEN 1 END) AS amt_not_sold	
	FROM wip
	GROUP BY brand_name, product_subcat
),
best_category AS (
	SELECT
		brand_name,
		product_subcat,
		amt_sold,
		likes,
		amt_not_sold,
		ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY amt_sold DESC) AS rank
	FROM cte
)
SELECT
	brand_name,
	product_subcat,
	amt_sold,
	ROUND((amt_sold::numeric / NULLIF(likes, 0) * 100), 2) AS likes_rate,
	ROUND((amt_sold::numeric / NULLIF(amt_not_sold, 0) * 100), 2) AS sell_rate
FROM best_category
WHERE rank = 1
ORDER BY amt_sold DESC
LIMIT 100;

-- What is the average price? by category
SELECT
	DISTINCT(product_category),
	ROUND(AVG(price_usd),0) AS avg_price
FROM wip
GROUP BY product_category;

-- What is the average price?
SELECT
	DISTINCT(product_subcat),
	ROUND(AVG(price_usd),0) AS avg_price
FROM wip
GROUP BY product_subcat;

-- top 100 brands avg selling price
WITH cte AS (
	SELECT
		DISTINCT(brand_name),
		COUNT(CASE WHEN sold THEN 1 END) AS amt_sold,
		ROUND(AVG(price_usd),0) AS avg_price
	FROM wip
	GROUP BY brand_name, product_subcat
),
average_price AS (
	SELECT
		brand_name,
		amt_sold,
		avg_price,
		ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY amt_sold DESC) AS rank
	FROM cte
)
SELECT
	brand_name,
	amt_sold,
	avg_price
FROM average_price
WHERE rank = 1
ORDER BY amt_sold DESC
LIMIT 100;

-- top 100 brands best selling product's avg selling price
WITH cte AS (
	SELECT
		DISTINCT(brand_name),
		product_subcat,
		COUNT(CASE WHEN sold THEN 1 END) AS amt_sold,
		ROUND(AVG(price_usd),0) AS avg_price
	FROM wip
	GROUP BY brand_name, product_subcat
),
average_price AS (
	SELECT
		brand_name,
		product_subcat,
		amt_sold,
		avg_price,
		ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY amt_sold DESC) AS rank
	FROM cte
)
SELECT
	brand_name,
	product_subcat,
	avg_price
FROM average_price
WHERE rank = 1
ORDER BY amt_sold DESC
LIMIT 100;

-- countries top 5 who sold 100+ items
SELECT *
FROM (
	SELECT
		seller_country,
		COUNT(DISTINCT brand_id) AS brand_count,
		COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS total_sold
	FROM wip
	GROUP BY seller_country
) AS subquery
WHERE total_sold >= 100
ORDER BY total_sold DESC, brand_count DESC
LIMIT 5;

-- In top 5 countries, which brands sell 100+ items?
SELECT *
FROM (
	SELECT
		seller_country,
		brand_name,
		COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS total_sold
	FROM wip
	GROUP BY seller_country, brand_name
) AS subquery
WHERE total_sold >= 100
	AND seller_country IN ('Italy', 'France', 'United Kingdom', 'Germany', 'United States')
ORDER BY total_sold DESC;

-- In top 5 countries, which brands sell 30+ items?
SELECT *
FROM (
	SELECT
		seller_country,
		brand_name,
		COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS total_sold
	FROM wip
	GROUP BY seller_country, brand_name
) AS subquery
WHERE total_sold >= 30
	AND seller_country IN (
		'Italy', 
		'France', 
		'United Kingdom', 
		'Germany', 
		'United States')
ORDER BY total_sold DESC;

-- seasons: amount sold, likes
SELECT
	product_season,
	likes,
	ROUND((amt_sold::numeric / likes * 100),2) AS likes_rate,
	amt_sold,
	ROUND((amt_sold::numeric / amt_not_sold * 100),2) AS sell_rate
FROM (
	SELECT
		DISTINCT(product_season),
		COUNT(product_like_count) AS likes,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS amt_sold,
		COUNT(CASE sold WHEN FALSE THEN 1 END) AS amt_not_sold	
	FROM wip
	GROUP BY product_season
) ORDER BY amt_sold DESC;

-- seasons, categories: amount sold, likes
SELECT
	product_season,
	product_category,
	MAX(sold) AS most_sold,
	MAX(likes) AS most_likes
FROM (
	SELECT
		DISTINCT(product_season),
		product_category,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS sold,
		COUNT(product_like_count) AS likes
	FROM wip
	GROUP BY product_season, product_category
) GROUP BY product_season, product_category
ORDER BY most_sold DESC;

-- seasons, products: amount sold, likes
SELECT
	product_season,
	product_subcat,
	MAX(sold) AS most_sold,
	MAX(likes) AS most_likes
FROM (
	SELECT
		DISTINCT(product_season),
		product_subcat,
		COUNT(CASE sold WHEN TRUE THEN 1 END) AS sold,
		COUNT(product_like_count) AS likes
	FROM wip
	GROUP BY product_season, product_subcat
) GROUP BY product_season, product_subcat
ORDER BY most_sold DESC;

-- what is the percentage of items sold in each price range
WITH bins_cte AS (
	SELECT
	    FLOOR(price_usd/100.00)*100 AS bin_floor,
	    COUNT(product_id::int) AS product_count,
		COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS product_sold
	FROM wip
	GROUP BY 1
	ORDER BY 1
)
SELECT
	bin_floor || ' - ' || (bin_floor + 100) AS price_range,
	product_sold,
	ROUND((product_sold::NUMERIC / product_count * 100),2) AS percent_sold
FROM bins_cte
WHERE ROUND((product_sold::NUMERIC / product_count * 100),2) > 0
ORDER BY 1;

-- pricing by season
SELECT
	DISTINCT(product_season),
	ROUND(MIN(price_usd), 0) AS min_price,
	ROUND(MAX(price_usd), 0) AS max_price,
	ROUND(AVG(price_usd), 0) AS avg_price,
	ROUND(MIN(seller_price), 0) AS min_seller_price,
	ROUND(MAX(seller_price), 0) AS max_seller_price,
	ROUND(AVG(seller_price), 0) AS avg_seller_price,
	COUNT(*) AS total_listed,
	COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS total_sold
FROM wip
GROUP BY product_season
ORDER BY avg_price DESC;

-- pricing by brand
SELECT
	DISTINCT(brand_name),
	ROUND(MIN(price_usd), 0) AS min_price,
	ROUND(MAX(price_usd), 0) AS max_price,
	ROUND(AVG(price_usd), 0) AS avg_price,
	ROUND(MIN(seller_price), 0) AS min_seller_price,
	ROUND(MAX(seller_price), 0) AS max_seller_price,
	ROUND(AVG(seller_price), 0) AS avg_seller_price,
	COUNT(*) AS total_listed,
	COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS total_sold
FROM wip
GROUP BY brand_name
ORDER BY total_sold DESC;

-- min, max, avg of products sold
SELECT
	ROUND(MIN(price_usd),0) AS min_price,
	ROUND(MAX(price_usd),0) AS max_price,
	ROUND(AVG(price_usd),0) AS avg_price
FROM wip
WHERE sold IS TRUE;

-- min, max, avg of all products
SELECT
	ROUND(MIN(price_usd),0) AS min_price,
	ROUND(MAX(price_usd),0) AS max_price,
	ROUND(AVG(price_usd),0) AS avg_price
FROM wip;

-- count countries, listed, sold
SELECT
	COUNT(DISTINCT seller_country) AS country_amt,
	COUNT(product_id) AS listed_amt,
	COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS sold_amt,
	SUM(product_like_count) AS likes_amt
FROM wip; -- 88	900514	13736	5671731

-- count from top 5 countries
SELECT
	COUNT(product_id) AS listed_amt,
	COUNT(CASE WHEN sold IS TRUE THEN 1 END) AS sold_amt
FROM wip
WHERE seller_country IN (
	'Italy', 
	'France', 
	'United Kingdom', 
	'Germany', 
	'United States'); -- 609006	9675