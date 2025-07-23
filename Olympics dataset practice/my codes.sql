select * from olympics_history;

# question 1
# How many olympics games have been held?
select count(distinct games) as total_olympic_games 
from olympics_history;

# question 2
# List down all Olympics games held so far.
select distinct games from olympics_history;

select distinct oh.year,oh.season,oh.city
from olympics_history oh
order by year;

# question 3
# Mention the total no of nations who participated in each olympics game?
select distinct games from olympics_history;

  with all_countries as
        (select games, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by games, nr.region)
    select games, count(1) as total_countries
    from all_countries
    group by games
    order by games;
    
# question 4
# Which year saw the highest and lowest no of countries participating in olympics?
 with all_countries as
              (select games, nr.region
              from olympics_history oh
              join olympics_history_noc_regions nr ON nr.noc=oh.noc
              group by games, nr.region),
          tot_countries as
              (select games, count(1) as total_countries
              from all_countries
              group by games)
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from tot_countries
      order by 1;
      
select * from olympics_history;
# question 6
# Identify the sport which was played in all summer olympics.
# 1) total number of summer games
# 2) distinct sports played in each summer game (not repeated)
# 3) compare 1 and 2

with t1 as 
	(select sport, games
    from olympics_history 
    where season = 'Summer') ;
# ab isne saare sports ka result dikha diya hai, kayi sports mein bohot saare players hote hai, toh yaha repeated sports bohot hai
# hamein sirf distinct sports chahiye

with t1 as
	(select count(distinct games) as total_summer_games
    from olympics_history
    where season = 'Summer'),
t2 as
	(select distinct sport, games
    from olympics_history
    where season = 'Summer' order by games),
t3 as
	(select sport, count(games) as no_of_games
    from t2 
    group by sport)
select *
from t3
join t1 on t1.total_summer_games = t3.no_of_games;
	
# question 7
# Which Sports were just played only once in the olympics.
# we need total number of distinct olympic games
# we need the distinct sports played in all the olympic games
# compare 1 and 2 where sport has been played only once

with t1 as
	(select count(distinct games) as total_sumwin_olympics
    from olympics_history
    where season like 'Summer' or 
    season like 'Winter'),
t2 as
	(select distinct sport, games 
    from olympics_history
    where season like 'Summer' or 
    season like 'Winter' order by games),
t3 as
	(select sport, games, count(games) as no_of_games
    from t2 
    group by sport)
select * 
from t3 where no_of_games = 1 order by sport;

# question 8
# Fetch the total no of sports played in each olympic games.
 # 1) each unique olympic game should be fetched out
 # 2) count the total number of games played in each olympic
 
 with t1 as
	(select distinct games
    from olympics_history
    where season like 'Summer' or season like 'Winter'),
t2 as
	(select distinct games, sport
    from olympics_history
    where season like 'Summer' or season like 'Winter' order by games),
t3 as
	(select count(distinct sport) as no_of_sports, games 
    from t2 group by games order by no_of_sports desc)
select *
from t3;

# question 9
# Fetch oldest athletes to win a gold medal
# oldest athlete matlab hamko ulte order mein age chahiye
# should also win gold medal toh usse ham filter kardenge
# we have to print all columns of these athletes

DELETE FROM olympics_history WHERE age = 'NA';
select * from olympics_history;
with t1 as
	(select *, row_number() over (order by age desc) as rn
    from olympics_history where medal = 'Gold' order by rn asc),
t2 as 
	(select *
    from t1
    where rn = 1)
select * from t2;

with temp as
            (select name,sex, ifnull(age, 0) as age
              ,team,games,city,sport, event, medal
            from olympics_history),
	ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;
    
with temp as
            (select name,sex, COALESCE(age) as age #coalesce returns the first non null value in a list
              ,team,games,city,sport, event, medal
            from olympics_history order by age desc),
	ranking as
            (select *, rank() over(order by age desc) as rnk
            from temp
            where medal='Gold')
    select *
    from ranking
    where rnk = 1;
    
# question 10
# Find the Ratio of male and female athletes participated in all olympic games.
# first count all male athletes (distinct) in all olympic games
# then count all women athletes
# divide them
select * from olympics_history;

