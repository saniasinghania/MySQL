-- # to print highest salary in each department

use youtube;
select * from employee;
select * from department;

select e.emp_name, e.salary, d.dept_name, e.dept_id
from employee e join department d on e.dept_id = d.dept_id
where (salary, e.dept_id) in
(select max(salary), dept_id from employee group by dept_id);

select * from
(select e.emp_name, e.salary, d.dept_name, e.dept_id,
rank() over (partition by dept_name order by salary desc) as rnk
from employee e join department d on e.dept_id = d.dept_id) x
where rnk =1 ;

-- # return nth highest salary in the employee table: (if nth highest salary does not exist then print null)
-- # n = 1 is 55000 (1st highest salary)

-- # nth highest salary find, if doesn't exist print null

select 
	ifnull(
			(select salary from
			(select distinct salary,
			dense_rank() over (order by salary desc) as rnk
			from employee) x
			where rnk = 2)
			, null) 
as abc;

SELECT
    IFNULL(
      (SELECT DISTINCT Salary
       FROM Employee
       ORDER BY Salary DESC
        LIMIT 1 OFFSET 1),
    NULL) AS SecondHighestSalary;

-- # numbers that appear atleast 3 times consecutively
create table sample2(
id int, num int);

select * from sample2;

-- # using self joins
select distinct a.num
from sample2 a
join sample2 b on a.id = b.id - 1 and a.num = b.num -- # we're checking consecutive results hence id should be consecutive and numbers should be equal
join sample2 c on a.id = c.id + 1 and a.num = c.num;
	
-- # using lag lead functions
select distinct num from
(select num, 
lead(num) over (order by id) as lead_,
lag(num) over (order by id) as lag_
from sample2) x
where num = lead_ and num = lag_ ;

-- # duplicate numbers

create table emails(
id int, email varchar(50));

insert into emails values(1,'sania@a.com');
insert into emails values(2,'sania@b.com');
insert into emails values(3,'sania@a.com');

select * from emails;

select email from(
select email, count(email) as count from emails group by email) x
where count > 1;

-- # employee salary greater than manager salary

insert into earnmore values (4,'Max',90000,null);

select * from earnmore;

select a.name as Employee
from earnmore a 
join earnmore b
on a.managerId = b.id
and a.salary > b.salary;

-- # swap salary

-- # update table_name set sex = if('m','f','m'); 

-- # higher temperature than previous date
select * from weather;

select 
case when temperature > lag(temperature) over (order by id)
then id else null end id
from Weather;

select a.id
from weather a
join weather b
on a.temperature > b.temperature and a.day = b.day + 1 ;


-- # delete duplicate values
use youtube;
select * from emails;
    
DELETE p2
FROM emails p1
JOIN emails p2
ON p1.Email = p2.Email
where p1.id < p2.id;

select count(email) from emails group by email;

-- # write a query to report the distance traveled by each user in descending order
-- # a users table with id and name
-- # a riders table with id, passenger_user_id, distance

select u.name, sum(r.distance) as distance_travelled 
from users u left join riders r 
on users.id = riders.passenger_user_id 
group by u.id 
order by distance_travelled desc;

-- # make a pivot table
create table pivot 
( student_id int, subject varchar(20), marks int);

insert into pivot values(1002,'Maths',83);
select * from pivot;

select student_id,
sum(case when subject = 'English' then marks else 0 end) as English,
sum(case when subject = 'Science' then marks else 0 end)  as Science,
sum(case when subject = 'Maths' then marks else 0 end) as Maths
from pivot group by student_id;

-- # Write a SQL query to find the cancellation rate of requests with unbanned users 
-- #(both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". 
-- #Round Cancellation Rate to two decimal points.

-- # The cancellation rate is computed by dividing the number of canceled (by client or driver)
-- # requests with unbanned users by the total number of requests with unbanned users on that day.
drop table Trips;
create table Trips(
id int, client_id int, driver_id int, city_id int, status varchar(20), request_at date);

insert into Trips values(
10,4,13,12,'cancelled_by_driver','2013-10-03');

select * from Trips;

create table Users(
users_id int, banned ENUM('Yes','No'), role ENUM('client','driver'));

insert into Users values(13,'No','driver');

select * from Users;

with unbannedclient as
				(select users_id as Id
				 from Users
				 where banned = 'No' and role = 'client'),
unbanneddriver as
				(select users_id as Id
				 from Users
				 where banned = 'No' and role ='driver'),
unbannedtrips as 
    (select Trips.Status, Trips.request_at, 
    count(*) as count
    from Trips
        join unbannedclient on Trips.client_id = unbannedclient.Id
        join unbanneddriver on Trips.driver_id = unbanneddriver.Id
    group by 
            Trips.Status, Trips.request_at),
totalunbannedtrips as 
    (select 
        request_at, sum(count) as total_trips
    from unbannedtrips group by request_at ),
-- # select * from totalunbannedtrips;
completeunbannedtrips as
    (select request_at, count as completetrips
    from unbannedtrips
    where Status!='completed')
select * from completeunbannedtrips;

select totalunbannedtrips.request_at as Day,
round(ifnull(completetrips,0)/ total_trips,2) as 'Cancellation Rate'
from totalunbannedtrips left join completeunbannedtrips
on totalunbannedtrips.request_at = completeunbannedtrips.request_at
where totalunbannedtrips.request_at >= cast('2013-10-01' as date)
and totalunbannedtrips.request_at <= cast('2013-10-03' as date);
