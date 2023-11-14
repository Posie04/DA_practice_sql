--ex 1
select a.CONTINENT, FLOOR(AVG(b.POPULATION))
from COUNTRY as a
inner join CITY as b
on a.CODE= b.COUNTRYCODE
GROUP BY a.CONTINENT
ORDER BY CEILING(AVG(b.POPULATION)) ASC

--ex 2
select 
round(cast 
  (count (b.email_id) as decimal)
    /count( distinct a.email_id)
    ,2) as active_ratio
from emails as a
left join texts as b
on a.email_id = b.email_id and signup_action = 'Confirmed';

--ex 3
SELECT b.age_bucket, 
round(100*sum(case when a.activity_type ='send' then a.time_spent else 0 end)/sum(case when a.activity_type in ('send','open') then a.time_spent else 0 end),2
) as send_perc,
round(100*sum(case when a.activity_type ='open' then a.time_spent else 0 end)/sum(case when a.activity_type in ('send','open') then a.time_spent else 0 end),2
) as open_perc
FROM activities as a
inner join age_breakdown as b
on a.user_id=b.user_id
where a.activity_type in ('send','open')
group by b.age_bucket

--ex 4
SELECT a.customer_id
FROM customer_contracts as a
inner join products as b
on a.product_id=b.product_id
group by a.customer_id
having count(distinct b. product_category)=3

--ex 5
select emp.employee_id,
emp.name,
count(man.reports_to) as reports_count, 
ceiling(avg(man.age)) as average_age
from Employees as emp
join Employees as man
on emp.employee_id=man.reports_to

--ex 6
select a.product_name,
sum(unit) as unit
from Products as a
join Orders as b
on a.product_id=b.product_id
where (order_date between '2020-02-01' and '2020-02-29')
group by a.product_name
having sum(unit) >=100

--ex 7
SELECT a.page_id
FROM pages as a
full join page_likes as b
on a.page_id = b.page_id
where b.liked_date is NULL
order by a.page_id ASC

