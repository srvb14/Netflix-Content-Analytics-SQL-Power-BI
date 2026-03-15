use netflix;
table netflix_data;

-- DATA CLEANING :
select 
count(*) - count(id) as missing_id ,
count(*) - count(title) as missing_title,
count(*) - count(type) as missing_type ,
count(*) - count(description) as missing_desc,
count(*) - count(release_year) as missing_release_year,
count(*) - count(age_certification) as missing_age_cert,
count(*) - count(runtime) as missing_runtime,
count(*) - count(imdb_id) as missing_imdb_id,
count(*) - count(imdb_score) as missing_imdb_score,
count(*) - count(imdb_votes) as missing_imdb_votes
from netflix_data;

# in description there are 5 missing values,
# in age_certification there are 2285 missing values,
# in imdb_votes there are 16 missing values.

select id, title , type,
count(*) from netflix_data
group by id, title , type
having count(*) >1;
# no duplicates found 

-- Fill the missing values
set sql_safe_updates = 0;
-- filling Description:
update netflix_data
set description = "Not Available"
where description is null;

-- filling Age certification:
update netflix_data
set age_certification = "Unrated"
where age_certification is null;

-- Filling IMDB votes:
update netflix_data 
set imdb_votes= 0
where imdb_votes is null;
----------------------------
# Content Mix Optimization |
----------------------------
## MARKET SHARE:
select type , 
concat(round(count(*)*100.0 /(select count(*) from netflix_data),2)," %") as type_share,
concat(round(sum(runtime)*100/ (select sum(runtime) from netflix_data),2)," %") as runtime_share,
concat(round(sum(imdb_score)*100/ (select sum(imdb_score) from netflix_data),2)," %") as imdb_score_share,
concat(round(sum(imdb_votes)*100/ (select sum(imdb_votes) from netflix_data),2)," %") as imdb_votes_share
from netflix_data
group by type;
-- Movie has dominate in all sectors till the last date of the dataset this shows netflix is primarily a movie library by volume 
-- even shows has 35% of the market share in terms of quantity they have 38% of imdb_score that shows 
-- 	per title shows are higher quality than movie ;
-- Movies has 73% of total votes that means movies are the real Hooks for people engaging the paltform.


## Quality and engagememnt metrics:
with cte as(
select id, type , imdb_score, imdb_votes , 
case when imdb_score >= 8.0 then 'Hits'
	when imdb_score >5.0 then 'Average'
    else 'Flop' end as Quality_flag
from netflix_data),

cte2 as (
select type,
count(*) as total_count,
round(avg(imdb_score),2) as avg_imdb_score,
round(avg(imdb_votes),2) as avg_imdb_votes,
sum(case when quality_flag = 'Hits' then 1 else 0 end) as total_hits,
sum(case when quality_flag = 'Average' then 1 else 0 end) as total_average,
sum(case when quality_flag = 'flop' then 1 else 0 end) as total_flop
from cte group by type)

select type, total_count, avg_imdb_score, avg_imdb_votes,

concat(round((total_hits*100.0/total_count),2),' %') as hits_pct,
concat(round((total_average*100.0/total_count),2),' %') as average_pct,
concat(round((total_flop*100.0/total_count),2), ' %') as flop_pct
from cte2;

/*
While Movies make up the majority of the library and drive 50% more engagement (votes) per title, they are 
a high-risk investment. Over 12% of Netflix movies are 'Flops'. Conversely, TV Shows are 
'Quality Engines' nearly 1 in 5 shows is a 'Hit,' and they maintain a significantly higher average quality. 
This suggests that while movies attract the audience, TV shows provide the prestige and satisfaction that 
likely reduces subscriber churn."
*/


## The "Evolution" Query (Time-Series)
table netflix_data;
with cte as(
select type,
case when release_year between 2000 and 2005 then "2000-2005"
	when release_year between 2006 and 2010 then "2006-2010"
	when release_year between 2011 and 2015 then "2010-2015"
    when release_year between 2016 and 2020 then "2016-2020"
    when release_year > 2000 then "After 2020" end as year_flag,
count(*) as total_count 
from netflix_data  where release_year >=2000
group by type, year_flag order by type, year_flag asc),

cte2 as (
select *, lag(total_count) over(partition by type order by year_flag asc) as prev_count
from cte)

select type, year_flag, 
round((total_count-prev_count)*100.0/prev_count,2) as growth
from cte2 order by type, year_flag;

/* both mobvies and shows are rapidly increasing in terms of number , actually shows are highly increasing
compare to movies and after 2020 for having lack of data (upto 2022) it shows decreasing , 

"While both formats are growing, the production of TV Shows exploded by nearly 400% in the late 2010s,
outpacing Movie growth by almost 100 percentage points. This indicates a strategic pivot: Netflix isn't
just a movie library anymore; it has transformed into a 'Destination for Series'. The decline after 2020 is
a 'Data Lag' artifact, as we only have partial data for the 2021-2022 period."*/


## Efficiency Ratio :
-- The Concept: If Netflix produces 1 minute of a Movie vs. 1 minute of a TV Show, which one generates more 
-- "Audience Buzz" (IMDb Votes)?

select
type , 
round(sum(case when release_year<2000 then imdb_votes else 0 end)/
	nullif(sum(case when release_year<2000 then runtime else 0 end),0),2) as vintage_vpm,
    
round(sum(case when release_year>=000 then imdb_votes else 0 end)/
	nullif(sum(case when release_year>=2000 then runtime else 0 end),0),2) as modern_vpm
