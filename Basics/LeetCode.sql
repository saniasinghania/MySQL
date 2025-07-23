-- # Leetcode 175
-- # combining two tables
select Person.FirstName, Person.LastName, Address.City, Address.State 
from Person
left join Address
on Person.PersonId = Address.PersonId;

-- # leetcode 176
-- # second highest salary, else null if does not exists
select *, dense_rank() over(order by salary desc) from employee;
select salary from employee order by salary desc;
-- # method 1 (not quite the right method)
select SALARY from (select SALARY,
rank() over(order by SALARY desc) as rnk from employee) x
where rnk = 2;
-- # this will not print null if 2nd highest salary does not exist
-- # method 2
select ifnull(
(select salary from(
select distinct salary, 
dense_rank() over(order by SALARY desc) as rnk 
from employee) x 
where rnk = 2)
, null)
as SecondHighestSalary;
-- # method 3
use employees;
select ifnull( 
(select distinct salary from employee order by salary desc limit 1 offset 1)
, null) 
as nthhighestsalary;
-- # method 4
select ifnull(
(select max(salary) as secondhighestsalary from employee where salary not in (select max(salary) from employee))
, null)
as SecondHighestSalary;

-- # leetcode 178
-- # rank scores
-- # method 1
select salary, dense_rank() over (order by salary desc) as rnk from employee;
-- # method 2
select e1.salary, (select count(distinct salary) from employee e2 where e2.salary >= e1.salary) as 'rank'
from employee e1
order by salary desc;
-- # so imagine this like percentile, if 11000 is the highest, it has only 1 number in the table that is equal to or higher than itself, i.e 11000 in this case. 
-- # similarly 10000 has 2 numbers equal or greater than itself, i.e 10000 and 11000. Hence the rank is 2. So and so forth.

-- # leetcode 180 
-- # consecutive number 
-- # print numbers that appear atleast three times consecutively
use youtube;
select * from sample2;
alter table sample2 rename consecutive;
select * from consecutive;

-- # method 1
select num from(
select *, lag(num) over (order by id) as 'prev', lead(num) over (order by id) as 'next' from consecutive) x
where num = prev and num = next;
-- # method 2
select distinct c1.num as consecutive_number
from consecutive c1
join consecutive c2 on c2.id = c1.id + 1 and c1.num = c2.num
join consecutive c3 on c3.id = c1.id + 2 and c1.num = c2.num;

-- #or 

select c1.num from consecutive c1
join consecutive c2 on c2.id = c1.id + 1
join consecutive c3 on c3.id = c1.id +2
where c1.num = c2.num = c3.num;

-- # method 3
select distinct num1 from(
select c1.num as num1, c2.num as num2, c3.num as num3 from consecutive c1
join consecutive c2
on c1.id = c2.id
join consecutive c3
on c1.id = c3.id + 1
join consecutive c4
on c1.id = c4.id -1) x
where num1 = num2  and num2 =  num3; 

-- # LeetCode 181 
-- # employees earning more than their managers
-- # no table here, use imagination
select * from employee;
select emp_ID from employee e1
join employee e2
on e1.emp_ID = e2.manager_id;

create table employee2 like employee;
insert into employee2 select * from employee;
update employee2 set manager_id = replace(manager_id, 'M1','E4');
update employee2 set manager_id = replace(manager_id, 'M2','E5');
update employee2 set manager_id = replace(manager_id, 'M1','E4');
update employee2 set manager_id = replace(manager_id, 'M3','E2');
select * from employee2;

select * from employee2;
select e1.emp_name as subordinate, e2.emp_name as manager 
from employee2 e1
join employee2 e2
on e1.manager_id = e2.emp_ID
where e1.salary > e2.salary;

-- # LeetCode 182
-- # Duplicate emails
use youtube;

select * from emails;
-- # method 1
select email from(
select email, count(email) as c
from emails
group by email) x
where c > 1;
-- # method 2
select email
from emails
group by email
having count(email) > 1;
-- # method 3
select distinct e1.email
from emails e1 join emails e2 on e1.email = e2.email and e1.id != e2.id;
 

