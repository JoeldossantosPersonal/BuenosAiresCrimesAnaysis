use PortfolioProject

-- Visualize Table
select distinct * 
from dbo.crimes_buenos_aires_2021_2016$

-- Data cleaning 
update dbo.crimes_buenos_aires_2021_2016$
set District = 'Nu�ez'
where District like 'Nuñez'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'V�lez Sarsfield'
where District like 'Vélez Sársfield'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'Constituci�n'
where District like 'Constitución'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'Agronom�a'
where District like 'Agronomía'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'San Crist�bal'
where District like 'San Cristóbal'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'San Nicol�s'
where District like 'San Nicolás'

update dbo.crimes_buenos_aires_2021_2016$
set District = 'Villa Pueyrred�n'
where District like 'Villa Pueyrredón'

--List of Districts & categorized  by district
select distinct district
from dbo.crimes_buenos_aires_2021_2016$
order by District asc

-- Types of crime grouped by district
select distinct District, Category, count(category) as NumberOfCrimesPerCategory
from dbo.crimes_buenos_aires_2021_2016$
group by District, Category 
order by District asc

-- Total crimes grouped by district
select district, sum(crime_count) AS total_crimes
from (
    select district,category, count(*) AS crime_count
    from dbo.crimes_buenos_aires_2021_2016$
    group by district, category
)subquery 
group by district;


--District with highest number of crimes (palermo)
-- Created a cte based on the query ^^^ and apply select from there
with CrimeCounts as (
	select district, sum(crime_count) AS total_crimes
from (
    select district, category, count(*) AS crime_count
    from dbo.crimes_buenos_aires_2021_2016$
    group by district, category
)subquery 
group by district
)
select district, total_crimes
from (
    select district, total_crimes, rank() over (order by total_crimes desc) as crime_rank
    from CrimeCounts
	) ranked_crimes
where crime_rank = 1;

--Palermo's stats
select distinct District, Category, count(category) as NumberOfCrimesPerCategory
from dbo.crimes_buenos_aires_2021_2016$
where District like 'Palermo'
group by District, Category 
order by District asc

-- Homicide rate [%] in hotest zone
-- Homicide / total number of crimes 
with CrimeCounts AS (
    select
        district,
        SUM(case when category = 'homicide' then crime_count else 0 end) as homicide_count,
        SUM(crime_count) as total_crimes
    from (
        select district, category, COUNT(*) AS crime_count
        from dbo.crimes_buenos_aires_2021_2016$
        group by district, category
    ) subquery
    group by district
)
select
    district,
    total_crimes,
    homicide_count,
    concat(round((CAST(homicide_count as decimal) / total_crimes) * 100,2),'%') as homicide_rate
from (
    select
        district,
        total_crimes,
        homicide_count,
        RANK() over (order by total_crimes desc) as crime_rank
    from CrimeCounts
) ranked_crimes
where crime_rank = 1;


-- Probability of being violently assaulted if being robbed [%]
with CrimeCounts as (
    select
        district,
        SUM(CASE WHEN category = 'theft (violent)' then crime_count else 0 end) as violent_theft_count,
        SUM(crime_count) AS total_crimes
    from (
        select district, category, COUNT(*) as crime_count
        from dbo.crimes_buenos_aires_2021_2016$
		group by district, category
    ) subquery
    group by district
)
select
    district,
    total_crimes,
    violent_theft_count,
    concat(round((CAST(violent_theft_count as decimal) / total_crimes) * 100,2),'%') as probability_violent_theft
from (
	select
        district,
        total_crimes,
        violent_theft_count,
        RANK() over (order by total_crimes desc) as crime_rank
    from CrimeCounts
) ranked_crimes
where crime_rank = 1;


-- Amount of homicide after 19:00pm to 4:00am vs 5:00am to 18pm
select
    district,
    SUM(case when [Time Zone] >= 19 OR [Time Zone] <= 4 then crime_count else 0 end) as total_crimes_19_to_4,
    SUM(case when [Time Zone] >= 5 AND [Time Zone] <= 18 then crime_count else 0 end) as total_crimes_5_to_18
from (
    select district, category, [Time Zone], COUNT(*) as crime_count
    from dbo.crimes_buenos_aires_2021_2016$
    group by district, category, [Time Zone]
) subquery
group by district;

-- see if there's correlation between categories and time zone

--Latitude and longitude by district
select District, Latitude, Longitude
from dbo.crimes_buenos_aires_2021_2016$