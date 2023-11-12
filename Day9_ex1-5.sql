--ex 1
SELECT
count
  (case WHEN device_type='laptop' then 'laptop_reviews' end) 
  as laptop_reviews,
count 
  (case when device_type='tablet' or device_type='phone' then 'mobile_reviews' end) 
  as mobile_reviews
FROM viewership;

--ex2
select *,
case
when x+y>z and x+z>y and y+z>x then 'Yes'
else 'No'
end as triangle
from Triangle;

--ex3 ( web ko hề có data để chạy - web lỗi ??)
SELECT 
  (COUNT(case 
    when call_category ='n/a' or call_category is null then 'uncategorised call' end)/
  (count(call_category)))*100
FROM callers

--ex4: có cách nào loại bỏ thẳng null mà dùng case when hoặc coalesce không ạ?
select name from Customer
where not referee_id = 2 or referee_id is null;

--ex5
SELECT survived,
sum(case when pclass = 1 then 1 else 0 end) AS first_class,
sum(case when pclass = 2 then 1 else 0 end) AS second_class,
sum(case when pclass = 3 then 1 else 0 end) AS third_class
FROM titanic
GROUP BY survived


