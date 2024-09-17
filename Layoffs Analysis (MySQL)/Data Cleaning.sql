-- Data Cleaning
SELECT * FROM layoffs;

-- First thing to do is staging of raw table for working and not changing raw table as it might be needed later.
-- Always work on staging table

-- Creating a staging layoffs table 
CREATE TABLE layoffs_staging LIKE layoffs;
SELECT * FROM layoffs;
SELECT * FROM layoffs_staging;

-- Created staging table and contents of raw table to insert in staging table is put forth
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- check for the staging table contents as in raw table
SELECT * FROM layoffs_staging;

-- Successfully staging table is ready for Data cleaning and usually follow these steps
-- 1. Remove Duplicates
-- 2. Standardize the data and Fix errors
-- 3. Observe Null/Blank Values and process
-- 4. Remove any columns that aren't necessary totally


-- 1.Remove Duplicates 
SELECT company, industry, total_laid_off, `date`,
	ROW_NUMBER() OVER(PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Check for Duplicates 
SELECT * FROM(
SELECT company, industry, total_laid_off, `date`,
	ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging) Duplicates
WHERE row_num > 1 ;

-- There are some things to be noted. Lets watch out
SELECT * FROM layoffs_staging
WHERE company ='Oda';

-- Trying to remove duplicates from table
WITH DELETE_CTE AS (
SELECT * FROM(
SELECT company, location,industry, total_laid_off,percentage_laid_off, `date`, stage, country, funds_raised_millions,
	ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) 
    AS row_num
FROM layoffs_staging) Duplicates
WHERE row_num > 1 
)
DELETE FROM DELETE_CTE;

-- Well Delete statement works as update statement in CTE's and so it cannot be used in this.
-- Thus, it would be good to add identifier column to the staging and removing duplicates

-- So create another staging table and adding the contents 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT company, location, industry, total_laid_off,percentage_laid_off, `date`, stage, country, funds_raised_millions,
	ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) 
    AS row_num
FROM layoffs_staging;

-- Deleting the duplicates
DELETE FROM layoffs_staging2
WHERE row_num > 1;
-- View for execution 
SELECT * FROM layoffs_staging2;

-- Hurray! The milestone of removing duplicates is achieved

-- 2. Standardize the data 
 SELECT * FROM layoffs_staging2;
 
 -- Checking company column and removing trailing spaces for uniformity
 SELECT COMPANY, TRIM(COMPANY)
 FROM layoffs_staging2;
 
 UPDATE layoffs_staging2
 SET company = TRIM(COMPANY);
 
 -- Checking industry column
 SELECT industry FROM layoffs_staging2;
 SELECT DISTINCT industry FROM layoffs_staging2
 ORDER BY 1;
 
 SELECT * FROM layoffs_staging2
 WHERE industry LIKE 'Crypto%';
 
 -- Crypto is not uniform. So we are making it uniform
 UPDATE layoffs_staging2
 SET industry = 'Crypto'
 WHERE industry LIKE 'Crypto%';
 
 -- Likewise analyze every column and enhance uniformity for analysis
 
 SELECT DISTINCT country FROM layoffs_staging2
 ORDER BY 1;
 
 -- Period in the US record and it breaks uniformity. Well lets remove that
 UPDATE layoffs_staging2
 SET country = TRIM(TRAILING '.' FROM country)
 WHERE country LIKE 'United States%';
 
 -- Date column is in text format and it is not legitimate for further analysis. So lets update it into date format (yyyy/mm/dd).
 UPDATE layoffs_staging2
 SET date = str_to_date(`date`, '%m/%d/%Y');
 
 -- Convert date column into date format
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;
 
 -- Yahoo! Reached another milestone. Lets go into final process
 
 -- 3. Observe Blank/Null values and process
 SELECT * FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL;
 -- Well it is fine to be blank and useful in analysis further
 
SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT * FROM layoffs_staging2
where company ='airbnb';
-- So here found some company are same but industry is left blank in multiple layoffs entries. So, its time to populate those values
-- Lets perform joining so that to verify matching during updation

SELECT * FROM layoffs_staging2 t1
	JOIN layoffs_staging t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

-- Thats it the match is perfect. But before updating ensure to nullify the blank to avoid errors
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Carry out populating the records
UPDATE layoffs_staging2 t1
    JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- A huge task as a novice learner. But finished populating. Bally's Interactive remains null as it is distinct.

-- 4. Remove columns that aren't necessary totally
SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- In the EDA phase, the records with null in total and percentage laid off columns  won't be contributing majorly. So its better to remove
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Finally Data cleaning project is over and this is our project. Next this would be in EDA phase
SELECT * FROM layoffs_staging2;

