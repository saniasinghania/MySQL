-- # Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). 
-- # If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.

create table lengthofchars(
city varchar(50));

insert into lengthofchars values('ACB');
	
SELECT city, length(city) as length FROM lengthofchars order by length(city) desc, city limit 1;
SELECT * FROM lengthofchars order by (city);

-- # cities starting with vowel

-- # 3 methods
select distinct city from lengthofchars where city regexp '^[aeiou]' order by city asc; -- # regexp is a better way of writing like in SQL
select distinct city from lengthofchars 
where 
city like 'A%' 
or city like 'E%'
or city like 'I%'
or city like 'O%'
or city like 'U%';
select distinct city from lengthofchars where substr(city,1,1) in ('A','E','I','O','U'); 
-- # Therefore, SUBSTR(CITY, 1, 1) means extracting substring at position 1 of length 1 from CITY column.
-- # start extracting characters from position 1 and extract 1 character (length)  
-- # in SQL array starts from 1 
SELECT CITY FROM lengthofchars WHERE LOWER(SUBSTR(CITY,1,1)) in ('a','e','i','o','u');
-- # lower will just make it in lower character and then compare

-- # ending with vowel
select distinct city from lengthofchars where substr(city, length(city), 1) in ('a','e','i','o','u');

-- # starting and ending with vowel
select distinct city from lengthofchars where substr(city,1,1) not in ('A','E','I','O','U') and substr(city, length(city), 1) not in ('a','e','i','o','u');

-- # secondary sort by id

-- #we want to display things in the following way:
-- #ID	Date
-- #1	1/1/2000
-- #2	1/2/2000
-- #1	1/1/2001
-- #2	1/2/2001
-- #1	1/1/2002
-- #2	1/2/2002

-- # and not 1 1 1 2 2 2 in id

-- # this is the code we can use in order by, jo baadme likhenge comma ke baad wo secondary rahega, uske pehle ka primary rahega
-- # order by year(date), id

-- # THE PADS problem
-- # https://www.hackerrank.com/challenges/the-pads/problem?isFullScreen=true

use hackerrank;
create table thepads(
Name varchar(50),
Occupation varchar(50));

insert into thepads values('Mohini','Singer');
select * from thepads;

select concat(Name,'(', left(Occupation,1),')') from thepads;
select concat('There are a total of ', count(Occupation),' ', lower(Occupation),'s.') 
from thepads
group by Occupation
order by count(Occupation) asc, Occupation asc;

-- # PIVOT thepads wala column
select 
group_concat((case when Occupation = 'Doctor'then Name end)) as Doctor,
group_concat(case when Occupation = 'Professor'then Name end) as Professor,
group_concat(case when Occupation = 'Singer'then Name end) as Singer,
group_concat(case when Occupation = 'Actor' then Name end) as Actor
FROM ( SELECT *, row_number() OVER(PARTITION BY OCCUPATION ORDER BY NAME) AS row_num from thepads ) x
group by row_num;
-- # isme squeeze hojayega sab kuch aur sab alag alag se check nahi karega

-- # the below does not work
select 
(case when Occupation = 'Doctor'then Name else null end) as Doctor,
(case when Occupation = 'Professor'then Name else null end) as Professor,
(case when Occupation = 'Singer'then Name else null end) as Singer,
(case when Occupation = 'Actor' then Name else null end) as Actor
from thepads;
-- # the above query is going to pivot par bohot saare null aayenge, wo har baar ek ek mein check kar raha hai

-- # count lead manager, senior manager, manager and employee of a certain company and print it against the founder name
-- # https://www.hackerrank.com/challenges/the-company/problem?isFullScreen=true&h_r=next-challenge&h_v=zen&h_r=next-challenge&h_v=zen;

select c.company_code, 
founder, 
count(distinct l.lead_manager_code), 
count(distinct s.senior_manager_code), 
count(distinct m.manager_code),
count(distinct e.employee_code)
from Company c
left join Lead_Manager l on l.company_code = c.company_code
left join  senior_manager s on s.company_code = c.company_code
left join manager m on m.company_code = c.company_code
left join Employee e on e.company_code = c.company_code
group by c.company_code, founder
order by company_code asc;

