-- dataset: https://www.kaggle.com/datasets/justinpakzad/vestiaire-fashion-dataset

CREATE TABLE raw_data (
	product_id BIGINT,
	product_type TEXT,
	product_name TEXT,
	product_description TEXT,
	product_keywords TEXT,
	product_gender_target TEXT,
	product_category TEXT,
	product_season TEXT,
	product_condition TEXT,
	product_like_count NUMERIC,
	sold BOOLEAN,
	reserved BOOLEAN,
	available BOOLEAN,
	in_stock BOOLEAN,
	should_be_gone BOOLEAN,
	brand_id INT,
	brand_name TEXT,
	brand_url TEXT,
	product_material TEXT,
	product_color TEXT,
	price_usd NUMERIC,
	seller_price NUMERIC,
	seller_earning NUMERIC,
	seller_badge TEXT,
	has_cross_border_fees BOOLEAN,
	buyers_fees NUMERIC,
	warehouse_name TEXT,
	seller_id BIGINT,
	seller_username TEXT,
	usually_ships_within TEXT,
	seller_country TEXT,
	seller_products_sold NUMERIC,
	seller_num_products_listed NUMERIC,
	seller_community_rank NUMERIC,
	seller_num_followers NUMERIC,
	seller_pass_rate NUMERIC
);

-- csv via command line
\COPY raw_data FROM '/Users/emily/Desktop/vestiaire.csv' WITH DELIMITER ',' CSV HEADER;

SELECT * FROM raw_data LIMIT 5;




-- update data type numeric to integer
ALTER TABLE raw_data
ALTER COLUMN product_like_count TYPE INT,
ALTER COLUMN seller_products_sold TYPE INT,
ALTER COLUMN seller_num_products_listed TYPE INT,
ALTER COLUMN seller_community_rank TYPE INT,
ALTER COLUMN seller_num_followers TYPE INT;

-- display duplicates
SELECT
	product_id,
	COUNT(*)
FROM raw_data
GROUP BY product_id
HAVING COUNT(*) > 1;

-- null count per column
SELECT
	COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id,
	COUNT(*) FILTER (WHERE product_type IS NULL) AS product_type,
	COUNT(*) FILTER (WHERE product_description IS NULL) AS product_description, -- 7
	COUNT(*) FILTER (WHERE product_keywords IS NULL) AS product_keywords, -- 1183
	COUNT(*) FILTER (WHERE product_gender_target IS NULL) AS product_gender_target,
	COUNT(*) FILTER (WHERE product_category IS NULL) AS product_category, -- 1183
	COUNT(*) FILTER (WHERE product_season IS NULL) AS product_season, -- 2
	COUNT(*) FILTER (WHERE product_condition IS NULL) AS product_condition,
	COUNT(*) FILTER (WHERE product_like_count IS NULL) AS product_like_count,
	COUNT(*) FILTER (WHERE sold IS NULL) AS sold,
	COUNT(*) FILTER (WHERE reserved IS NULL) AS reserved,
	COUNT(*) FILTER (WHERE available IS NULL) AS available,
	COUNT(*) FILTER (WHERE in_stock IS NULL) AS in_stock,
	COUNT(*) FILTER (WHERE should_be_gone IS NULL) AS should_be_gone,
	COUNT(*) FILTER (WHERE brand_id IS NULL) AS brand_id,
	COUNT(*) FILTER (WHERE brand_name IS NULL) AS brand_name,
	COUNT(*) FILTER (WHERE brand_url IS NULL) AS brand_url,
	COUNT(*) FILTER (WHERE product_material IS NULL) AS product_material, -- 4
	COUNT(*) FILTER (WHERE product_color IS NULL) AS product_color, -- 1
	COUNT(*) FILTER (WHERE price_usd IS NULL) AS price_usd,
	COUNT(*) FILTER (WHERE seller_price IS NULL) AS seller_price,
	COUNT(*) FILTER (WHERE seller_earning IS NULL) AS seller_earning,
	COUNT(*) FILTER (WHERE seller_badge IS NULL) AS seller_badge,
	COUNT(*) FILTER (WHERE has_cross_border_fees IS NULL) AS has_cross_border_fees, -- 13736
	COUNT(*) FILTER (WHERE buyers_fees IS NULL) AS buyers_fees, -- 13736
	COUNT(*) FILTER (WHERE warehouse_name IS NULL) AS warehouse_name,
	COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id,
	COUNT(*) FILTER (WHERE seller_username IS NULL) AS seller_username, -- 39
	COUNT(*) FILTER (WHERE usually_ships_within IS NULL) AS usually_ships_within, -- 154791
	COUNT(*) FILTER (WHERE seller_country IS NULL) AS seller_country,
	COUNT(*) FILTER (WHERE seller_products_sold IS NULL) AS seller_products_sold,
	COUNT(*) FILTER (WHERE seller_num_products_listed IS NULL) AS seller_num_products_listed,
	COUNT(*) FILTER (WHERE seller_community_rank IS NULL) AS seller_community_rank,
	COUNT(*) FILTER (WHERE seller_num_followers IS NULL) AS seller_num_followers,
	COUNT(*) FILTER (WHERE seller_pass_rate IS NULL) AS seller_pass_rate