-- # Leetcode 196
-- # Delete duplicate emails
use youtube;
select * from emails;
delete e2
from emails e1 
join emails e2 on e1.email = e2.email and e1.id < e2.id;

insert into emails values(3,'sania@a.com');

drop table emails;
create table emails(id int, email varchar(50));
insert into emails values(1,'sania@a.com');
insert into emails values(2,'sania@b.com');
insert into emails values(3,'sania@a.com');

-- # Leetcode 183
-- # Customers who never order 
-- # there are 2 tables: customers (customerid and name) and order (orderid and customerid)
-- # virtual tables




-- # method 1
select Customers.Name as Customers
from Customers 
left join Orders
on Customers.Id = Orders.CustomerId
where Orders.CustomerId is NULL;
-- # jab left join karenge, toh jin customers ne order nahi kiya unke isme 'null' likhke aayega kyuki uski id hi nahi hai (left join speciality)
-- # method 2
select Name as Customers
from Customers
where customerId not in (Select CustomerId from Orders);

-- # leetcode 184
-- # department highest salary
use employees;
select * from employees;
-- # method 1
select FIRST_NAME, max(salary), department_id from employees group by DEPARTMENT_ID order by department_id;
-- # this is printing distinct, agar 2 max salaries hai toh dono print nahi karega
-- # method 2
select salary, department_id, first_name from (
select salary, department_id, first_name, rank() over (partition by department_id order by salary desc) as rnk from employees) x
where rnk = 1;
-- # department_id = 90 mein do logo ki salary 17000 hai jo maximum hai uss dept ki, ye method 2 dono print karega
-- # method 3 (on a different dataset having 2 different tables)
-- # table 1 has: id, name, salary, dept_id and table 2 has: dept_id, dept_name
-- # we have to print dept_name, salary, name
use employees;
create table department2(
id int,
name varchar(20));
create table employee2(
id int, 
name varchar(40), 
salary int, 
dept_id int);
insert into department2 values(2, 'Sales');
insert into employee2 values(7,'Will',70000,1);
select * from employee2;
select * from department2;

-- # method 1
with t1 as
(select *, dense_rank() over (partition by dept_id order by salary desc) as rnk from employee2),
t2 as
(select d.name as DepartmentName, e.name as EmployeeName, e.salary, rnk from t1 e join department2 d
on e.dept_id = d.id)
select * from t2 where rnk = 1 ;
-- # this will print all repeated max salaries as well
-- # method 2
select name, salary, dept_name from(
select e.name, e.salary, d.name as dept_name, dense_rank() over (partition by d.name order by salary desc) as rnk
from employee2 as e
join department2 as d
on e.dept_id = d.id) x
where rnk = 1;

-- # leetcode 185
-- # top three department salaries
select * from employee2;
select * from department2;
-- # method 1
select name, salary, dept_id, rnk from(
select e.name, e.salary, d.name as dept_id, dense_rank() over (partition by d.id order by salary desc) as rnk 
from employee2 e
join department2 d
on e.dept_id = d.id) x
where rnk < 4;
-- # method 2
with t1 as
(select *, dense_rank() over (partition by dept_id order by salary desc) as rnk from employee2),
t2 as
(select d.name as DepartmentName, e.name as EmployeeName, e.salary, rnk from t1 e join department2 d
on e.dept_id = d.id)
select * from t2 where rnk < 4;

-- # leetcode 262
-- # trips and users


-- # leetcode
-- # gameplay analysis I
select player_id, min(event_id) as first_login from Activity group by player_id;

-- # Leetcode 512
-- # gameplay analysis II
drop table Activity;
Create table Activity (player_id int, device_id int, event_date date, games_played int);
insert into Activity (player_id, device_id, event_date, games_played) values ('1', '2', '2016-03-01', '5');
insert into Activity (player_id, device_id, event_date, games_played) values ('1', '2', '2016-03-02', '6');
insert into Activity (player_id, device_id, event_date, games_played) values ('2', '3', '2017-06-25', '1');
insert into Activity (player_id, device_id, event_date, games_played) values ('3', '1', '2019-03-02', '0');
insert into Activity (player_id, device_id, event_date, games_played) values ('3', '4', '2018-07-03', '5'); -- # observe the date properly
select * from Activity;
-- # we have to print the device that is first logged in by each player