-- # student name, grades and marks
create table Grades(
Grade int, min_mark int, max_mark int);

insert into Grades values(10,90,100);

create table Students(
Name varchar(50), Marks int);

insert into Students values('Jane', 81);

select  
(case when Marks >= 70 then concat(Name, ' ', Grade, ' ', Marks) else concat('NULL', ' ', Grade, ' ', Marks) end)
from Students s
join 
Grades g on (s.marks between g.Min_Mark and g.Max_Mark)
order by s.marks desc;

WITH CTE AS (SELECT 
    Name,
    Grade,
    Marks
FROM Students, Grades
WHERE Marks BETWEEN Min_Mark AND Max_Mark)
SELECT concat(
    IF(Grade>7, Name, 'NULL'), ' ',
    Grade, ' ',
    Marks)
FROM CTE
ORDER BY Grade DESC, Name asc, Marks asc;

select
concat(if (grade >=8,Name, 'NULL'), ' ', grade, ' ', marks)
from students s
join grades g
on s.marks between g.min_mark and g.max_mark
order by grade desc, name asc, marks asc;

-- # finding the median of a row
use employees;
select * from employee;
with t1 as(
select round(salary,4) as salary, row_number() over(order by salary) as rownum, count(*) over() as cnt from employee)
select
	(case when mod(max(rownum),2) <> 0 then (select salary from t1 where rownum = (cnt + 1)/2)
	else (select (sum(salary)/2) from t1 where rownum in (cnt/2, 1+ cnt/2)) end) as median
from t1;

-- # print symmetric pairs (doubt)
use hackerrank;
create table symmetric(
X int(2), Y int(2));
insert into symmetric values(21,20);
select * from symmetric;

select distinct s1.X, s1.Y
from (select *, row_number() over (order by x) as rownum from symmetric) s1
join (select *, row_number() over (order by x) as rownum from symmetric) s2
on s1.X  = s2.Y and s1.y = s2.x and s1.rownum != s2.rownum and s1.x<=s1.y
order by s1.x;

select f1.x, f1.y
from symmetric f1
join symmetric f2 on f1.x = f2.y
where f1.x <= f1.y and f1.x = f2.y and f2.x = f1.y
group by f1.x, f1.y
order by f1.x, f1.y	;

SELECT f1.X, f1.Y
FROM symmetric f1
JOIN symmetric f2 ON f1.X = f2.Y AND f2.X = f1.Y
GROUP BY f1.X, f1.Y
HAVING f1.X < f1.Y OR COUNT(f1.X) > 1
ORDER BY f1.X;

-- # earnings of employees
use hackerrank;
create table employee(
id int, 
name varchar(100),
months int,
salary int);

insert into employee values(1, 'Rose',15,2000);
insert into employee values(2, 'Angela',1,3000);
insert into employee values(3, 'Frank',17,1000);
insert into employee values(4, 'Patrick',7,5000);
insert into employee values(5, 'Lisa',11,3000);
insert into employee values(6, 'Kimberly',16,4000);
insert into employee values(7, 'Bonnie',16,4000);

select * from employee;
with t1 as(
    select *, (months*salary) as earnings
    from employee),
t2 as(
    select *, count(earnings) as cnt from t1 group by earnings),
t3 as(
    select *, dense_rank() over(order by earnings desc) as rnk from t2)
select concat(earnings,' ', cnt) as top_earners from t3 order by earnings desc limit 1 offset 0;

select concat(earnings,' ', cnt) as top_earners from(
select *, dense_rank() over(order by earnings desc) as rnk from(
select *, count(earnings) as cnt from (select *, (months*salary) as earnings from employee) y
group by earnings) x) a
order by earnings desc limit 1 offset 0;

select concat(max(months*salary) ,' ',count(months*salary)) from Employee group by months*salary order by months*salary desc limit 1;

select name from employee where name in (select id, name, months, max(salary) where salary < 5000) x;
	
select name from(
select name, max(salary) from employee where salary < 5000) x;