FROM raw_data;

-- Which records have null seasons?
SELECT *
FROM raw_data
WHERE product_season IS NULL;

-- What season are women's silk scarves categorized under?
SELECT product_season, COUNT(*)
FROM raw_data
WHERE product_name LIKE '%ilk scarf%'
	AND product_category = 'Women Accessories'
GROUP BY product_season
ORDER BY COUNT(*) DESC; -- Autumn / Winter

-- What season are women's sunglasses categorized under?
SELECT product_season, COUNT(*)
FROM raw_data
WHERE product_name LIKE '%unglasses%'
	AND product_category = 'Women Accessories'
GROUP BY product_season
ORDER BY COUNT(*) DESC; -- All seasons

-- update null seasons for sunglasses
UPDATE raw_data
SET product_season = 'Autumn / Winter'
WHERE product_season IS NULL
	AND product_name LIKE '%unglasses%';

-- update null seasons for silk scarves
UPDATE raw_data
SET product_season = 'All seasons'
WHERE product_season IS NULL
	AND product_name LIKE '%ilk scarf%';

-- change case
UPDATE raw_data
SET product_type = INITCAP(product_type)
WHERE product_id in ('40688130','41377526','1743853','1891000','24207111');

-- What are shipping options?
SELECT DISTINCT usually_ships_within
FROM raw_data;

-- update null values to false
UPDATE raw_data
SET has_cross_border_fees = false
WHERE has_cross_border_fees IS NULL;

-- verify buyer's fee calculations
SELECT
	price_usd,
	seller_price,
	seller_earning,
	buyers_fees,
	price_usd - seller_price AS buyers_fee_verify
FROM raw_data
WHERE buyers_fees IS NOT NULL
LIMIT 5;

-- update null buyer's fees
UPDATE raw_data
SET buyers_fees = price_usd - seller_price
WHERE buyers_fees IS NULL;

-- Does production information already state color?
SELECT 
	product_type,
	product_name,
	product_description
FROM raw_data WHERE product_color IS NULL;

-- What are color options?
SELECT DISTINCT product_color
FROM raw_data;

-- update null color
UPDATE raw_data
SET product_color = 'Multicolour'
WHERE product_color IS NULL;

-- What are material options?
SELECT DISTINCT product_material
FROM raw_data;

-- update null materials
UPDATE raw_data
SET product_material = 'Not specified'
WHERE product_material IS NULL;





-- Is seller information static?
-- not static if any metric is >1
SELECT 
	seller_id, 
	COUNT(DISTINCT seller_badge) AS badges,
	COUNT(DISTINCT seller_username) AS usernames,
	COUNT(DISTINCT seller_country) AS countries,
	COUNT(DISTINCT seller_community_rank) AS ranks,
	COUNT(DISTINCT seller_num_followers) AS followers
FROM raw_data
GROUP BY seller_id
HAVING COUNT(DISTINCT seller_badge) > 1
	OR COUNT(DISTINCT seller_username) > 1
	OR COUNT(DISTINCT seller_country) > 1
	OR COUNT(DISTINCT seller_community_rank) > 1
	OR COUNT(DISTINCT seller_num_followers) > 1
;

-- Is brand information static?
SELECT 
	brand_id, 
	COUNT(DISTINCT brand_name),
	COUNT(DISTINCT brand_url)
FROM raw_data
GROUP BY brand_id
HAVING COUNT(DISTINCT brand_name) > 1
	OR COUNT(DISTINCT brand_url) > 1
;