from netflix_data
where runtime <>0
group by type;
/*When we look at Engagement Density (Votes per Minute), we see a massive efficiency gap. TV Shows generate
nearly 2x more engagement per minute of content compared to Movies (443 vs 236 for modern titles). Even more
striking is that vintage content (pre-2000) is significantly more 'dense' in engagement than modern originals.
This suggests that while Netflix is producing more content than ever, the return on engagement per minute
produced is actually declining.
As an analyst, I would recommend focusing on high-density serialized content to maximize the efficiency of the
production budget.
Business Impact Summary: If Netflix wants to increase user satisfaction and production efficiency,
they should prioritize high-quality TV Series over high-volume Movie production.*/



-----------------------------------------------
# Maturity Gap" & Audience Targeting Strategy |
-----------------------------------------------
## Market Segmentation (The Distribution)

with cte as(
select *,'G', 'PG', 'TV-Y', 'TV-Y7', 'TV-G', 'TV-PG'
case when age_certification in () then 'Kids/Family'
	when age_certification in('PG-13', 'TV-14') then 'Teens'
    when age_certification in ('R', 'NC-17', 'TV-MA') then 'Adults' 
    else 'Unrated/Others' end as target_segment
from netflix_data)

select target_segment,
count(*) as titles, 
sum(case when release_year<2000 then 1 else 0 end) as title_pre_2000, 
sum(case when release_year >=2000 then 1 else 0 end) as title_post_2000,
round(avg(imdb_score),2) as avg_quality,
round(avg(imdb_votes),2) as total_engagement
from cte group by target_segment;

/*
While Netflix is often seen as a broad platform, the data shows it is heavily skewed toward Adult content,
which accounts for the highest engagement. However, the Teens segment actually delivers the highest average
quality scores.*/

# Identifying the "Hidden Gems"
table netflix_data;
select title, type, imdb_score ,
imdb_votes
from netflix_data where 
imdb_score >=8.0 and 
imdb_votes < (select avg(imdb_votes) from netflix_data);

create view Hidden_gems as 
with segment_avg_votes as (
select 
case when age_certification in ('G', 'PG', 'TV-Y', 'TV-Y7', 'TV-G', 'TV-PG') then 'Kids/Family'
	when age_certification in('PG-13', 'TV-14') then 'Teens'
    when age_certification in ('R', 'NC-17', 'TV-MA') then 'Adults' 
    else 'Unrated/Others' end as target_segment,
avg(imdb_votes) as avg_votes_segment
from netflix_data group by target_segment),

clasified_titles as (
select title, type, 
imdb_score, imdb_votes,
case when age_certification in ('G', 'PG', 'TV-Y', 'TV-Y7', 'TV-G', 'TV-PG') then 'Kids/Family'
	when age_certification in('PG-13', 'TV-14') then 'Teens'
    when age_certification in ('R', 'NC-17', 'TV-MA') then 'Adults' 
    else 'Unrated/Others' end as t_segment
from netflix_data)

select ct.title, ct.type, ct.imdb_score, ct.imdb_votes, ct.t_segment 
from clasified_titles ct join segment_avg_votes sv 
	on ct.t_segment = sv.target_segment
where ct.imdb_score >= 8.0 and 
ct.imdb_votes < sv.avg_votes_segment
order by imdb_score desc;
select * from hidden_gems;

/*I identified 326 'Hidden Gems' across the library. These are titles with IMDb scores above 8.0 that are
currently sitting below their segment's average engagement level.
For example, in the Kids/Family segment—which we
previously identified as underserved—titles like '#ABtalks' and 'Who Rules The World' have near-perfect scores
but very less mainstream visibility.
By using data to identify these 'Gold Mines,' Netflix can optimize its recommendation engine to push these 
titles to more users, increasing satisfaction without spending a single dollar on new production.*/


## Business Impact:
select T_segment , count(*) as total_hidden_gems, round(avg(imdb_score),2) as avg_imdb_score
from hidden_gems
group by t_segment;
-- Netflix needs to improve the "discoverability" of its 58 Kids/Family hidden gems to better compete with Disney+.

-- The Teens segment has the best "Quality-to-Volume" ratio. Netflix should double down on TV-14 series as they
-- are high quality and high engagement.

-- Many hidden gems in the "Unrated" category are high-quality international titles. This proves that Netflix's
-- global content strategy is working, but these titles need better localization/marketing.

with decade_data as (
select *, 
case 
	when release_year <1970 then "before 1970"
	when release_year between 1970 and 1979 then "1970"
    when release_year between 1980 and 1989 then "1980"
    when release_year between 1990 and 1999 then "1990"
    when release_year between 2000 and 2009 then "2000"
	when release_year between 2010 and 2019 then "2010"
	when release_year > 2000 then "after 2000" end as decades
from netflix_data)
select type, decades, count(*) as title_count,
round(avg(imdb_score),2) as avg_imdb_score
from decade_data 
group by decades,type
order by type, decades;
-- In the 1970s, almost 1 in 3 movies on Netflix were 'Hits' (> 8.0%). As Netflix scaled its library in the
-- 2020s (adding 900+ movies), the 'Prestige Rate' crashed to just 2.4%.

-- While TV Shows have also seen a decline, they remain much more resilient. Even in the high-volume 2020s,
-- 10.5% of shows are still 'Hits'—nearly 5x better than the hit rate of modern movies.

/*
Based on my analysis of the Netflix data, I recommend a 3-pillar strategy for the upcoming fiscal year:
	a) Shift 15% of the Original Film budget into Episodic Series. The data shows 'Shows' have 5x the hit rate
    and 2x the engagement-per-minute of movies.
    
    b) Family Gap :Our current library is heavily adult-skewed, yet 'Teen' content shows the highest potential for 
    quality. We should move from 'Adult-First' to 'Family-Co-Viewing'.
    
    c) Instead of just producing new content, leverage the 326 Hidden Gems (high score, low votes).
    I identified Re-marketing these existing assets is a zero-cost way to increase subscriber satisfaction.
*/