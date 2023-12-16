---Ad-hoc tasks
---- Thống kê tổng số lượng người mua và số lượng đơn hàng đã hoàn thành mỗi tháng ( Từ 1/2019-4/2022)
with a /*số người mua*/ as
(
  select 
  FORMAT_TIMESTAMP('%Y-%m', created_at) as time1, 
  count(distinct user_id) as numuser from bigquery-public-data.thelook_ecommerce.order_items
  group by FORMAT_TIMESTAMP('%Y-%m', created_at)

),
b /* số đơn hoàn thành*/ as 
(
  select FORMAT_TIMESTAMP('%Y-%m', created_at) as time2,
  count(order_id) as numdone from bigquery-public-data.thelook_ecommerce.order_items
  where status='Complete'
  group by FORMAT_TIMESTAMP('%Y-%m',created_at)
)

select
a.time1,
a.numuser as num_user, 
b.numdone as num_done,
from a
join b on a.time1=b.time2
where a.time1 between '2019-01' and '2022-04'
order by a.time1 

=> insight: số lượng người dùng tăng theo thời gian, số lượng đơn hàng hoàn thành cũng tăng dần. tuy nhiên tiến độ hoàn thành đơn rất chậm

---Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng ( Từ 1/2019-4/2022)
/* Output: month_year ( yyyy-mm), distinct_users, average_order_value
giá trị đơn hàng trung bình = tổng giá trị đơn hàng trong tháng/số lượng đơn hàng */

with a as
(
select FORMAT_TIMESTAMP('%Y-%m', created_at) as year_month, 
count(distinct user_id) as distinct_users, 
sum(sale_price)/count(order_id) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items
where (FORMAT_TIMESTAMP('%Y-%m', created_at)) between '2019-01' and '2022-04'
group by FORMAT_TIMESTAMP('%Y-%m', created_at)
)
select * from a
order by year_month asc

--- Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
/* Tìm các khách hàng có trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất)
Hint: Sử dụng UNION các KH tuổi trẻ nhất với các KH tuổi già nhất 
tìm các KH tuổi trẻ nhất và gán tag ‘youngest’  
tìm các KH tuổi già nhất và gán tag ‘oldest’ 
Insight là gì? (Trẻ nhất là bao nhiêu tuổi, số lượng bao nhiêu? Lớn nhất là bao nhiêu tuổi, số lượng bao nhiêu) 
Note: Lưu output vào temp table rồi đếm số lượng tương ứng 
*/
with a as
(
select first_name,last_name, gender, age,FORMAT_TIMESTAMP('%Y-%m',created_at),
case 
  when age=min(age) over(partition by gender) then 'youngest' 
  when age=max(age) over(partition by gender) then 'oldest' end as tag
from bigquery-public-data.thelook_ecommerce.users
where FORMAT_TIMESTAMP('%Y-%m',created_at) between '2019-01' and '2022-04'
),
output as
( 
select first_name,last_name, gender, age,tag,
count(tag) over(partition by gender,tag) from a
where tag is not null)

select tag,age,gender,
count(tag) from output
group by tag,age,gender

=> insight: nhiều người già sử dụng hơn người trẻ, lớn nhất là 70 tuổi và nhỏ nhất là 12 tuổi









