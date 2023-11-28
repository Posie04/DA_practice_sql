--ex 1
select count (company_id) as duplicate_companies from 
(select company_id,
count(company_id)
from job_listings
group by company_id
having count(company_id) > 1) as new_table

--ex 2: ko giải được
select product,
sum(spend) as total_spend 
FROM product_spend
where (transaction_date between '01/01/2022' and '12/30/2022') and (
category = 'appliance')
group by product
having sum(spend) DESC

select product,
sum(spend) as total_spend 
FROM product_spend
where (transaction_date between '01/01/2022' and '12/30/2022') and (
category = 'electronics')
group by product
having sum(spend) DESC

-- ex 3
SELECT count(policy_holder_id) FROM
(select policy_holder_id,
count(call_category)
from callers
where call_category is not NULL
group by policy_holder_id
having count(call_category) > 2) as new

--ex 4
select page_id FROM
( select pages.page_id,
count(pages.page_id) as time
from pages
full join page_likes
on pages.page_id = page_likes.page_id
where page_likes.page_id is NULL
group by pages.page_id ) as new

--ex 5
with June AS
(
select user_id, 
extract (month from event_date) as previous,
count(event_type)
from user_actions
where event_date between '06/01/2022' and '06/30/2022'
group by user_id, extract (month from event_date)
having count(event_type) > 0),
July AS
(
select user_id, 
extract (month from event_date) as current,
count(event_type)
from user_actions
where event_date between '07/01/2022' and '07/31/2022'
group by user_id, extract (month from event_date)
having count(event_type) > 0)

select July.current as month,
count( distinct June.user_id) as monthly_active_users
from June
inner join July
on June.user_id=July.user_id
group by July.current

--ex 6: ko dùng được to_char????/ lúc chạy bị lỗi 1 lỗi :<
with trans AS 
(
select country, trans_date,
Date_format(trans_date, '%Y-%m'),
count(id) as trans_count, 
sum(amount) as trans_total_amount
from transactions
group by country,Date_format(trans_date, '%Y-%m')),

approved AS
(
select country, trans_date,
Date_format(trans_date, '%Y-%m'),
count(id) as approved_count,  
sum(amount) as approved_total_amount
from transactions
where state = 'approved'
group by country,Date_format(trans_date, '%Y-%m'))

select
Date_format(trans.trans_date, '%Y-%m') as month,
trans.country,
trans.trans_count,  
approved.approved_count, 
trans.trans_total_amount,
approved.approved_total_amount
from approved
join trans
on approved.country=trans.coulỗi
with table1 as
(select a.user_id,
a.num_movie,
b.name
from (select user_id,
count(movie_id) as num_movie
from MovieRating
group by user_id) as a
join Users as b
on a.user_id = b.user_id
having a.num_movie=max(a.num_movie)),

table2 as 
(select a.title, max(b.ave), a.movie_id from
(select movie_id,
avg(rating) as ave
from MovieRating
where date(created_at) between "2020-02-01" and "2020-02-29"
group by movie_id) as b
join Movies as a
on b.movie_id=a.movie_id)

select name,title
from MovieRating as c
join table1 as a on a.user_id=c.user_id
join table2 as b on b.movie_id=c.movie_id

--ex12
with a as
(select requester_id as id from RequestAccepted
union all
select accepter_id as id from RequestAccepted)

select id, count(id) as num
from a
group by id
order by num desc
limit 1
