create table weather
(
id int,
city varchar(50),
temperature int,
day date
);

insert into weather values
(1, 'London', -1, str_to_date('2021/01/01','%Y/%m/%d')),		
(2, 'London', -2, str_to_date('2021/1/2,'%Y/%m/%d')),
(3, 'London', 4, str_to_date('2021-01-03','%Y/%m/%d')),
(4, 'London', 1, str_to_date('2021-01-04','%Y/%m/%d')),
(5, 'London', -2, str_to_date('2021-01-05','%Y/%m/%d')),
(6, 'London', -5, str_to_date('2021-01-06','%Y/%m/%d')),
(7, 'London', -7, str_to_date('2021-01-07','%Y/%m/%d')),
(8, 'London', 5, str_to_date('2021-01-08','%Y/%m/%d'));

select * from weather;
