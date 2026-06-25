use [SQL Case Studies]
select * from T20I

/* Q1 Identify matches played between two specific teams (ex. India vs South Africa) in 2024 
and their result.*/
select * from T20I
where ((Team1 = 'India' and Team2 = 'South Africa') or (Team1 = 'South Africa' and Team2 = 'India'))
and year(matchdate) = 2024

-- Q2 Find the team with the highest number of wins in 2024 and total matche it won.
select top 1 Winner,count(*) as totalwin from T20I
where YEAR(matchdate) = '2024'
group by Winner
order by totalwin desc

-- Q3 Rank the teams based on the total number of wins in 2024.
select Winner,count(*) as totalwin,
DENSE_RANK() over(order by count(*) desc) as rankedteam
from T20I
where YEAR(matchdate) = 2024 and winner not in('tied','no result')
group by Winner
order by totalwin desc;

 --Q4 Which team had the highest average winning margin(in runs), And what was the average margin?
 select top 1 Winner,avg(cast(left(margin,CHARINDEX(' ',Margin)) as int)) as avg_run from T20I
 where Margin like '%runs'
 group by Winner
 order by avg_run desc

 --Q5 List all matches where the winning margin was greater then the average margin across all matches.
 select * from T20I
 where margin like '%runs' and 
 cast(left(margin,CHARINDEX(' ',Margin)) as int)>
 (select avg(cast(left(margin,CHARINDEX(' ',Margin)) as int)) as avg_margin from T20I
 where margin like '%runs')

 -- Q6 Find the team with the most wins when chasing a target(win by wickets)
 
 select winner,total_win from
 (select winner,count(*) as total_win,
 RANK() over(order by count(*) desc) as ranked_win
 from T20I
 where Margin like '%wickets'
 group by Winner) as t
 where ranked_win = 1

 -- Q7 Head to head record between two selected teams (e.g. England vs Australia)
 declare @teamA varchar(25) = 'west indies'
 declare @teamB varchar(25) = 'Australia'
 
 select Winner,count(*) as matchwon from T20I
 where (team1 = @teamA and team2 = @teamB) or (team1 = @teamB and team2 = @teamA)
 group by Winner

 --Q8 Identify the month in 2024 with the highest number of t20i matches played.
 
 select top 1 monthplay,count(*) as total_match from
 (select *,datename(MONTH,MatchDate) as monthplay from T20I
 where DATEPART(year,matchdate)='2024') t
 group by monthplay
 order by total_match desc

--Q9 For each team, Find how many matches they played in 2024 and their win percentage?
with cte_matches as
(select team,count(*) as matches_played
from
(select team1 as team 
from T20I
union all
select team2 as team
from T20I) t
group by team)

,cte_won as(
     select Winner as team,count(*) as matches_won 
     from T20I
     group by Winner
	 )
select m.team,m.matches_played,isnull(w.matches_won,0) as matches_won ,
cast((isnull(w.matches_won,0)*100.00/m.matches_played) as decimal(10,2)) as win_percentage
from cte_matches m
left join cte_won w
on m.team = w.team
group by m.team,m.matches_played,w.matches_won
order by win_percentage desc

--Q10 Identify the most successful team at each ground(teams with most wins for ground)
with cte_groundwin as(
select winner,ground,winner_team,
RANK() over(partition by ground order by winner_team desc) as rn_win
from
(select winner,Ground,count(*) as winner_team 
from T20I
where Winner not in ('tied','no result')
group by winner,Ground) t
)
select Ground,Winner,winner_team from cte_groundwin
where rn_win = 1
order by Ground

select distinct(ground) from T20I