-- # method 1
select player_id, device_id from
(select *, dense_rank() over (partition by player_id order by event_date) as rnk from Activity) x
where rnk = 1;
-- # method 2
select a.player_id, a.device_id from
(select player_id, min(event_date) as event_date from Activity group by player_id) Filtered join Activity a
on Filtered.player_id = a.player_id and Filtered.event_date = a.event_date;
-- # method 3
select a1.device_id, a1.event_date from Activity a1
join Activity a2
on a1.player_id = a2.player_id
where a1.event_date <= a2.event_date
group by a1.player_id;

-- # leetcode 596
-- # Classes more than 5 students
-- # IMPORTANT
create table student(
student varchar(3),
class varchar(10));
insert into student values('I','Math');
select * from student;
-- # method 1
select class from
(select class, count(class) as c from student group by class) count
where c >=5;
-- # method 2
select class from student group by class
having count(distinct student) >=5;
-- # using having because hamne aggregate function use kiya haki

-- # leetcode 620
-- # not boring movies
-- # id should be odd
-- # description should be not boring
-- # order the rating desc
select * from cinema
where id % 2 = 1 and description != 'boring'
order by rating desc;

-- # leetcode 627
-- # swap salary, male ka female and vice versa
-- # do not use any select statements, only update statements can be used
-- # method 1
update salary set sex = if(sex = "m","f","m");
-- # method 2
update salary set sex = case when sex = "m" then "f" else "m" end;

-- # leetcode 1068
-- # product sales I
select p.product_name, s.year, s.price 
from Sales s join Product p
on s.product_id = p.product_id;

-- # leetcode 1069
-- # product sales II
-- # isme product id diye hai aur unke quantity sold diye hai, hamko har product id 
-- # ka abhi tak jitne quantity sell kiye hai wo calculate karna hai
-- # A 50, B 50, A 20, C 60
-- # solution should be A 70, B 50, C 60

select product_id, sum(quantity) as Total_Quantity from (
select p.product_name, s.quantity, s.product_id from products
join sales s
where s.product_id = p.product_id)x
group by product_id;
-- #or
select product_id, sum(quantity) as Total_Quantity from Sales 
group by product_id;

-- # leetcode 1082
-- # sales analysis I
-- # report sellers with maximum sale
Create table If Not Exists Product (product_id int, product_name varchar(10), unit_price int);
Create table If Not Exists Sales (seller_id int, product_id int, buyer_id int, sale_date date, quantity int, price int);
Truncate table Product;
insert into Product (product_id, product_name, unit_price) values ('1', 'S8', '1000');
insert into Product (product_id, product_name, unit_price) values ('2', 'G4', '800');
insert into Product (product_id, product_name, unit_price) values ('3', 'iPhone', '1400');
Truncate table Sales;
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values ('1', '1', '1', '2019-01-21', '2', '2000');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values ('1', '2', '2', '2019-02-17', '1', '800');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values ('2', '1', '3', '2019-06-02', '1', '800');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values ('3', '3', '3', '2019-05-13', '2', '2800');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values ('4', '1', '2', '2019-03-27', '1', '1000');
select * from Product;
select * from Sales;
-- # inappropriate method
select seller_id, max(total_sales) from(
select seller_id, sum(price) as total_sales from Sales group by seller_id) x;
-- # isme seller 3 ka aayega hi nahi, hence this method is not appropriate
-- # method 1 
select seller_id from(
select seller_id, rank() over (order by total_price desc) as rnk from(
select seller_id, sum(price) as total_price from Sales group by seller_id) x) a
where rnk = 1;
-- # method 2
select seller_id from Sales group by seller_id having sum(price) = 
(select sum(price) as total_price from Sales group by seller_id order by total_price desc limit 1 offset 0);
-- # method 3
with t1 as(
select seller_id, sum(price) as total_sales from Sales group by seller_id),
t2 as(
select *, dense_rank() over (order by total_sales desc) as rnk from t1)
select seller_id from t2 where rnk = 1;

