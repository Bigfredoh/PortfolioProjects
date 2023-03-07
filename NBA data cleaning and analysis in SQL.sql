-----------------Data Cleaning and Analysis in SQL-----------------

---------- Loading of PlayersProfile table and PlayersStats--------------

SELECT *
FROM 
	NBA_db.dbo.PlayersProfile
SELECT *
FROM 
	NBA_db.dbo.PlayersStats

ALTER TABLE NBA_db.dbo.PlayersProfile
DROP COLUMN height_in_meters;

------ Creating 3 New Columns from player_info column-----------------------

SELECT
	PARSENAME(REPLACE(player_info, '|', '.'), 3) AS player_team,
    PARSENAME(REPLACE(player_info, '|', '.'), 2) AS jersey_number,
	PARSENAME(REPLACE(player_info, '|', '.'), 1) AS player_position
FROM 
	NBA_db.dbo.PlayersProfile;


ALTER TABLE 
	NBA_db.dbo.PlayersProfile
ADD player_team char(50),jersey_number char(50),player_position char(50);

UPDATE
	NBA_db.dbo.PlayersProfile
SET player_team=PARSENAME(REPLACE(player_info, '|', '.'), 3),
	jersey_number=PARSENAME(REPLACE(player_info, '|', '.'), 2),
	player_position=PARSENAME(REPLACE(player_info, '|', '.'), 1);

------Creating New Column from nba_draft column---------------------

SELECT
	PARSENAME(REPLACE(nba_draft, ' ', '.'), 4) AS year_drafted
FROM 
	NBA_db.dbo.PlayersProfile

ALTER TABLE 
	NBA_db.dbo.PlayersProfile
ADD year_drafted char(10)

UPDATE
	NBA_db.dbo.PlayersProfile
SET year_drafted = PARSENAME(REPLACE(nba_draft, ' ', '.'), 4)

-----------Standaize Date Format----------------------
SELECT 
	CONVERT(Date, player_birthdate)
FROM 
	NBA_db.dbo.PlayersProfile;

ALTER TABLE NBA_db.dbo.PlayersProfile
ADD player_DOB Date;

UPDATE 
	NBA_db.dbo.PlayersProfile
SET 
	player_DOB = CONVERT(date, player_birthdate);


----- Extracting Player Height in meter and Weight in Kg from player_height and player_weight columns respectively
SELECT 
	SUBSTRING(player_height,CHARINDEX('(',player_height)+1,4)
FROM 
	NBA_db.dbo.PlayersProfile

ALTER TABLE NBA_db.dbo.PlayersProfile
ADD height_in_meters char(20);

UPDATE 
	NBA_db.dbo.PlayersProfile
SET height_in_meters = SUBSTRING(player_height,CHARINDEX('(',player_height)+1,4)

SELECT player_weight,
	REPLACE(SUBSTRING(player_weight,CHARINDEX('(',player_weight)+1, 3),'k','')
FROM 
	NBA_db.dbo.PlayersProfile


ALTER TABLE NBA_db.dbo.PlayersProfile
ADD weight_in_kg char(10);

UPDATE 
	NBA_db.dbo.PlayersProfile
SET weight_in_kg = REPLACE(SUBSTRING(player_weight,CHARINDEX('(',player_weight)+1, 3),'k','')

SELECT *
FROM 
	NBA_db.dbo.PlayersProfile


-------- Replacing string and weird characters in different columns--------------

ALTER TABLE NBA_db.dbo.PlayersProfile
ADD player_years_of_experience char(10);
 
SELECT REPLACE(REPLACE(years_of_experience,'Years',''),'Year','') 
FROM NBA_db.dbo.PlayersProfile

UPDATE
	NBA_db.dbo.PlayersProfile
SET 
 player_years_of_experience= REPLACE(REPLACE(years_of_experience,'Years',''),'Year','')


----------Performing Analysis on the cleaned datasets----------------
-- Question 1- What is the average weight and height of NBA players?

SELECT	
	ROUND(AVG(CAST(weight_in_kg AS float)),2) AS avg_weight_in_kg, 
	ROUND(AVG(CAST(height_in_meters AS float)),2) AS avg_height_in_meters
FROM 
	NBA_db.dbo.PlayersProfile
WHERE  
	weight_in_kg <> '--' AND weight_in_kg IS NOT NULL;


-- Question 2- Top 15 Nationality that has dominated NBA over the years.----

SELECT TOP 15
	COUNT(player_nationality) AS nationality_count, player_nationality
FROM 
	NBA_db.dbo.PlayersProfile
WHERE 
	player_nationality IS NOT NULL
GROUP BY 
	player_nationality
ORDER BY 
	COUNT(player_nationality) DESC;


-- Question 3- Top 10 players with the most game played and mins played.----
SELECT TOP 10 
	ps.player_name, ps.points,pp.player_rebounds_per_game, min_played,ps.game_played,ROUND(ps.points/ps.game_played,2) AS avg_points_per_game,pp.player_position
FROM 
	NBA_db.dbo.PlayersStats ps
INNER JOIN 
	NBA_db.dbo.PlayersProfile as pp 
ON 
	pp.player_name = ps.player_name
ORDER BY 
	game_played DESC, min_played DESC

-- Question 4- what is players current age and 10 players that spent the most of their career in NBA.----

SELECT TOP 10 
	player_name,player_DOB, CONVERT(INT, DATEDIFF(YEAR,player_DOB, GETDATE())) AS player_age,
	(CASE WHEN player_years_of_experience = 'Rookie' THEN 0
		  WHEN player_years_of_experience IS NULL THEN 0
      ELSE CAST(player_years_of_experience AS INT)
 END) AS number_of_experience
FROM 
	NBA_db.dbo.PlayersProfile
ORDER BY 
	number_of_experience DESC

-- Question 5- Relationship between players position with respect to blocks,free throw percent, true shooting percent, three Point field goal percent

SELECT TOP 10
	ps.player_name, ps.blocks,CAST(pp.player_assists_per_game*ps.game_played AS float) AS total_assists, ps.game_played, CAST(ps.free_throw_percent AS float) AS free_throw_percent, ps.true_shooting_percent, ps.three_Point_field_goal_percent,pp.player_position
FROM 
	NBA_db.dbo.PlayersStats ps
JOIN
	NBA_db.dbo.PlayersProfile pp
ON 
	pp.player_name = ps.player_name
WHERE 
	pp.player_position IS NOT NULL
ORDER BY	
	total_assists desc
