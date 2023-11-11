--ex1
SELECT
Name
FROM STUDENTS
WHERE Marks > 75
ORDER BY RIGHT(Name,3), ID ASC 

--ex2
SELECT user_id,
Concat(UPPER(LEFT(name,1)),LOWER(RIGHT(name,LENGTH(name)-1))) AS name 
FROM Users
ORDER BY user_id

/* ex2: note:
có thể dùng substring - lấy chữ từ vị trí số .... đến hết */

SELECT user_id,
Concat(UPPER(LEFT(name,1)),LOWER(SUBSTRING(name,2))) AS name 
FROM Users
ORDER BY user_id

--ex3
SELECT 
manufacturer,
'$' || ROUND(SUM(total_sales)/1000000) || ' '||'million'
as total_drug_sales
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC, manufacturer ASC

--ex4
SELECT extract (month from submit_date) as month,  product_id,
ROUND(avg(stars),2) as avg_starstars
FROM reviews
group by extract (month from submit_date), product_id
order by extract (month from submit_date), product_id

--ex5
SELECT sender_id,
COUNT(message_id) as messages
FROM messages
WHERE extract(year from sent_date)=2022 and extract (month from sent_date) = 8
GROUP BY sender_id
order by COUNT(message_id) DESC
limit 2

--ex6
SELECT
tweet_id
FROM Tweets
Where Length(content) >15  

--ex7
SELECT activity_date as day,
count(distinct user_id) as active_users
FROM Activity
Group by activity_date
HAVING abs(datediff('2019-07-27',activity_date))<30 

--ex8
select 
COUNT(ID) AS number
from employees
where EXTRACT(YEAR FROM joining_date)= 2022 
and (EXTRACT(MONTH FROM joining_date) between 1 and 7)

--ex9
select 
position('a'in first_name) as position
from worker
where first_name ='Amitah'

--ex10
select
substring(title from (position('2' in title)) for 4)
from winemag_p2
where country = 'Macedonia'

--ex10 (bài chữa) 
select substring(title,length(winery)+2,4) /* winery- tên loại rượu +2 => vị trí bắt đầu năm => +4 để thêm 4 kí tự đủ năm*/
from winemag_p2
where country ='Macedonia'