-- # leetcode 1083
-- # sales analysis II
-- # report buyers who have bought S8 but not iphone
select * from Product;
select * from Sales;

-- # method 1
select Sales.*, Product.*
from Sales join Product
on Sales.product_id = Product.product_id 
group by buyer_id  
having sum(product_name = "S8") > 0 and sum(product_name = "iPhone") = 0;
-- # even though the table does not show S8 bought by buyer_id 2 after using group by, sum(products) mein uska S8 note mein aayega SQL ke, so don't worry even if you're grouping
-- # the summation does its job properly
-- # method 2
with t1 as (
select Sales.buyer_id, Product.product_name
from Sales join Product 
on Sales.product_id = Product.product_id)

select distinct buyer_id from t1 where product_name = "S8"
and buyer_id not in (
select buyer_id from t1 where product_name = "iPhone");

-- # leetcode 1084
-- # sales analysis III
-- # product names that were only sold in between 2019-01-01 and 2019-03-31 both inclusive
-- # product that have been sold of out these dates should not be included
select * from Product;
select * from Sales;

create view product_sales as(
select s.*, p.product_name, p.unit_price from Sales s
join Product p
on s.product_id = p.product_id);

select * from product_sales;
-- # method 1 using view and between statement
select product_name from product_sales
where sale_date between '2019-01-01' and '2019-03-03'
and product_name not in (select product_name from product_sales where
sale_date > '2019-03-03');

-- # method 2
with t1 as(
select Product.product_name as product_name, Sales.sale_date, Sales.product_id
from Sales join Product 
on Sales.product_id = Product.product_id)
select product_name, product_id from t1
where sale_date >= '2019-01-01' and sale_date <= '2019-03-31'
and product_name not in (
select product_name from t1 where sale_date >= '2019-03-31');
-- # method 3
select Product.product_name, Product.product_id
from Sales join Product 
on Sales.product_id = Product.product_id
group by product_id
having min(sale_date) >= '2019-01-01' and max(sale_date) <='2019-03-31';
-- # method 3
SELECT 
	p.product_id,
	p.product_name,
	s.sale_date 
FROM Sales s 
JOIN product p 
  ON s.product_id = p.product_id 
GROUP BY p.product_id, p.product_name 
HAVING SUM(s.sale_date BETWEEN '2019-01-01' AND '2019-03-31') > 0 
  AND SUM(s.sale_date NOT BETWEEN '2019-01-01' AND '2019-03-31') = 0;
-- # method 4
SELECT p.product_id,p.product_name
 FROM Product p
 inner join Sales s
 on p.product_id=s.product_id
 GROUP BY p.product_id
 HAVING MIN(s.sale_date) >= '2019-01-01' AND MAX(s.sale_date)<='2019-03-31';
 
 -- # leetcode 1179
 -- # pivot table / reformatting the table
 create table departmentpivot(
 id int, revenue int, month varchar(5));
 insert into departmentpivot values(1,6000,'Jan');
 select * from departmentpivot;

 -- # method 1
select id,
sum(case when month = 'Jan' then revenue else null end) Jan,
sum(case when month = 'Feb' then revenue else null end) as Feb,
sum(case when month = 'Mar' then revenue else null end) as Mar
from departmentpivot group by id;
-- # method 2
select * from departmentpivot group by id;
select id,
sum(if(month = 'Jan', revenue, null)) as Jan,
sum(if(month = 'Feb', revenue, null)) as Feb,
sum(if(month = 'Mar', revenue, null)) as Mar
from departmentpivot
group by id;
-- # why do we use sum?
-- # because hamne kyuki groupby use kiya, we want to check all values of revenue inside every group of each month instead of only one, islie sum use karna padta hai 

-- # leetcode 1777
-- # reformatting table
select product_id,
sum(if(store = 'store1',price,null)) as store1,
sum(if(store = 'store2',price,null)) as store2,
sum(if(store = 'store3',price,null)) as store3
from Products
group by product_id;
-- # yaha sum, max, min, avg kuch bhi use kar sakte hai because kisi product ki kisi store mein ek hi price rahegi, pichle problem jaise nahi hai ye

