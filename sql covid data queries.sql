CREATE TABLE CovidData (
    Province VARCHAR(255),
    Country_Region VARCHAR(255),
    Latitude FLOAT,
    Longitude FLOAT,
    Date DATE,
    Confirmed INT,
    Deaths INT,
    Recovered INT
);
ALTER TABLE CovidData MODIFY Date VARCHAR(10);
ALTER TABLE CovidData MODIFY Latitude decimal(50,10);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Corona Virus Dataset.csv' into table CovidData 
fields terminated by ','
ignore 1 lines;

SHOW VARIABLES LIKE "secure_file_priv";
SET SQL_SAFE_UPDATES = 0;


Select count(*) from CovidData;
select * from CovidData;

-- Q1. Write a code to check NULL values
SELECT 
    (SELECT COUNT(*) FROM CovidData WHERE Province IS NULL) AS NullProvince,
    (SELECT COUNT(*) FROM CovidData WHERE Country_Region IS NULL) AS NullCountryRegion,
    (SELECT COUNT(*) FROM CovidData WHERE Latitude IS NULL) AS NullLatitude,
    (SELECT COUNT(*) FROM CovidData WHERE Longitude IS NULL) AS NullLongitude,
    (SELECT COUNT(*) FROM CovidData WHERE Date IS NULL) AS NullDate,
    (SELECT COUNT(*) FROM CovidData WHERE Confirmed IS NULL) AS NullConfirmed,
    (SELECT COUNT(*) FROM CovidData WHERE Deaths IS NULL) AS NullDeaths,
    (SELECT COUNT(*) FROM CovidData WHERE Recovered IS NULL) AS NullRecovered;



-- Q2. If NULL values are present, update them with zeros for all columns. 
-- Update NULL values in the Province column to an empty string (as it is a VARCHAR column)
UPDATE CovidData SET Province = '' WHERE Province IS NULL;

-- Update NULL values in the Country_Region column to an empty string (as it is a VARCHAR column)
UPDATE CovidData SET Country_Region = '' WHERE Country_Region IS NULL;

-- Update NULL values in the Latitude column to zero
UPDATE CovidData SET Latitude = 0 WHERE Latitude IS NULL;

-- Update NULL values in the Longitude column to zero
UPDATE CovidData SET Longitude = 0 WHERE Longitude IS NULL;

-- Update NULL values in the Date column to '0000-00-00' (as it is a VARCHAR column)
UPDATE CovidData SET Date = '0000-00-00' WHERE Date IS NULL;

-- Update NULL values in the Confirmed column to zero
UPDATE CovidData SET Confirmed = 0 WHERE Confirmed IS NULL;

-- Update NULL values in the Deaths column to zero
UPDATE CovidData SET Deaths = 0 WHERE Deaths IS NULL;

-- Update NULL values in the Recovered column to zero
UPDATE CovidData SET Recovered = 0 WHERE Recovered IS NULL;

-- Q3. check total number of rows
SELECT COUNT(*) AS TotalRows FROM CovidData;

-- Q4. Check what is start_date and end_date
SELECT MIN(Date) AS Start_Date,MAX(Date) AS End_Date FROM CovidData;

-- Q5. Number of month present in dataset
SELECT 
    COUNT(DISTINCT CONCAT(YEAR(parsed_date), '-', MONTH(parsed_date))) AS NumberOfMonths
FROM (
    SELECT 
        CASE
            WHEN Date LIKE '%-%-%' THEN STR_TO_DATE(Date, '%d-%m-%Y')
            WHEN Date LIKE '%/%/%' THEN STR_TO_DATE(Date, '%d/%m/%Y')
            ELSE NULL
        END AS parsed_date
    FROM CovidData
) AS formatted_dates
WHERE parsed_date IS NOT NULL;

-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT 
    DATE_FORMAT(parsed_date, '%Y-%m') AS YearMonth,
    AVG(Confirmed) AS AvgConfirmed,
    AVG(Deaths) AS AvgDeaths,
    AVG(Recovered) AS AvgRecovered
FROM (
    SELECT 
        CASE
            WHEN Date LIKE '%-%-%' THEN STR_TO_DATE(Date, '%d-%m-%Y')
            WHEN Date LIKE '%/%/%' THEN STR_TO_DATE(Date, '%d/%m/%Y')
            ELSE NULL
        END AS parsed_date,
        Confirmed,
        Deaths,
        Recovered
    FROM CovidData
) AS formatted_dates
WHERE parsed_date IS NOT NULL
GROUP BY YearMonth
ORDER BY YearMonth;

-- Q7. Find most frequent value for confirmed, deaths, recovered each month 
SELECT 
    MAX(Most_Frequent_Confirmed) AS Most_Frequent_Confirmed,
    MAX(Most_Frequent_Deaths) AS Most_Frequent_Deaths,
    MAX(Most_Frequent_Recovered) AS Most_Frequent_Recovered
FROM (
    SELECT 
        MONTH(Date) AS Month,
        Confirmed AS Most_Frequent_Confirmed,
        0 AS Most_Frequent_Deaths,
        0 AS Most_Frequent_Recovered
    FROM 
        CovidData
    GROUP BY 
        Month, Confirmed
    UNION ALL
    SELECT 
        MONTH(Date) AS Month,
        0 AS Most_Frequent_Confirmed,
        Deaths AS Most_Frequent_Deaths,
        0 AS Most_Frequent_Recovered
    FROM 
        CovidData
    GROUP BY 
        Month, Deaths
    UNION ALL
    SELECT 
        MONTH(Date) AS Month,
        0 AS Most_Frequent_Confirmed,
        0 AS Most_Frequent_Deaths,
        Recovered AS Most_Frequent_Recovered
    FROM 
        CovidData
    GROUP BY 
        Month, Recovered
) AS MonthlyData;

