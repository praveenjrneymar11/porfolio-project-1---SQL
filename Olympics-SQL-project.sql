create table if not exists OLYMPICS_HISTORY
(id INT,
 name VARCHAR,
 sex VARCHAR,
 age VARCHAR,
 height VARCHAR,
 weight VARCHAR,
 team VARCHAR,
 noc VARCHAR,
 games VARCHAR,
 year INT,
 season VARCHAR,
 city VARCHAR,
 sport VARCHAR,
 event VARCHAR,
 medal VARCHAR
)


create table if not exists OLYMPICS_HISTORY_NOC_REGIONS
(noc VARCHAR,
 region VARCHAR,
 notes VARCHAR
)

select * from OLYMPICS_HISTORY
select * from OLYMPICS_HISTORY_NOC_REGIONS

--identify the sport which was played in all summer olympics
--1.find total no of summer olympics games
--2.find for each sport how manny games where they played
--3. compare 1 & 2

with t1 as
	(select count(distinct games) as total_distinct_games
	 from OLYMPICS_HISTORY
	where season = 'Summer')
	
t2 as
	(select distinct sport, games
	from OLYMPICS_HISTORY
	where season = 'Summer' order by games)
t3 as
	(select sport, count(games)) as no_of_games
	from t2
	group by sport

-- (Q2). To fetch the top 5 athletes who won most gold medals
-- steps
--1.filter athletes with gold medal
--2.group the filtered athletes by name
--3.use Dense_rank to rank the athles
with t1 as
	(select name, count(medal) as gold_medal
	from OLYMPICS_HISTORY
	where medal = 'Gold'
	group by name
	order by gold_medal desc),

t2 as 
	(select *, dense_rank() over(order by gold_medal desc) as rank
	from t1)

select * from t2
where rank <= 5

--(Q3). List down the total gold, silver, bronze won by each country
--steps
--1.filter the medal section by removing null values
--2.join table (OLYMPICS_HISTORY) and (OLYMPICS_HISTORY_NOC_REGIONS) on column 'noc' to get the name of country
--3.aggregate the gold, silver, bronze medals by using grouping name
--4.use the cross tab function to modify the rows into columns
--5.Order the misplaced values accordingly

select NR.region as country, medal, count(medal) as total_medals 
from OLYMPICS_HISTORY OH
join OLYMPICS_HISTORY_NOC_REGIONS NR on OH.noc = NR.noc
where medal <>'NA'
group by NR.region, medal
order by NR.region 

create extension tablefunc

select country
,coalesce (gold, 0) as gold
,coalesce (silver, 0) as silver
,coalesce (bronze, 0) as bronze
from crosstab('select NR.region as country, medal, count(medal) as total_medals 
			from OLYMPICS_HISTORY OH
			join OLYMPICS_HISTORY_NOC_REGIONS NR on OH.noc = NR.noc
			where medal <>''NA''
			group by NR.region, medal
			order by NR.region',
			'values(''Bronze''),(''Gold''),(''Silver'')')
			as result(country VARCHAR, bronze BIGINT, gold BIGINT, silver BIGINT)
			order by gold desc, silver desc, bronze desc

--(Q4). Identify which country won the most gold, most silver, most bronze medals in each olympic games
--steps
--1.using the above table ,we try to get gold, silver, bronze upon each olympic games not by country

select NR.region as country, medal, count(medal) as total_medals 
from OLYMPICS_HISTORY OH
join OLYMPICS_HISTORY_NOC_REGIONS NR on OH.noc = NR.noc
where medal <>'NA'
group by NR.region, medal
order by NR.region 

create extension tablefunc

with t1 as
	(select substring(games_country, 1, position(' - ' in games_country) -1) as games
	,substring(games_country, position(' - ' in games_country) +3) as country
	,coalesce (gold, 0) as gold
	,coalesce (silver, 0) as silver
	,coalesce (bronze, 0) as bronze
	from crosstab('select concat(games, '' - '', NR.region) as games_country, medal, count(medal) as total_medals 
				from OLYMPICS_HISTORY OH
				join OLYMPICS_HISTORY_NOC_REGIONS NR on OH.noc = NR.noc
				where medal <>''NA''
				group by games, NR.region, medal
				order by games, NR.region, medal',
				'values(''Bronze''),(''Gold''),(''Silver'')')
				as result(games_country VARCHAR, bronze BIGINT, gold BIGINT, silver BIGINT)
				order by games_country)
			
select distinct games
, concat(first_value(country) over(partition by games order by gold desc)
		 ,' - '
		 ,first_value(gold) over(partition by games order by gold desc)) as max_gold
, concat(first_value(country) over(partition by games order by silver desc)
		 ,' - '
		 ,first_value(silver) over(partition by games order by silver desc)) as max_silver
, concat(first_value(country) over(partition by games order by bronze desc)
		 ,' - '
		 ,first_value(bronze) over(partition by games order by bronze desc)) as max_bronze
from t1
order by games
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			