-- # leetcode 1571
-- # warehouse manager
select name as warehouse_name, sum(width*height*length*units) as volume
from Warehouse join Products on Warehouse.product_id = Products.product_id
group by name;

-- # leetcode 1661
 -- # Average Time of Process per Machine
 -- # to find average time every machine takes to complete a process
 -- # method 1
 select machine_id, a.timestamp as start_time, b.timestamp as end_time,
 round(avg(b.timestamp - a.timestamp),3) as processing_time -- # avg barobar kaam karega kyuki hamne group by use kiya hai
 from Activity a join Activity b 
 on a.machine_id = b.machine_id
 and a.process_id = b.process_id
 where a.activity_type = 'start' and b.activity_type = 'end' -- # a table se saare start times extract karlo aur b table se saare end time
 group by machine_id;
 -- # in this method we made new
 -- # method 2
select machine_id, round(avg (end_timestamp - start_timestamp),3) as processing_time
from
(
select machine_id, process_id,
SUM(if(activity_type ='start', timestamp,null)) AS start_timestamp, -- # isme pivot table wala concept apply kardiya
SUM(if(activity_type ='end', timestamp,null)) AS end_timestamp -- # yaha bhi pivot kardiya 
from Activity
group by machine_id, process_id
) as t
group by machine_id;

-- # leetcode 1407
-- # Top Travellers
-- # method 1
with t1 as(
select user_id,
sum(distance) as travelled_distance
from Rides
group by user_id order by travelled_distance desc)
select users.name, ifnull(t1.travelled_distance,0) -- # ifnull(a,b) if a is null then print b otherwise print a
from users left join t1 -- # agar koi distance travel nahi kiya toh 0 dalna hai
on users.id = t1.user_id
order by (travelled_distance) desc, (name) asc;
-- # method 2: left join method
select users.name, ifnull(sum(distance),0) as travelled_distance
-- # we can also use coalesce(sum(distance),0)
from users left join Rides
on users.id = t1.user_id
group by user_id
order by travelled_distance desc, name asc;

-- # leetcode 1741
-- # Find Total Time Spent by Each Employee
-- # Common interview question
create table employee3(
id int, day date, in_time int, out_time int);
insert into employee3 values(2,'2020-12-09',47,74);
select * from employee3;
select day, id, sum(out_time - in_time) as difference
from employee3
group by id, day
order by day;

-- # leetcode 577
-- # Employee Bonus
-- # select all employee names whose bonus is <1000	
-- # toh yaha wo sab employees ka naam aayega jiska bonus 0 hai, i.e null
select * from employee;
create table bonus(emp_ID int, bonus int);
insert into bonus values(104, 2000);
select * from bonus;
-- # method 1
select employee.emp_NAME, bonus.bonus
from employee left join bonus
on employee.emp_ID = bonus.emp_ID
where bonus < 1000 or bonus is null;
-- # method 2
select employee.emp_NAME, bonus.bonus
from employee left join bonus
on employee.emp_ID = bonus.emp_ID
where coalesce(bonus, 0) < 1000;
-- # method 3,4
-- # these both methods are wrong
select employee.emp_NAME, employee.emp_ID, bonus.bonus
from employee left join bonus
on employee.emp_ID = bonus.emp_ID and coalesce(bonus,0) < 1000;	

select employee.emp_NAME, employee.emp_ID, bonus.bonus
from employee left join bonus
on employee.emp_ID = bonus.emp_ID and bonus < 1000;
-- # this is wrong because inme 24 rows aa rahe hai, kyuki 104 ko 2000 bonus mil raha hai, 0 nahi hai uska bonus, fir bhi usko null mein daldiya
-- # islie where aur join mein kya daalna hai uska dhyaan rakhna padta hai
-- # 'join where' mein kya ho raha hai ki join hone ke baad filter ho raha hai, toh wo 104 ko completely hata deta hai
-- # 'join and' mein kya ho raha hai ki join condition mein wo > 1000 walo ko null samajhke le raha hai result mein
-- # hence 'join and' is wrong here, 'join where' is correct

