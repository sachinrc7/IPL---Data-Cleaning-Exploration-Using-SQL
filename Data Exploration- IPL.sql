/* DATA CLEANING*/

/* Changing the data type of date column as it contained some values in different format*/

Alter table matches
Modify column date date;

 
/*How many matches were played every year. Count the number of matches by year*/
SELECT COUNT(*) as count, season
FROM matches
GROUP BY season
ORDER BY season;

/* How many different teams played each year */
WITH t1 as (
SELECT DISTINCT team1, season
FROM matches)

SELECT count(team1), season
FROM t1
GROUP BY season
ORDER BY season;

/* Which is the team that won max number of tosses across all seasons*/

SELECT count(toss_winner), toss_winner
FROM matches
GROUP BY 2
ORDER BY 1 DESC
LIMIT 1;

/* Who has won the most number of matches across each season*/

SELECT t3.Highest,t2.winner,t2.season from
(Select MAX(cou) as Highest, season
FROM (SELECT winner, season,
COUNT(winner) as cou
FROM matches
GROUP BY 1,2) as t1
GROUP BY 2) as t3
JOIN
(SELECT winner, season,
COUNT(winner) as cou
FROM matches
GROUP BY 1,2) as t2
ON  t3.season=t2.season
WHERE t2.cou=t3.Highest
ORDER BY season;

/* Which team has won by max number of runs across each season*/

SELECT t2.MAX,t2.season,t1.winner
FROM
	(SELECT winner, season, win_by_runs
	FROM matches
	ORDER BY 2) AS t1
JOIN
	(SELECT season, Max(win_by_runs) as MAX
	FROM matches
	GROUP BY 1
	ORDER BY 2) AS t2
	ON t1.season=t2.season
WHERE t1.win_by_runs= t2.MAX;

/* Which team has won by max number of runs across all seasons*/

SELECT t2.MAX,t2.season,t1.winner
FROM
	(SELECT winner, season, win_by_runs
	FROM matches
	ORDER BY 2) AS t1
JOIN
	(SELECT season, Max(win_by_runs) as MAX
	FROM matches
	GROUP BY 1
	ORDER BY 2) AS t2
	ON t1.season=t2.season
WHERE t1.win_by_runs= t2.MAX
ORDER BY 1 Desc
LIMIT 1;

/* Which team has won by max number of wickets across each season*/

SELECT t2.MAX,t2.season,t1.winner
FROM
	(SELECT winner, season, win_by_wickets
	FROM matches
	ORDER BY 2) AS t1
JOIN
	(SELECT season, Max(win_by_wickets) as MAX
	FROM matches
	GROUP BY 1
	ORDER BY 2) AS t2
	ON t1.season=t2.season
WHERE t1.win_by_wickets= t2.MAX;

/* Who has got the highest number of man of match awards across all seasons*/

SELECT player_of_match, count(player_of_match)
FROM matches
GROUP BY 1
ORDER BY 2 DESC;

/* Who has got the highest number of man of match awards across each seasons*/

SELECT t3.season, t3.mm, t2.player_of_match
FROM
(SELECT season, Max(MOM) as mm
FROM
(SELECT season, player_of_match, count(player_of_match) as MOM
FROM matches
GROUP BY 1,2
ORDER BY 1,3) as t1
GROUP BY 1) as t3
JOIN
(SELECT season, player_of_match, count(player_of_match) as MOM
FROM matches
GROUP BY 1,2
ORDER BY 1,3) as t2
ON t3.season=t2.season
WHERE t2.MOM=t3.mm
ORDER BY 1;

/* How many teams chose to field in every month of IPL across every season */

SELECT count(t1.toss_decision), t1.season
FROM
(SELECT date, season, toss_decision
FROM matches
WHERE toss_decision='field') as t1
GROUP BY 2
ORDER BY 2;


/* Show the teams with highest and lowest win_by_runs across every season*/

-- windows function ( row_number, rank, dense_rank, lead and lag)

select m.*,
row_number() over(partition by season) as rn,
rank() over (partition by season order by win_by_runs desc) as rnk,
dense_rank() over (partition by season order by win_by_runs desc) as drnk
from matches as m;

/*Fetch the first 2 matches played in every season. result should contain season, city, date, team1 and team2 columns*/

Select * from
(select m.season, m.city, m.date, m.team1, m.team2,
row_number() over(partition by season order by id) as rn
from matches as m) as x
where x.rn<3;

/*Fetch the first 2 winners in each season who won by max number of runs*/

select * from
(
select winner, season, win_by_runs,
rank() over (partition by season order by win_by_runs desc) as rnk
from matches 
) as x
where x.rnk<3;
