-- copy raw_data as working table
CREATE TABLE wip AS TABLE raw_data;





-- count null product records
SELECT COUNT(DISTINCT product_id) 
FROM wip
WHERE product_category IS NULL;


-- update product categories
-- --------------------------------------------------
-- men shoes
UPDATE wip
SET product_category = 'Men Shoes'
WHERE product_category IS NULL
	AND (product_type LIKE '%ace up%' -- lace ups
		OR product_type LIKE '%oot%' -- boots
		OR product_type LIKE '%spadrille%' -- espadrilles
		OR product_type LIKE '%lat%' -- flats
		OR product_type LIKE '%rainer%' -- trainers
);

-- men clothing
UPDATE wip
SET product_category = 'Men Clothing'
WHERE product_category IS NULL
	AND (product_type LIKE '%ermuda%' -- bermuda shorts
		OR product_type LIKE '%oat%' -- coat
		OR product_type LIKE '%ull%' -- pull over
		OR product_type LIKE '%acket%' -- jacket
		OR product_type LIKE '%ean%' -- jeans
		OR product_type LIKE '%weatshirt%' -- Knitwear & sweatshirt
		OR product_type LIKE '%rouser%' -- trousers
		OR product_type LIKE '%est%' -- vest
		OR product_type LIKE '%arka%' -- parka
		OR product_type LIKE '%uffer%' -- puffer
		OR product_type LIKE '%hirt%' -- shirt
		OR product_type LIKE '%hort%' -- shorts
		OR product_type LIKE '%wimwear%' -- swimwear
		OR product_type LIKE '%rench%' -- trench
);

-- men accessories
UPDATE wip
SET product_category = 'Men Accessories'
WHERE product_category IS NULL
	AND (product_type LIKE '%at%' -- hat
		OR product_type LIKE '%elt%' -- belt
		OR product_type LIKE '%carf%' -- scarf
		OR product_type LIKE '%ie%' -- tie
		OR product_type LIKE '%unglass%' -- sunglasses
		OR product_type LIKE '%ewellery%' -- jewelry
		OR product_type LIKE '%ufflink%' -- cufflinks
	);

-- women clothing
UPDATE wip
SET product_category = 'Women Clothing'
WHERE product_category IS NULL
	AND (product_type LIKE '%louse%' -- blouse
		OR product_type LIKE '%lazer%' -- blazer
		OR product_type LIKE '%amisole%' -- camisole
		OR product_type LIKE '%ardigan%' -- cardigan
		OR product_type LIKE '%nitwear%' -- knitwear
		OR product_type LIKE '%ant%' -- pants
		OR product_type LIKE '%rouser%' -- trousers
		OR product_type LIKE '%orset%' -- corset
		OR product_type LIKE '%ress%' -- dress
		OR product_type LIKE '%umper%' -- jumper
		OR product_type LIKE '%umpsuit%' -- jumpsuit
		OR product_type LIKE '%egging%' -- leggings
		OR product_type LIKE '%oncho%' -- poncho
		OR product_type LIKE '%kirt%' -- skirt
		OR product_type LIKE '%ra%' -- bra
		OR product_type LIKE '%olo%' -- polo
		OR product_type LIKE '%op%' -- top
		OR product_type LIKE '%tole%' -- stole
		OR product_type LIKE '%arem%' -- harem pants
		OR product_type LIKE '%lip%' -- slip
	);

-- women accessories
UPDATE wip
SET product_category = 'Women Accessories'
WHERE product_category IS NULL
	AND (product_type LIKE '%ase%' -- case
		OR product_type LIKE '%ing%' -- ring
		OR product_type LIKE '%allet%' -- wallet
		OR product_type LIKE '%urse%' -- purse
		OR product_type LIKE '%hoker%' -- choker
	);






-- new column subcategories (based on Vestiaire website subcategories)
ALTER TABLE wip
ADD COLUMN product_subcat TEXT;


-- update subcategories
-- --------------------------------------------------
-- batch 1: women main
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%rouser' OR 
		product_type LIKE '%rousers' THEN 'Trousers'
	WHEN product_type LIKE '%kirt%' THEN 'Skirts'
	WHEN product_type LIKE '%eans%' THEN 'Jeans'
	WHEN product_type LIKE '% _hort%' OR  
		product_type LIKE '_hort%' OR 
		product_type LIKE '%ombishort%' THEN 'Shorts'
	WHEN product_type LIKE '%acket%' THEN 'Jackets'
	WHEN product_type LIKE '%nitwear%' THEN 'Knitwear' 
	WHEN product_type LIKE '%oat%' THEN 'Coats'
	WHEN product_type LIKE '%op%' OR 
		product_type LIKE '_op%' THEN 'Tops'
	WHEN product_type LIKE '%ress%' THEN 'Dresses'
	WHEN product_type LIKE '%wimwear%' THEN 'Swimwear'
	WHEN product_type LIKE '%umpsuit%' THEN 'Jumpsuit'
	WHEN product_type LIKE '%ingerie%' THEN 'Lingerie'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Women Clothing';