-- # leetcode 1821
-- # Find Customers With Positive Revenue this Year
select customer_id, year
from Customers
where year = '2021' and revenue > 0;

-- # leetcode 610
-- # Triangle Judgement
create table triangle(
x int, y int, z int);
insert into triangle values(10,20,15);
select * from triangle;
-- # method 1
select x, y, z, 
(case when (x + y > z) and (y + z > x) and (x + z > y) then 'yes' else 'no' end) as triangle
from triangle;
-- # method 2
select x, y, z,
if((x + y > z) and (y + z > x) and (x + z > y), 'yes','no') as triangle
from triangle;

-- # leetcode 1173
-- # Immediate Food Delivery I
create table delivery(
delivery_id int, customer_id int, order_date date, customer_pref_delivery_date date);
insert into delivery values(6,2,'2019-08-11', '2019-08-13');
select * from delivery;
-- # find the percentage of intermediate orders in the table, rounded to 2 decimal places.
-- # method 1 (my method)
with t1 as(
select row_number() over (order by delivery_id) as no_of_rows from delivery limit 1 offset 5),
t2 as(
select delivery_id, count(customer_id) as intermediate from delivery where order_date = customer_pref_delivery_date)
select round((t2.intermediate/t1.no_of_rows) * 100,2) from t2 join t1;
-- # method 2 (fredrick's method)
select round(sum(order_date = customer_pref_delivery_date) *100 / count(*), 2) as intermediate_percentage from delivery;
-- # method 3
select round(same_day/(select count(*) from delivery)*100,2) as immediate_percentage 
from(select count(*) as same_day from delivery where order_date= customer_pref_delivery_date) t;
-- # method 4
Select round(Sum(Order_type) *100/ count(*),2) as Immediate_percentage
from
(select case when customer_pref_delivery_date = order_date
then '1'
else '0' 
end as Order_Type
from delivery) as D;

-- # leetcode 1350
-- # students in departments that don't exist anymore
select * from employee2;
select * from department2;
insert into employee2 values(9, 'Sonny',9000,4);
-- # method 1
select employee2.id, employee2.name employee_name, department2.id as dept_id from
employee2 left join department2
on employee2.dept_id = department2.id
where department2.id is null;
-- # method 2 (doubt)
select employee2.name as employee_name from employee2 left join department2 on employee2.dept_id = department2.id
where employee_name not in(
select employee2.name as employee_name from
employee2 join department2
on employee2.dept_id = department2.id);

-- # leetcode 1633
-- # Percentage of Users registered in each contest rounded to 2 decimals
-- # display result as percentage in desc, and if there is a tie then contest_id in asc
select contest_id, round(count(user_id)* 100 /(select count(*) from Users),2) as percentage
from Register
group by contest_id
order by percentage desc, contest_id asc;

-- # leetcode 586
-- # Customer Placing the Largest Number of Orders
create table orders(
order_number int, customer_number int);
insert into orders values(4,3);
select * from orders;
-- # method 1
with t1 as(
select customer_number, (count(order_number)) as count
from Orders 
group by customer_number
order by count desc limit 1)
select customer_number from t1 ;
-- # method 2
select customer_number
from orders
group by customer_number
order by count(distinct(order_number)) desc
limit 1;





with unbannedclient as
    ( select users_id as Id
     from Users
     where banned = 'No' and role = 'client'),
unbanneddriver as
    (select users_id as Id
     from Users
     where banned = 'No' and role ='driver'),
unbannedtrips as 
    (select Trips.Status as Status, Trips.request_at as request_at, 
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
completeunbannedtrips as
    (select request_at, count as completetrips
    from unbannedtrips
    where Status!='completed')

select totalunbannedtrips.request_at as Day,
round(ifnull(completetrips,0)/ total_trips,2) as 'Cancellation Rate'
from totalunbannedtrips left join completeunbannedtrips
on totalunbannedtrips.request_at = completeunbannedtrips.request_at
where totalunbannedtrips.request_at >= cast('2013-10-01' as date)
and totalunbannedtrips.request_at <= cast('2013-10-03' as date);


