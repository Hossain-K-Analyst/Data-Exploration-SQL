 --Looking at the data

SELECT count(distinct([country]))
  FROM [dbo].[world_suiside_data]


  select avg([suicides/100k pop])
  from [dbo].[world_suiside_data]
  where year between 2004 and 2015

  --looking at total suiside 1985-2016 by country (map)

  SELECT distinct([country]),sum([suicides_no]) as total_suiside
	FROM [dbo].[world_suiside_data]
	where year between 2004 and 2015
	GROUP BY country
	ORDER BY 2 desc
	
 --Looking at highest suiside year around the world

  SELECT [year],sum([suicides_no]) as total_suiside 
	  FROM [dbo].[world_suiside_data]
	  where year between 2004 and 2015
	  GROUP BY year
	  ORDER BY 2 
  
  --Looking at highest global suiside rate over the 12 years 

 with global_suiside_rate as
 (SELECT distinct(year),sum([suicides_no]) as total_suicide
		,sum([suicides/100k pop]) as suicide_p_100k
		,sum(population) as global_popu
	  FROM [dbo].[world_suiside_data]
	  where year between 2004 and 2015
	  group by year)
	  
	  SELECT year, (total_suicide/global_popu)*100000 as world_s_rate
		FROM global_suiside_rate
		Order by 2


 --  looking at gender difference of top 10 suicide commited over time 
 
 WITH Gernder_percentage as (
  SELECT  country,  male,  female, (male + female) as total_suicides 
  from	(SELECT [country], [sex] as gender, [suicides_no] 
			FROM [dbo].[world_suiside_data] 
			where  year between 2004 and 2015 
			) source_table pivot 
		( sum(suicides_no) for gender in ([male], [female]) ) as pivot_table
	) 
		select top 10  country,total_suicides,  male / total_suicides * 100 as male_percentage , female / total_suicides * 100 as male_percentage 
		from Gernder_percentage 
		order by  2 desc


-- Looking at age diffrences 
 
 WITH table_1 AS (
    SELECT
        year,
        suicides_no,
        (CASE
            WHEN [age] = '75+ years' THEN 'Elderly' 
            WHEN [age] = '55-74 years' THEN 'Senior_Adult'
            WHEN [age] = '35-54 years' THEN 'Adult'
            WHEN [age] = '25-34 years' THEN 'Young_Adult'
            WHEN [age] = '15-24 years' THEN 'Youth'
            WHEN [age] = '5-14 years' THEN 'Child'
            ELSE 'Unknown'
        END) AS age_d
    FROM [dbo].[world_suiside_data]
    WHERE [year] BETWEEN 2004 AND 2015
),
year_totals AS (
    SELECT
        year,
        SUM(suicides_no) AS total_suicides
    FROM table_1
    GROUP BY year
)
 
SELECT
    t1.year,
    100.0 * SUM(CASE WHEN age_d = 'Child' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Child_percentage,
    100.0 * SUM(CASE WHEN age_d = 'Youth' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Youth_percentage,
    100.0 * SUM(CASE WHEN age_d = 'Young_Adult' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Young_Adult_percentage,
    100.0 * SUM(CASE WHEN age_d = 'Adult' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Adult_percentage,
    100.0 * SUM(CASE WHEN age_d = 'Senior_Adult' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Senior_Adult_percentage,
    100.0 * SUM(CASE WHEN age_d = 'Elderly' THEN suicides_no ELSE 0 END) / NULLIF(yt.total_suicides, 0) AS Elderly_percentage
FROM table_1 t1
JOIN year_totals yt ON t1.year = yt.year
GROUP BY t1.year, yt.total_suicides;