with t1 as
	(select count(distinct name) as male_athletes
    from olympics_history where sex = 'M'),
t2 as
	(select count(distinct name) as female_athletes
    from olympics_history where sex = 'F'),
t3 as(
	select *
    from t1
    natural join t2),
t4 as 
	(select (male_athletes/female_athletes) as ratio
    from t3)
select * from t4;

with t1 as
        	(select sex, count(1) as cnt
        	from olympics_history
        	group by sex),
        t2 as
        	(select *, row_number() over(order by cnt) as rn
        	 from t1),
        min_cnt as
        	(select cnt from t2	where rn = 1),
        max_cnt as
        	(select cnt from t2	where rn = 2)
    select concat('1 : ', round(max_cnt.cnt::decimal/min_cnt.cnt, 2)) as ratio
    from min_cnt, max_cnt;
    
# question 11
# Fetch the top 5 athletes who have won the most gold medals.
# filter by gold, order by athletes, top 5 nikalna hai
# also print the team 

with t1 as
	(select name, medal, team
    from olympics_history where medal = 'Gold' order by name asc),
t2 as 
	(select distinct name, count(medal) as total_medals, team
    from t1
    group by name order by total_medals desc)
select * from t2;

# question 12
# Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select * from olympics_history;

with t1 as
	(select name, medal, team
    from olympics_history 
    where medal = 'Silver' or 
    medal = 'Bronze' 
    or medal = 'Gold'  order by name asc),
t2 as 
	(select name, count(name) as no_of_medals, team
    from t1
    group by name order by no_of_medals desc),
t3 as
	(select * ,
    dense_rank() over (order by no_of_medals desc) as rnk
    from t2),
t4 as
	(select name, no_of_medals, team
    from t3 where rnk < 6)
select * from t4;

with t1 as
            (select name, team, count(1) as total_medals
            from olympics_history
            where medal in ('Gold', 'Silver', 'Bronze')
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk
            from t1)
    select name, team, total_medals
    from t2
    where rnk <= 5;
    
# question 13
# Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select * from olympics_history;

with t1 as
	(select team, medal
    from olympics_history where medal in  ('Gold', 'Silver', 'Bronze')),
t2 as
	(select team, count(medal) as medals
    from t1
    group by team order by medals desc),
t3 as
	(select *,
    rank() over (order by medals desc) as rnk
    from t2)
select * from t3 where rnk < 6;

# question 14
# List down total gold, silver and bronze medals won by each country.
## PIVOT

select * from olympics_history;
drop view GSBMedals;
create view GSBMedals
as
with t1 as
	(select team, medal
    from olympics_history
    where medal in  ('Gold', 'Silver', 'Bronze')),
t2 as
	(select team, medal, count(*) as Number_of_medals
    from t1
	group by medal, team
	having count(*) > 0)  # having is for the whole table but where clause is only for a single row hence yaha where use nahi kiya
select * from t2;

select * from GSBMedals;

select team, 
max(case when medal = "Gold" then Number_of_medals END) "Gold",
max(case when medal = "Silver" then Number_of_medals END) "Silver",
max(case when medal = "Bronze" then Number_of_medals END) "Bronze",
SUM(Number_of_medals) as Total_medals
from GSBMedals
group by team order by Gold desc, Silver desc, Bronze desc;

# question 15
# List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

create or replace view GBSMedals2 
as
with t1 as
	(select games, team, medal
	from olympics_history
	where medal in ('Gold','Silver','Bronze')),
t2 as 
	(select *, count(*) as medal_count
    from t1 group by team, games, medal)
select * from t2 order by medal_count desc;

select * from GBSMedals2;

#create view GBSMedals2_2
#as
select games, team, 
max(case when not isnull(medal = "Gold") then medal_count else 0 end) "Gold" , 
max(case when not isnull(medal = "Silver") then medal_count end) "Silver",
max(case when (medal = "Bronze") then medal_count end) "Bronze"
from GBSMedals2
group by games, team 
order by games;

select games, team, 
max(case when (not isnull(medal = "Gold")) then medal_count else 0  end) "Gold" , 
max(case when medal = "Silver" then medal_count end) "Silver",
max(case when medal = "Bronze" then medal_count end) "Bronze"
from GBSMedals2
group by games, team 
order by games;