-- batch 2: women secondary
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%pants' OR 
		product_type LIKE '%arem%' OR 
		product_type LIKE '%hino%' OR 
		product_type LIKE '%verall%' OR 
		product_type LIKE '%egging%' THEN 'Trousers' 
	WHEN product_type LIKE '%ermuda%' THEN 'Shorts'
	WHEN product_type LIKE '%lazer%' OR 
		product_type LIKE '%aban%' OR 
		product_type LIKE '%uffer%' OR 
		product_type LIKE '%oncho%' OR 
		product_type LIKE '%arka%' OR 
		product_type LIKE '%ape' THEN 'Jackets'
	WHEN product_type LIKE '%umper%' OR 
		product_type LIKE '%weatshirt%' OR 
		product_type LIKE '%ardi%' OR 
		product_type LIKE '%win_set%' THEN 'Knitwear'
	WHEN product_type LIKE '%louse%' OR 
		product_type LIKE '%hirt%' OR 
		product_type LIKE '%-shirt%' OR 
		product_type LIKE '%amisole%' OR 
		product_type LIKE '%unic%' OR 
		product_type LIKE '%est%' OR 
		product_type LIKE '%olo%' OR 
		product_type LIKE '%orset%' THEN 'Tops'
	WHEN product_type LIKE '%wimsuit%' OR 
		product_type LIKE '%areo%' OR 
		product_type LIKE '%ath a%' THEN 'Swimwear'
	WHEN product_type LIKE '%ra%' OR 
		product_type LIKE '%ight%' OR 
		product_type LIKE '%lip%' OR 
		product_type LIKE '%ustier%' OR 
		product_type LIKE '%tring%' THEN 'Lingerie'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Women Clothing';

-- batch 3: men main
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%rousers%' THEN 'Trousers'
	WHEN product_type LIKE '%eans%' OR
		product_type LIKE '%lim%ean%' THEN 'Jeans'
	WHEN product_type LIKE '% _hort%' OR  
		product_type LIKE '_hort%' OR 
		product_type LIKE '%ombishort%' THEN 'Shorts'
	WHEN product_type LIKE '%acket%' THEN 'Jackets'
	WHEN product_type LIKE '%nitwear%' THEN 'Knitwear' 
	WHEN product_type LIKE '%oat%' THEN 'Coats'
	WHEN product_type LIKE '%wimwear%' THEN 'Swimwear'
	WHEN product_type LIKE '%-shirt%' THEN 'T-shirts'
	WHEN product_type LIKE '%olo%' THEN 'Polo Shirts'
	WHEN product_type LIKE '%hirt%' THEN 'Shirts'
	WHEN product_type LIKE '%rench%' THEN 'Trench Coats'
	WHEN product_type LIKE '%uit%' THEN 'Suit'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Men Clothing';

-- batch 4: men secondary
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%ermuda%' THEN 'Shorts'
	WHEN product_type LIKE '%ants%' THEN 'Trousers'
	WHEN product_type LIKE '%umper%' OR 
		product_type LIKE '%weatshirt%' OR 
		product_type LIKE 'Pull%' OR 
		product_type LIKE '% pull' OR 
		product_type LIKE '%ardigan%' THEN 'Knitwear'
	WHEN product_type LIKE '%uffer%' OR
		product_type LIKE 'Puffer%' OR
		product_type LIKE 'Vest%' OR
		product_type LIKE '%arka%' OR 
		product_type LIKE '% vest' THEN 'Jackets'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Men Clothing';

-- update subcat (remained null due to product_type casesensitivity)
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_id = '41377526' THEN 'T-shirts'
	WHEN product_id = '40688130' THEN 'Trousers'
	ELSE NULL
END
WHERE product_subcat IS NULL;

-- update miscategorized vests from jackets to knitwear
UPDATE wip
SET product_subcat = 'Knitwear'
WHERE product_category = 'Men Clothing'
	AND product_type LIKE '%est%' -- vest
	AND product_keywords LIKE '%nitwear%' -- knitwear
;

-- batch 5: women accessories main
UPDATE wip
SET product_subcat = 
	CASE
	WHEN product_type LIKE '%ilk%chief%' THEN 'Silk Handkerchief'
	WHEN product_type LIKE '%carf%' THEN 'Scarves' 
	WHEN product_type LIKE '%glass%' THEN 'Sunglasses'
	WHEN product_type LIKE '%hat%' OR 
		product_type LIKE '%Hat' OR
		product_type LIKE 'Hat%' THEN 'Hats'
	WHEN product_type LIKE '%atch%' THEN 'Watches'
	WHEN product_type LIKE '%allet%' THEN 'Wallets'
	WHEN product_type LIKE '%elt%' THEN 'Belts'
	WHEN product_type LIKE '%urse%' THEN 'Purses, Wallets & Cases' 
	WHEN product_type LIKE '%love%' THEN 'Gloves' 
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Women Accessories';

