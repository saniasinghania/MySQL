use classicmodels;

select * from products;
select * from orderdetails;

-- # price of each product < 100 dollars
-- # yaha price orderdetails table mein hai par products ke naam products table mein hai 
select productCode, productName from products where productCode in (select productCode from orderdetails where priceeach< 100);


