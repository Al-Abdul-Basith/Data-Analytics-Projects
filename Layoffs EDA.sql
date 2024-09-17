SELECT * FROM layoffs_staging2;

-- The data in the table has undergone cleaning process and ready for Exploratory Data Analysis (EDA)
-- So moving on to this phase, there are lot many things to do with this data stuff and explore to extract meaningful insights
-- Well, lets perform some analysis of data and get insights about layoffs by companies in various sectors between the year 2020-2023
-- Here we are going to explore the data and find trends or patterns or any interesting facts about layoffs

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Above data shows a huge total layoff which is 12000 and percentage of layoff is 1 i.e. the company has been shutdown. Shocking!

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY 1 ASC;

-- Well, the numbers are so huge that around 116 companies have laid off totally and shows the shutdown of company
-- Also most of the companies are looking to be startups or in its initial stage of essence in market and covid had hit them significantly it seems

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;

-- Shocking to see that BritishVolt and Quibi raised a huge amount of funds as a startup and demised miserably. Checkout on browser for failures of company

SELECT INDUSTRY, MAX(total_laid_off) FROM layoffs_staging2
GROUP BY INDUSTRY
ORDER BY 2 DESC;

SELECT INDUSTRY, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY INDUSTRY
ORDER BY 2 DESC;

-- It is disheartening to see the consumer, retail sectors had more layoffs and shows impact of covid maybe

SELECT COUNTRY, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY COUNTRY
ORDER BY 2 DESC;

SELECT COUNTRY, MAX(total_laid_off) FROM layoffs_staging2
GROUP BY COUNTRY
ORDER BY 2 DESC;

-- USA and INDIA had top layoffs and USA has created nightmares for its workers seems

SELECT location, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

SELECT location, MAX(total_laid_off) FROM layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- SF Bay Area, Seattle, NY City, Amsterdam, Bengaluru had huge layoffs.

SELECT company, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 5;

SELECT company, total_laid_off FROM layoffs_staging2
ORDER BY 2 DESC
LIMIT 5;   

-- Leading tech giants like Meta, Google, Amazon , Microsoft increased layoffs seems

SELECT YEAR(date) AS year, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

-- Post-covid effects reflect disastrous layoffs in 2022 and 2023

SELECT stage, SUM(total_laid_off) FROM layoffs_staging2
GROUP BY STAGE 
ORDER BY 1 ASC;

-- POST-IPO companies has raised enormous layoffs certainly

SELECT SUBSTRING(`date`,1,7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC;

-- Lets find out per month layoffs and rolling total of layoffs between March 2020 - March 2023 using CTE

WITH RollingTotal AS(
SELECT SUBSTRING(`date`,1,7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY dates
ORDER BY dates ASC)
SELECT dates, total_laid_off, SUM(total_laid_off) OVER(ORDER BY dates ASC) AS Rolling_Total_layoffs
FROM RollingTotal;

-- Around more than 380000 layoffs have been estimated from March 2020 - March 2023
-- Enormous layoffs were driven during November 2022, January 2023, February 2023

WITH Company_Year AS
( SELECT company, YEAR(date) as years, SUM(total_laid_off) as total_laid_off FROM layoffs_staging2
  GROUP BY company, Year(date)
),
Company_Year_Rank AS 
( SELECT company, years, total_laid_off,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC)
AS ranking FROM Company_Year
)
SELECT company, years, total_laid_off, ranking FROM Company_Year_Rank
WHERE (ranking<=5) AND (years IS NOT NULL)
ORDER BY years ASC, total_laid_off DESC;

-- Well we have found companies with most layoffs per year and assigning & returning top 5 companies with most layoffs per year
-- In 2020 Uber, 2021 Bytedance, 2022 Meta, 2023 Google companies had most layoffs

/* So we can explore more and more in the given data based on stated requirements. Summary of the explored insights from layoffs data
(March 2020 - March 2023)

 01. Maximum single time layoff - 12000 and Maximum percentage of layoff - 1.
 02. 116 companies have been shutdown.
 03. Consumer and Retail industries had witnessed more layoffs.
 04. BritishVolt and Quibi company(Start-up) have raised greater funds and dropped out from market.
 05. USA and India had top layoffs among the countries.
 06. SF Bay Area, Seattle, NY City, Amsterdam, Bengaluru had top layoffs among location.
 07. Tech Giants like Meta, Google, Microsoft, Amazon are the companies with enormous layoffs
 08. Disastrous layoff drives were carried during 2022 and 2023 and minimum layoffs were seen during 2021
 09. POST-IPO stage companies carried out huge layoffs, around more than 200000 people had lost their job.
 10. More than 380000 people have lost their job during layoffs that have been estimated from March 2020 - March 2023 data.
 11. Huge layoffs were driven by companies during November 2022, January 2023 and February 2023.
 12. In the year 2020 Uber, 2021 Bytedance, 2022 Meta and 2023 Google companies had carried out most layoffs.
  
Well these are the exploration of data and insights mined from data.
*/


-- Extra works
With Rolling_Total AS(
SELECT company, SUM(total_laid_off) as India_layoff FROM layoffs_staging2
WHERE country = "india" AND total_laid_off IS NOT NULL
GROUP BY company
ORDER BY 2 DESC
)
SELECT company, India_layoff, SUM(India_layoff) OVER(ORDER BY Company) AS Rolling_Total_layoff
FROM Rolling_Total;

-- Rolling total of layoffs estimate to 36000 peoples by companies in India.

SELECT company, SUM(funds_raised_millions) FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
GROUP BY company
ORDER BY 2 DESC;

-- Netflix raised huge funds followed by Uber, WeWork, Twitter, ByteDance among top 5 funds raised companies




 