-- batch 6: women accessories secondary
UPDATE wip
SET product_subcat = 
	CASE
	WHEN product_type LIKE '%tole%' OR 
		product_type LIKE '%chief%' OR 
		product_type LIKE '%hoker%' OR 
		product_type LIKE '%heche%' THEN 'Scarves'
	WHEN product_type LIKE '%eanie%' OR 
		product_type LIKE '%cap%' OR 
		product_type LIKE 'Cap%' OR 
		product_type LIKE '%eret%' OR 
		product_type LIKE '%anama%' THEN 'Hats'
	WHEN product_type LIKE '%ase%' OR 
		product_type LIKE '%ing%' OR 
		product_type LIKE '%lutch%' OR 
		product_type LIKE '%iary%' OR 
		product_type LIKE '%ccessories' THEN 'Purses, Wallets & Cases'
	WHEN product_type LIKE '%itten%' THEN 'Gloves'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Women Accessories';

-- batch 7: men accessories
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%tie%' OR 
		product_type LIKE 'Tie%' THEN 'Ties'
	WHEN product_type LIKE '%glass%' THEN 'Sunglasses'
	WHEN product_type LIKE '%hat%' OR 
		product_type LIKE 'Hat%' THEN 'Hats'
	WHEN product_type LIKE '%quare%' OR 
		product_type LIKE '%carf%' OR 
		product_type LIKE '%chief%' THEN 'Scarves & Pocket Squares'
	WHEN product_type LIKE '%ewellery%' THEN 'Jewellery'
	WHEN product_type LIKE '%atch%' THEN 'Watches'
	WHEN product_type LIKE '%elt%' THEN 'Belts'
	WHEN product_type LIKE '%ufflink%' THEN 'Cufflinks'
	WHEN product_type LIKE '%love%' THEN 'Gloves'
	WHEN product_type LIKE '%allet%' OR 
		product_type = 'Cloth lifestyle' THEN 'Purses, Wallets & Cases'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Men Accessories';

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Shoes',
	product_subcat = 'Mules & Clogs'
WHERE product_id IN ('43058381','42759624');

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Clothing',
	product_subcat = 'Dresses'
WHERE product_id = '42488417';

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Clothing',
	product_subcat = 'Skirts'
WHERE product_id = '42813693';

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Clothing',
	product_subcat = 'Lingerie'
WHERE product_id = '42859923';

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Clothing',
	product_subcat = 'Trousers'
WHERE product_id IN ('42997568','42523183');

-- update miscategorized records from Men Accessories
UPDATE wip
SET product_category = 'Women Accessories',
	product_subcat = 'Purses, Wallets & Cases'
WHERE product_id = '14242992';

-- batch 8: women shoes
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%rainer%' THEN 'Trainers'
	WHEN product_type LIKE '%ules & clog%' OR 
		product_type LIKE '%ule%' THEN 'Mules & Clogs'
	WHEN product_type LIKE '%lat%' THEN 'Flats'
	WHEN product_type LIKE '%andal%' OR 
		product_type LIKE '%lip flop%' THEN 'Sandals'
	WHEN product_type LIKE '%eel%' OR 
		product_id = '41822032' THEN 'Heels'
	WHEN product_type LIKE '%spadrilles%' THEN 'Espadrilles'
	WHEN product_type LIKE '%ace up%' THEN 'Lace-ups'
	WHEN product_type LIKE '%oot%' THEN 'Boots'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Women Shoes';

-- batch 9: men shoes
UPDATE wip
SET product_subcat =
	CASE
	WHEN product_type LIKE '%rainer%' THEN 'Trainers'
	WHEN product_type LIKE '%lat%' THEN 'Flats'
	WHEN product_type LIKE '%andal%' OR 
		product_type LIKE '%lip flop%' THEN 'Sandals'
	WHEN product_type LIKE '%oot%' THEN 'Boots'
	WHEN product_type LIKE '%spadrilles%' THEN 'Espadrilles'
	WHEN product_type LIKE '%ace up%' THEN 'Lace-ups'
	ELSE NULL
END
WHERE product_subcat IS NULL
	AND product_category = 'Men Shoes';

-- update null subcat
UPDATE wip
SET product_subcat = 
	CASE
	WHEN product_id = '24207111' THEN 'Trainers'
	WHEN product_id IN ('1743853','1891000') THEN 'Boots'
	WHEN product_id = '38648728' THEN 'Lace-ups'
	ELSE NULL
END
WHERE product_subcat IS NULL;

-- count null product records
SELECT COUNT(DISTINCT product_id) 
FROM wip
WHERE product_subcat IS NULL;


-- transform product categories
-- --------------------------------------------------
UPDATE wip
SET product_category =
	CASE
	WHEN product_category LIKE '%Clothing' THEN 'Clothing'
	WHEN product_category LIKE '%Shoes' THEN 'Shoes'
	WHEN product_category LIKE '%Accessories' THEN 'Accessories'
	ELSE product_category
END;

-- check categories
SELECT DISTINCT product_category
FROM wip;