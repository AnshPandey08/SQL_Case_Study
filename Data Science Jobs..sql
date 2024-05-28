/*1.You're a Compensation analyst employed by a multinational corporation. 
Your Assignment is to Pinpoint Countries who give work fully remotely,for the title 'managers’ Paying salaries Exceeding $90,000 USD*/

select * from salaries;
Select job_title from salaries;
Select distinct company_location from salaries where job_title like '%Manager%' and salary_in_usd >90000 and remote_ratio=100;


/* 2.AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. 
you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies. */

Select * from salaries;
SELECT company_locatiON, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_locatiON 
ORDER BY cnt DESC
LIMIT 5;

 
 /*3. Picture yourself AS a data scientist Working for a workforce management platform.
 Your objective is to calculate the percentage of employees. Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, 
 Shedding light ON the attractiveness of high-paying remote positions IN today's job market. */
 
 Set @total = (select Count(*) from salaries where salary_in_usd>100000);
 Set @count = (select Count(*) from salaries where salary_in_usd>100000 and remote_ratio = 100);
 set @percentage= round(((select @count) / (select @total))*100,2);
 select @percentage as 'Percentage';
 
 /*4.	Imagine you're a data analyst Working for a global recruitment agency. 
 Your Task is to identify the Locations where entry-level average salaries exceed the average salary for that job title IN market 
 for entry level, helping your agency guide candidates towards lucrative opportunities. */
 
 Select * from salaries;
 Select t.job_title, company_location, average, average_per_country from
 (
 Select job_title, avg(salary_in_usd) as 'average' from salaries group by job_title
 )t
 inner join(
 Select company_location, job_title,avg(salary_in_usd) as 'average_per_country' from salaries group by job_title,company_location
 )m
 on  t.job_title = m.job_title where average_per_country > average;



/* 5.  You've been hired by a HR Consultancy to look at how much people get paid In different countries.Your job is to find out for each job 
title which Country pays the maximum average salary . This helps you to place your candidates in those countries. */

Select * from salaries;
Select * from
(
 Select *, dense_rank() over ( partition by job_title order by average desc)  as 'num' from
(
Select company_location, job_title, avg(salary_in_usd) as 'average' from salaries group by company_location, job_title
)t
)k where num = 1;

/*6. As a data-driven Business Consultant, you've been hired by a multinational corporation to analyze salary
trends across company locations. Your goal is to Pinpoint locations WHERE the average salary has consistently increased over the Past
few years(Countries WHERE data is available for 3 years Only(present year and past two years) providing Insights into Locations
experiencing Sustained salary growth. */

With DS as
(
    Select * from salaries where company_location in
   (
    select company_location from
   (
    Select company_location,  avg(salary_in_usd) as 'average' , count(distinct work_year) as 'cnt' from salaries where work_year >= year(current_date())-2 
    group by company_location having cnt = 3
   )t
   )
)

select company_location , 
MAX(case when work_year=2022 THEN average END) as AVG_salary_2022,
MAX(case when work_year=2023 THEN average END) as AVG_salary_2023,
MAX(case when work_year=2024 THEN average END) as AVG_salary_2024
from
(
select company_location, work_year , avg(salary_in_usd) as average from DS group by company_location, work_year
)q group by company_location having AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023> AVG_salary_2022;
 
/*  7. Picture yourself AS a workforce strategist employed by a global HR tech startup. 
Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021 and compare it WITH the 
corresponding figures for 2024, Highlighting any significant Increases or decreases IN remote work Adoption over the years. */

WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level


/* 8. AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. 
Your objective is to calculate the average salary increase percentage for each experience level and job title 
between the years 2023 and 2024, helping the company stay competitive IN the talent market.  */

With t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title 
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL 


/* 9. You're a database administrator tasked with role-based access control for a company's employee database. 
Your goal is to implement a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) 
can only access details relevant to their respective experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.
 */
 
 select * from salaries
 select distinct experience_level from salaries
 Show privileges

CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';

CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN'
GRANT SELECT ON campusx.entry_level TO 'Entry_level'@'%'
UPDATE view entry_level set WORK_YEAR = 2025 WHERE EMPLOYNMENT_TYPE='FT'
 
 /*10. You are working with a consultancy firm, your client comes to you with certain data and preferences such as 
 (their year of experience , their employment type, company location and company size )  and want to make an transaction 
 into different domain in data industry (like  a person is working as a data analyst and want to move to some other domain 
 such as data science or data engineering etc.) your work is to  guide them to which domain they should switch to base on  
 the input they provided, so that they can now update their knowledge as  per the suggestion/.. The Suggestion should be based 
 on average salary.
 */
 
 DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.

call GetAverageSalary('EN','FT','AU','M');
drop procedure Getaveragesalary





