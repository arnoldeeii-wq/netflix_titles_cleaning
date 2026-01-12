-- Netflix Titles Cleaning Session
-- Steps:
-- 1. Create staging table
-- 2. Add persistent row numbers (via CTE + JOIN)
-- 3. Standardize missing values (director, cast, country)
-- 4. Commit changes
-- Author: Arnold
-- Date: 2026-01-09

-- 1) Create staging table and copy data

CREATE TABLE netflix_titles_staging LIKE netflix_titles;
INSERT netflix_titles_staging SELECT * FROM netflix_titles;

-- 2) Add a permanent row number column

ALTER TABLE netflix_titles_staging
ADD COLUMN updated_show_id INT;

-- Generate row numbers and update staging
WITH numbered AS (
    SELECT 
        ROW_NUMBER() OVER () AS rn,
        show_id  
    FROM netflix_titles
)
UPDATE netflix_titles_staging nts
JOIN numbered n ON nts.show_id = n.show_id
SET nts.updated_show_id = n.rn;

-- 3) Standardize missing values
-- Director → 'Unknown'
UPDATE netflix_titles_staging
SET director = 'Unknown'
WHERE director = '' OR TRIM(director) = '';

-- Cast → 'Not found'
UPDATE netflix_titles_staging
SET cast = 'Not found'
WHERE cast = '' OR TRIM(cast) = '';

-- Country → 'N/A'
UPDATE netflix_titles_staging
SET country = 'N/A'
WHERE country = '' OR TRIM(country) = '';

-- 4) Persist changes
COMMIT;

-- Verify
SELECT *
FROM netflix_titles_staging
;
