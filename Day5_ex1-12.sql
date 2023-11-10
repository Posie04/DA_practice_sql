--ex1
SELECT DISTINCT CITY
FROM STATION
WHERE ID % 2 = 0;

--ex2
SELECT COUNT(CITY) - COUNT(DISTINCT CITY) FROM STATION;

--ex3 ( ĐỂ DÀNH LÚC SAU LÀM)

--ex4
SELECT 
  ROUND(CAST
    (SUM(item_count*order_occurrences)
        /SUM(order_occurrences)
    AS DECIMAL)
  ,1) AS mean
FROM items_per_order;

--ex5
SELECT DISTINCT candidate_id FROM candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id
having COUNT(candidate_id)=3
order by candidate_id ASC

--ex ( bài chữa)
SELECT DISTINCT candidate_id FROM candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id
having COUNT(skill)=3
order by candidate_id ASC

--ex6
SELECT user_id,
Date(max(post_date))-Date(min(post_date)) as day_between
from posts
where Date(post_date) between '2021-01-01' and '2021-12-31'
group by user_id
having count(user_id)>=2

--ex6 ( bài chữa)
SELECT user_id,
Date(max(post_date))-Date(min(post_date)) as day_between
from posts
where post_date >= '2021-01-01' and post_date < '2022-01-01'
group by user_id
having count(user_id)>=2

--ex7
SELECT card_name,
max(issued_amount)-min(issued_amount) as disparity
FROM monthly_cards_issued
Group by card_name
order by disparity DESC 

--ex8
SELECT
manufacturer,
COUNT(drug) AS drug_count, 
SUM(cogs - total_sales) AS total_loss
FROM pharmacy_sales
WHERE cogs > total_sales
GROUP BY manufacturer
ORDER BY total_loss DESC;

--ex9
SELECT id, movie,description,rating
FROM Cinema
where not description = 'boring'
group by id
having id%2 <> 0
order by rating DESC 

--ex9 (bài chữa)
SELECT *
FROM Cinema
where description <> 'boring' and  id%2=1
order by rating DESC 

--ex10
SELECT 
teacher_id,
COUNT(DISTINCT subject_id) as cnt
FROM Teacher
group by teacher_id 

--ex11
select user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by followers_count ASC

--ex12
SELECT class
FROM Courses
group by class
having count(class)>=5



