-- # views
use classicmodels;
select * from customers;

create view cust_details
as
select customerName, phone, city
from customers;

select * from cust_details;

select * from productlines;
select * from products;

create view product_description
as
select productName, quantityinstock, msrp, textdescription
from products as p inner join productlines as pl
on p.productline = pl.productline;

select * from product_description;

-- # rename description
rename table product_description to vehicle_description; -- # even though it is a view, we have to type table only because ideally it is a virtual table

-- # display what all views we have views
show full tables where table_type = 'VIEW';

-- #to delete a view
-- # drop view cust_details;

-- # real lecture starts from here

-- # VIEWS
use youtube;
create table tb_customer_data(
cust_id varchar(10) primary key,
cust_name varchar(50),
phone bigint,
email varchar(50),
address varchar(250));
select * from tb_customer_data;

insert into tb_customer_data values('C3','Priyanka Verma', 9938675893,'priyanka@demo.com','Chennai');

create table tb_product_info(
prod_id varchar(10) primary key,
prod_name varchar(50),
brand varchar(50),
price int);

insert into tb_product_info values('P6','Macbook Pro','Apple', 5000);

select * from tb_product_info;

create table tb_order_details(
ord_id bigint primary key,
prod_id varchar(10),
quantity int,
cust_id varchar(10),
disc_id int,
date date);

insert into tb_order_details values(8,'P3',1,'C2',0,'2020-02-01');

select * from tb_order_details;
alter table tb_order_details rename column disc_id to disc_percent;
select * from tb_product_info;
select * from tb_customer_data;

create view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name,
(p.price * o.quantity - ((p.price * o.quantity) * disc_percent/100)) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

select * from order_summary;

-- # rules of views:

-- # 1) view only stores the structure not the data
-- # purpose and advantages:
-- # the purpose of using a view is to allow some external client/user to see the table without getting access of the whole database
-- # we can create a new dummy user for him and give access to that person only for this particular view and he will be able to see it
-- # this is done to protect confidencial company data and is very very useful in such cases

-- # views are also very very useful to simplify very long queries: if you have 100 line query and manager wants to do end changes to it,
-- # we can simply put the whole query in a view and then the manager can make changes to it like using a table

-- # create role james
-- # login
-- # password 'james'

-- # grant select on order_summary to james;

-- # using create or replace view 

-- # agar mai wapis yahi query likhti hu to mujhe error milta hai ki order_summar already exists
create view order_summary
as
select o.ord_id, o.date as date, p.prod_name, c.cust_name,
(p.price * o.quantity - ((p.price * o.quantity) * disc_percent/100)) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

-- # islie ham replace agar use karte hai toh:
-- # 1) agar already exist karta hai toh kuch nahi bas isise replace kardega
-- # 2) exist agar nahi karta hai toh new table bana dega

create or replace view order_summary
as
select o.ord_id, o.date, p.prod_name, c.cust_name,
(p.price * o.quantity - ((p.price * o.quantity) * disc_percent/100)) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;

-- # no errors

-- # rules or using create or replace view:
-- # 1) we cannot change the order of the columns that were made when the view was initially made, hence we cannot add a column in between columns
-- # but we can add a column at the end of the view columns
-- # 2) we cannot change the column data type (using ::abcd eg: ::varchar will change the datatype to varchar)
-- # 3) we cannot change the column names of already existing columns 

-- # 1) example:
create or replace view order_summary
as
select o.ord_id, o.date as order_date, p.prod_name, c.cust_name, c.cust_id,
(p.price * o.quantity - ((p.price * o.quantity) * disc_percent/100)) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id;
-- # error because i changed o.date to o.order_date in line 130
select * from order_summary;
-- # 2) example

create or replace view expensive_products
as 
select * from tb_product_info where price >1000;

select * from expensive_products;
select * from tb_product_info;

alter table tb_product_info add column prod_config varchar(100);

select * from expensive_products;

-- # jab ye run karte hai toh pata chalta hai ki prod_config wo view mein nahi show hua
-- # this is because even though view picks up values from the table passed in the select query, it does not remember data,
-- # it only remembers the structure of the data. Hence expensive_products will not be updated even if tb_product_info is altered.
-- # if we want to see the updated structure of the table in view, we need to run the 'create or replace view' query again.
-- # but this is not the case when we add a row of data, data will be updated in view without running the 'create or replace view' query.

-- #alter table tb_product_info drop column prod_config; -- # ececuted later on

-- # now there is one catch to this:
-- # even though view cannot update your structure (columns and everything), it can update your new data that you add.

-- # run this chronologically without running anything else:
insert into tb_product_info values('P10','TEST','TEST','1200');

select * from tb_product_info;
select * from expensive_products;

-- # you will see that the table is very much updated with the new data without running create or replace view wala query at all

-- # UPDATABLE VIEWS
-- # Update /insert / delete table details with views 
-- # Rules:
-- # 1) Views should be created with 1 table only/1 view only: agar joins use karke view banaya hai toh wo update nahi ho payega'
-- # 2) Query cannot have distinct clause
-- # 3) Query cannot have group by clause
-- # 4) Query cannot have with clause
-- # 5) Query cannot have windows functions

-- # 1) example:
update expensive_products
set prod_name = 'Airpods Pro', brand = 'Apple'
where prod_id = 'P10';

select * from expensive_products;
select * from tb_product_info;
-- # if you see now, i did not even do anything to tb_product_info but uske details update hogaye because I added them to the view.alter
-- # so this works vice versa

-- # par is view mein ab sirf ek hi table tha, hamne joins use nahi kiya tha
-- # lets try this with order_summary view jisme hamne joins use karke view banaya hai

select * from order_summary;
update order_summary
set cust_name  = 'Sania' where ord_id = 1;

-- # doubt on the result

-- # 2) example:

create or replace view expensive_products
as 
select distinct * from tb_product_info where price >1000;

select * from expensive_products;

update expensive_products
set prod_name = 'Airpods Pro 2', brand = 'Apple'
where prod_id = 'P10';

-- # throws me an error

-- # 3) example:

create view order_count
as
select date, count(1) as no_of_order
from tb_order_details
group by date;

select * from order_count;

update order_count
set no_of_order = 0 where date = '2020-01-01';

-- # again it throws me an error.

-- # WITH CHECK OPTION (to update tables through views)

create view apple_products
as
select * from tb_product_info where brand ='Apple';

select * from apple_products;

insert into apple_products
values('P25','Iphone 10','Apple',700);

select * from apple_products;
select * from tb_product_info;

insert into apple_products
values('P20','Note 20','Samsung',2500);

select * from apple_products;
select * from tb_product_info;

create or replace view apple_products
as
select * from tb_product_info where brand ='Apple'
with check option;

insert into apple_products
values('P22','Note 22','Samsung',2700);

-- # throws me an error