-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT 
    Year,
    MIN(Min_Confirmed) AS Minimum_Confirmed,
    MIN(Min_Deaths) AS Minimum_Deaths,
    MIN(Min_Recovered) AS Minimum_Recovered
FROM (
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        MIN(Confirmed) AS Min_Confirmed,
        0 AS Min_Deaths,
        0 AS Min_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
        0 AS Min_Confirmed,
        MIN(Deaths) AS Min_Deaths,
        0 AS Min_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        0 AS Min_Confirmed,
        0 AS Min_Deaths,
        MIN(Recovered) AS Min_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
) AS YearlyData
WHERE 
    Year IS NOT NULL
GROUP BY 
    Year;




-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT 
    Year,
    MAX(Max_Confirmed) AS Maximum_Confirmed,
    MAX(Max_Deaths) AS Maximum_Deaths,
    MAX(Max_Recovered) AS Maximum_Recovered
FROM (
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        MAX(Confirmed) AS Max_Confirmed,
        0 AS Max_Deaths,
        0 AS Max_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
        0 AS Max_Confirmed,
        MAX(Deaths) AS Max_Deaths,
        0 AS Max_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        0 AS Max_Confirmed,
        0 AS Max_Deaths,
        MAX(Recovered) AS Max_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year
) AS YearlyData
WHERE 
    Year IS NOT NULL
GROUP BY 
    Year;


-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT 
    Year,
    Month,
    SUM(Total_Confirmed) AS Total_Confirmed,
    SUM(Total_Deaths) AS Total_Deaths,
    SUM(Total_Recovered) AS Total_Recovered
FROM (
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
        SUM(Confirmed) AS Total_Confirmed,
        SUM(Deaths) AS Total_Deaths,
        SUM(Recovered) AS Total_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year, Month
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) AS Month,
        SUM(Confirmed) AS Total_Confirmed,
        SUM(Deaths) AS Total_Deaths,
        SUM(Recovered) AS Total_Recovered
    FROM 
        CovidData
    GROUP BY 
        Year, Month
) AS MonthlyData
WHERE 
    Year IS NOT NULL AND Month IS NOT NULL
GROUP BY 
    Year, Month;

-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    (SELECT SUM(Confirmed) FROM CovidData) AS Total_Confirmed_Cases,
    (SELECT AVG(Confirmed) FROM CovidData) AS Average_Confirmed_Cases,
    (SELECT VARIANCE(Confirmed) FROM CovidData) AS Variance_Confirmed_Cases,
    (SELECT STDDEV(Confirmed) FROM CovidData) AS Standard_Deviation_Confirmed_Cases;


-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    Year,
    Month,
    SUM(Deaths) AS Total_Death_Cases,
    AVG(Deaths) AS Average_Death_Cases,
    VARIANCE(Deaths) AS Variance_Death_Cases,
    STDDEV(Deaths) AS Standard_Deviation_Death_Cases
FROM (
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
        Deaths
    FROM 
        CovidData
    WHERE 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) IS NOT NULL
        AND MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) IS NOT NULL
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) AS Month,
        Deaths
    FROM 
        CovidData
    WHERE 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) IS NOT NULL
        AND MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) IS NOT NULL
) AS Data
GROUP BY 
    Year, Month;


-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    Year,
    Month,
    SUM(Recovered) AS Total_Recovered_Cases,
    AVG(Recovered) AS Average_Recovered_Cases,
    VARIANCE(Recovered) AS Variance_Recovered_Cases,
    STDDEV(Recovered) AS Standard_Deviation_Recovered_Cases
FROM (
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) AS Month,
        Recovered
    FROM 
        CovidData
    WHERE 
        YEAR(STR_TO_DATE(Date, '%d-%m-%Y')) IS NOT NULL
        AND MONTH(STR_TO_DATE(Date, '%d-%m-%Y')) IS NOT NULL
    UNION ALL
    SELECT 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) AS Year,
        MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) AS Month,
        Recovered
    FROM 
        CovidData
    WHERE 
        YEAR(STR_TO_DATE(Date, '%d/%m/%Y')) IS NOT NULL
        AND MONTH(STR_TO_DATE(Date, '%d/%m/%Y')) IS NOT NULL
) AS Data
GROUP BY 
    Year, Month;

-- Q14. Find Country having highest number of the Confirmed case
SELECT Country_Region,MAX(Confirmed) AS Max_Confirmed_Cases FROM CovidData 
GROUP BY 
	Country_Region
ORDER BY 
    Max_Confirmed_Cases DESC
LIMIT 1;

-- Q15. Find Country having lowest number of the death case
SELECT Country_Region,MIN(Deaths) AS Min_Death_Cases FROM CovidData 
GROUP BY 
	Country_Region
ORDER BY 
    Min_Death_Cases 
LIMIT 1;

-- Q16. Find top 5 countries having highest recovered case
SELECT 
    Country_Region,
    SUM(Recovered) AS Total_Recovered_Cases
FROM 
    CovidData
GROUP BY 
    Country_Region
ORDER BY 
    Total_Recovered_Cases DESC
LIMIT 5;
