-- -- # windows function
-- -- # useful in solving analytical problems

-- -- # to find total combined salary of employees of each department
use employees;

select * from employees order by SALARY DESC;

select FIRST_NAME, DEPARTMENT_ID, sum(SALARY) over (partition by DEPARTMENT_ID)  from employees;

-- -- # ROW NUMBER

select e.*,
row_number() over(order by SALARY) as rn
from employee e;

select e.*,
row_number() over(partition by DEPT_NAME) as rn
from employee e;

select e.*,
row_number() over(partition by DEPT_NAME order by SALARY) as rn
from employee e;

-- -- # fetch 1st 2 employees to join each dept given that the employee who joins later has a greater emp id than previous emp
select * from(
	select e.*, -- # this is now a subquery
	row_number() over(partition by DEPT_NAME order by emp_ID) as rn
	from employee e) x
where x.rn < 3;	

select row_number() over(order by SALARY) as row_num , FIRST_NAME, SALARY from employees order by SALARY;

-- -- # ROW NUMBER ENDS






create table demo(st_id int, st_name varchar(20));

insert into demo
values(101,'Shane'),(102,'Bradley'),(103,'Herath'),(103,'Herath'),
(104,'Nathan'),(105,'Kevin'),(105,'Kevin');

select * from demo;

-- -- # to find duplicate values in the dataset

-- -- # first count how many rows are duplicate

-- -- # method 1
select st_id, st_name, count(*) as CNT from demo group by st_id, st_name having CNT > 1; 

-- -- # method 2 
select st_id, st_name, row_number() over (partition by st_id, st_name order by st_id) as row_num from demo;

-- # method 3
-- # delete from demo where st_id not in ( select MAX(st_id) as MaxRecord from demo group by st_id, st_name ) ;

-- #delete from CTE
-- #where row_num > 1;



-- # Lead function
-- # fetch the users who logged in consecutively 3 or more times
use youtube;
select * from login_details; 

select distinct user_name -- -- # kyuki james repeated hai, toh distinct use kiya to choose unique names
from (
select *,
case when user_name = lead(user_name) over(order by login_id) -- #1st record compare with next
and  user_name = lead(user_name,2) over(order by login_id) -- #1st record compare with next to next
then user_name 
else null
end as repeated_names 
from login_details) x
where x.repeated_names is not null;

-- # ye jo subquery hai wo repeated names bata dega par dusre column mein 
select *,
case when user_name = lead(user_name) over(order by login_id) -- #1st record compare with next
and  user_name = lead(user_name,2) over(order by login_id) -- #1st record compare with next to next
then user_name 
else null
end as repeated_names 
from login_details;


-- # to interchange the adjacent student names.

create table students
(
id int primary key,
student_name varchar(50) not null
);
insert into students values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin');

select * from students;

select id,student_name,
case when id % 2 <> 0 then lead(student_name) over(order by id)
when id % 2 = 0 then lag(student_name) over(order by id) end as new_student_name
from students; 
-- # in the above method, robin is left out, so figuring out a way to do that

select id,student_name,
case when id % 2 <> 0 then lead(student_name,1,student_name) over(order by id) -- #hamne bata diya usko ki agar wo aage nahi badh pata hai toh by default usko apna student name is daal lena hai column mein
-- # toh yaha kyuki robin ka koi succeeding name nahi hai even though wo odd number hai toh islie we need to make this little change for robin
when id % 2 = 0 then lag(student_name) over(order by id) end as new_student_name
from students; 

-- # agar even number of rows hote toh:
drop table students2;
create table students2
(
id int primary key,
student_name varchar(50) not null
);
insert into students2 values
(1, 'James'),
(2, 'Michael'),
(3, 'George'),
(4, 'Stewart'),
(5, 'Robin'),
(6, 'Pam');

select * from students2;
select id,student_name,
case when id % 2 <> 0 then lead(student_name) over(order by id)
when id % 2 = 0 then lag(student_name) over(order by id) end as new_student_name
from students2; 
-- # this method works for when there are even number of rows

-- # fetch all the records when London had extremely cold temperature for 3 consecutive days or more.
use youtube;
create table weather
(
id int,
city varchar(50),
temperature int,
day date
);

insert into weather values
(1, 'London', -1, str_to_date('2021/01/01','%Y/%m/%d')),		
(2, 'London', -2, str_to_date('2021/1/2','%Y/%m/%d')),
(3, 'London', 4, str_to_date('2021/01/03','%Y/%m/%d')),
(4, 'London', 1, str_to_date('2021/01/04','%Y/%m/%d')),
(5, 'London', -2, str_to_date('2021/01/05','%Y/%m/%d')),
(6, 'London', -5, str_to_date('2021/01/06','%Y/%m/%d')),
(7, 'London', -7, str_to_date('2021/01/07','%Y/%m/%d')),
(8, 'London', 5, str_to_date('2021/01/08','%Y/%m/%d'));

select * from weather;

-- # select str_to_date('02/02/1930','%m/%d/%Y');















-- #First value()
select * from employees ; 
select FIRST_NAME, SALARY, first_value(SALARY)
over (order by SALARY desc) as highest_salary from employees; -- # comparison of others' salary with max salary


select FIRST_NAME, SALARY, DEPARTMENT_ID, first_value(FIRST_NAME)
over (partition by DEPARTMENT_ID order by SALARY desc) as highest_salary
from employees; -- # comparison of employee salary wrt their department's maximum salary

















