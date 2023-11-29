--ex 1
select count (company_id) as duplicate_companies from 
(select company_id,
count(company_id)
from job_listings
group by company_id
having count(company_id) > 1) as new_table

--ex 2: 
with a AS
(
select product, category,
sum(spend) as total_spend 
FROM product_spend
where (transaction_date between '01/01/2022' and '12/30/2022') and (
category = 'appliance')
group by product, category
ORDER BY sum(spend) DESC limit 2),
b as 
(
select product, category,
sum(spend) as total_spend 
FROM product_spend
where (transaction_date between '01/01/2022' and '12/30/2022') and (
category = 'electronics')
group by product, category
order by sum(spend) DESC limit 2 )

select category, product, total_spend from a
UNION ALL
select category, product, total_spend from b

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

--ex 6:
SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') AS month
    , country
    , COUNT(*) AS trans_count
    , SUM(IF(state = 'approved', 1, 0)) AS approved_count
    , SUM(amount) AS trans_total_amount
    , SUM(IF(state = 'approved', amount, 0)) AS approved_total_amount
FROM Transactions
GROUP BY month, country

--ex7
select product_id, min(year) as first_year,
quantity, price from sales
group by product_id
  
--ex8
select customer_id from
(
select customer_id,
count(customer_id)
from customer
group by customer_id
having count(customer_id) = (select count(product_key) from product)) as new

--ex9
select s.employee_id
from (select * from employees
where salary < 30000) as s
join employees as b
on s.employee_id = b.manager_id 

--ex10
select count (company_id) as duplicate_companies from 
(select company_id,
count(company_id)
from job_listings
group by company_id
having count(company_id) > 1) as new_table

--ex 11
with table1 as
(select a. num_movie, 
b.name as results
from (select user_id,
count(movie_id) as num_movie
from MovieRating
group by user_id) as a
join Users as b
on a.user_id = b.user_id
having a.num_movie=max(a.num_movie) ),

table2 as 
(select a.title as results, b.ave, a.movie_id from
(select movie_id,
avg(rating) as ave
from MovieRating
where date(created_at) between "2020-02-01" and "2020-02-29"
group by movie_id) as b
join Movies as a
on b.movie_id=a.movie_id
order by b.ave DESC limit 1)

select results from table1
union all
select results from table2
  
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
