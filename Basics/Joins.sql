-- # note
-- # the right side of the equation is fixed while the left side gets incremented till it finds the one in the right table. 
-- # you can use group by while joining tables as well (leetcode 512 is a good example (game play analysis II))
use youtube;
drop table employee;
create table employee
( emp_ID char(20)
, emp_name varchar(50) not null
, salary int
, dept_id varchar(50)
, manager_id varchar(20));

select * from employee;

insert into employee values('E1', 'Rahul', 15000, 'D1', 'M1');
insert into employee values('E2', 'Manoj',15000,'D1','M1');
insert into employee values('E3', 'James', 55000, 'D2','M2');
insert into employee values('E4', 'Michael', 25000, 'D2', 'M2');
insert into employee values('E5', 'Ali', 20000, 'D10', 'M3');
insert into employee values('E6', 'Robin', 35000, 'D10', 'M3');

drop table manager;
create table manager
( manager_id varchar(20),
manager_name varchar(50),
dept_id varchar(20));

insert into manager values('M1', 'Prem', 'D3');
insert into manager values('M2', 'Shripadh','D4');
insert into manager values('M3','Nick', 'D1');
insert into manager values('M4', 'Cory', 'D1');

select * from manager;


drop table department;
create table department
(dept_id varchar(20),
dept_name varchar(50));

insert into department values('D4', 'Admin'); 	

select * from department;

drop table projects;
create table projects
( project_id varchar(20),
project_name varchar(100),
team_member_id varchar(20));

insert into projects values('P2', 'ETL Tool', 'M4');

select * from projects;


-- # JOINS

-- # INNER JOIN/ JOIN (both names mean the same)

-- # fetch the employee name and the department name they belong to
select * from employee;
select * from department;

select e.emp_name, d.dept_name
from employee e
join department d on e.dept_id = d.dept_id;
-- # ab isme sirf 4 employees ka naam aaya aur baaki choot gaye kyuki unka dept name nahi tha
-- # manager ne bola ki saare employees ka name chahiye, hence we can use left join in this case

-- # fetch ALL the employee name and the department name they belong to

-- # LEFT JOIN / LEFT OUTER JOIN

select e.emp_name, d.dept_name
from employee e
left join department d on e.dept_id = d.dept_id;
-- # left join jab use karte hai toh former(left) table ko priority deke uske saare values print hote hai and 
-- # latter(right) table ke sirf matching values print hote hai
-- # left join = inner joi + any additional records in the left table

-- # RIGHT JOIN / RIGHT OUTER JOIN
select e.emp_name, d.dept_name
from employee e
right join department d on e.dept_id = d.dept_id;
-- # right join = inner join + additional records in the right table

-- # fetch details of ALL employees, their manager, their department, and the project they work on
select * from manager;
select * from projects;
select * from employee;
select * from department;

select e.emp_name, m.manager_name, d.dept_name, p.project_name
from employee e
inner join manager m on e.manager_id = m.manager_id -- #inner kyuki saare employees ke paas managers hai jo manager table mein present hai, we can also use left join it will give same result
left join department d on e.dept_id = d.dept_id
left join projects p on p.team_member_id = e.emp_id;

-- # FULL OUTER JOIN/ FULL JOIN   

-- # full outer join = inner join + additional records in left table + additional records in right table
-- # full outer join = inner join + left join + right join
-- # since mySQL does not support full join, we can use union of left join + right join

select e.emp_name, d.dept_name
from employee e
left join department d on e.dept_id = d.dept_id
union
select e.emp_name, d.dept_name
from employee e
right join department d on e.dept_id = d.dept_id;


-- # CROSS JOIN
-- # cross is a cartesian product
select e.emp_name, d.dept_name
from employee e -- # 6 records
cross join department d order by dept_name; -- # 4 records
-- # table on 6 records of employee table matched with every record in dept table
-- # isme kabhi bhi join condition nahi dete hai, cross join mein it is not needed

drop table company;
create table company(
company_id varchar(20),
company_name varchar(50),
location varchar(20));

insert into company values('C001', 'TechTFQ Solutions','Kuala Lumpur');
select * from company;

-- # write a query to fetch all employee names and their department
-- # also write their company and company location corresponding to each employee

select e.emp_name, d.dept_name, c.company_name, c.location
from employee e
left join department d on e.dept_id = d.dept_id
cross join company c;

-- # example: menu combinations with 2 tables: food and drinks

-- # NATURAL JOIN

select e.emp_name, d.dept_name
from employee e
natural join department d;
-- # inner join hogaya

alter table department rename column dept_id to id;

select e.emp_name, d.dept_name
from employee e
natural join department d;
-- # cross join hogaya

alter table department rename column id to dept_id;

-- # why shouldn't we use Natural join?
-- # - because it doesn't allow the user to choose the columns, usko jo theek lagta hai wo match kardega
-- # - if the two tables joining have a column with same name then it will match them and join them (jitne rahenge sab kardega)
-- # - if there are 2 tables having no same column toh cross join hojayega

-- # SELF JOIN
-- # very important type of join 
-- # joining a table to itself

create table family(
member_id varchar(20),
name varchar(50),
age int,
parent_id varchar(10));

select * from family;

insert into family values('F8','Asha','8','F4');

-- # display parent names and ages of all family members

-- # isme apneko parent_id ke jo names and ages hai wo display karne hai family table ke andar hi
-- # aise cases mein self join use karte hai
-- # isme sirf join use karte hai bas same table mention karke usko alias dusra dena padta hai, we can do left, right join also.
select child.name as child_name, child.age as child_age, parent.name as parent_name, parent.age as parent_age
from family as child
join family as parent on child.parent_id = parent.member_id;

-- # iska result ulta hoga jab ham child.member_id = parent.parent_id use karenge instead of jo pehle kiya
select child.name as child_name, child.age as child_age, parent.name as parent_name, parent.age as parent_age
from family as child
join family as parent on child.member_id = parent.parent_id;

-- # left join bhi kar sakte hai, jiska parent ka info nahi hai wo bhi print hojayega
select child.name as child_name, child.age as child_age, parent.name as parent_name, parent.age as parent_age
from family as child
left join family as parent on child.parent_id = parent.member_id;


