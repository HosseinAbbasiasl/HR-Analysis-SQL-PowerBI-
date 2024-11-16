Create Database HR;
USE HR;


SELECT *
FROM HR_DATA


SELECT termdate
FROM HR_DATA
ORDER BY termdate DESC


----Fix termdate formatting----
--1) Convert dates to YYYY-MM-DD
--2) Create new column New_termdate
--3) Copy converted time values from termdate to New_termdate
--4) 120 in the query below is the date time function
--5) In SSMS you can not convert termdate (nvarchar(50)) directly so you have to create new column

UPDATE HR_DATA
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

ALTER TABLE HR_DATA
ADD New_termdate DATE;


-- Copy converted time values from termdate to New_termdate

Update HR_DATA
SET new_termdate = CASE
WHEN termdate is not Null 
	AND ISDATE(termdate) = 1 THEN CAST (termdate as DATETIME)
	ELSE NULL
	END;

--Create a new column "Age"

ALTER TABLE HR_DATA
ADD Age nvarchar(50);

-- Populate new column with Age

UPDATE HR_DATA 
SET Age = DATEDIFF(YEAR, birthdate, GETDATE());


SELECT Age
FROM HR_DATA;

---- Questions to answer from data
--1) What's the age distribution in the company?
--age distribution

SELECT 
	MIN(Age) AS Youngest,
	Max(Age) AS Oldest
FROM HR_DATA;

SELECT Age_group,
COUNT (*) AS Count
FROM
(SELECT 
	CASE
	 WHEN age >=21 AND age <=30 THEN '21 to 30'
	 WHEN age >=31 AND age <=40 THEN '31 to 40'
	 WHEN age >=41 AND age <=50 THEN '41 to 50'
	 ELSE '50+'
	 END AS Age_group
FROM HR_DATA
WHERE New_termdate IS NULL
) AS Subquery
GROUP BY Age_group
ORDER BY Age_group;

--age group by gender

SELECT Age_group, 
Gender,
COUNT (*) AS Count
FROM
(SELECT 
	CASE
	 WHEN age >=21 AND age <=30 THEN '21 to 30'
	 WHEN age >=31 AND age <=40 THEN '31 to 40'
	 WHEN age >=41 AND age <=50 THEN '41 to 50'
	 ELSE '50+'
	 END AS Age_group,
	 Gender
FROM HR_DATA
WHERE New_termdate IS NULL
) AS Subquery
GROUP BY Age_group, Gender
ORDER BY Age_group, Gender;



--2) What's the gender breakdown in the company?

SELECT Gender, 
COUNT(Gender) as Count
FROM HR_DATA
WHERE New_termdate IS NULL
GROUP BY Gender
ORDER BY Gender;



--3) How does gender vary across departments and job titles?

SELECT Department, Gender, 
COUNT(Gender) as Count
FROM HR_DATA
WHERE New_termdate IS NULL
GROUP BY Department, Gender
ORDER BY Department, Gender;

-- Job Titles

SELECT Department, Jobtitle, Gender, 
COUNT(Gender) as Count
FROM HR_DATA
WHERE New_termdate IS NULL
GROUP BY Department, Jobtitle, Gender
ORDER BY Department, Jobtitle, Gender;

--4) What's the race distribution in the company?

SELECT Race, 
COUNT (*) AS Count
FROM HR_DATA
WHERE New_termdate is NULL
GROUP BY Race
ORDER BY Count DESC;


--5) What's the average lenght of employment in the company?

SELECT 
AVG(DATEDIFF(year, hire_date, new_termdate)) AS Tenure
FROM HR_DATA
WHERE New_termdate IS NOT NULL
AND
New_termdate <= GETDATE();



--6) Which department has the highest turnover rate?

-- get total count
-- get terminated count
-- terminated count/total count
SELECT 
Department,
total_count,
terminated_count,
ROUND((CAST(terminated_count AS FLOAT)/total_count), 2)* 100 AS Turnover_rate
FROM
(
	SELECT 
	Department,
	COUNT(*) AS Total_count,
	SUM(CASE
		WHEN New_termdate IS NOT NULL
		AND
		New_termdate <= GETDATE() THEN 1
		ELSE 0
		END) AS Terminated_count
	FROM HR_DATA
	GROUP BY Department
	) AS Subquery
ORDER BY Turnover_rate DESC;



--7) What's the tenure distribution for each department?

SELECT 
Department,
AVG(DATEDIFF(year, hire_date, new_termdate)) AS Tenure
FROM HR_DATA
WHERE New_termdate IS NOT NULL
AND
New_termdate <= GETDATE()
GROUP BY Department
ORDER BY Tenure DESC;


--8) How many employees work remotely for each department?

SELECT location,
COUNT(*) AS Count
From HR_DATA
WHERE New_termdate IS NULL
GROUP BY Location;



--9) What's the distribution of employees across different states?

SELECT 
location_state,
COUNT(*) AS Count
FROM HR_DATA
WHERE New_termdate IS NULL
GROUP BY location_state
ORDER BY Count DESC;

--10) How are job titles distributed across the company?

SELECT Jobtitle,
COUNT(*) AS Count
FROM HR_DATA
WHERE New_termdate IS NULL
GROUP BY jobtitle
ORDER BY Count DESC;



--11) How have employee hire counts varied over time?
-- Calculate hires
-- Calculate terminations
-- (Hire - terminations)/ Hires percent hire change



SELECT 
 Hire_year,
 Hires,
 Terminations,
 Hires - Terminations AS Net_Change,
 ROUND(CAST(Hires-Terminations AS FLOAT)/Hires, 2)*100 AS Percent_hire_change
	  FROM
	  (
		SELECT 
		 YEAR(hire_date) AS Hire_year,
		 COUNT(*) AS Hires,
		 SUM(CASE
				WHEN New_termdate IS NOT NULL
				AND
				New_termdate <= GETDATE() THEN 1
				ELSE 0
				END
				) AS Terminations
		FROM HR_DATA
		GROUP BY YEAR(hire_date)
		) AS Subquery
ORDER BY Percent_hire_change;
