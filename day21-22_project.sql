---------------------------Day 21
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

select tag,age,
count(tag) from output
group by tag,age

=> insight: nhiều người già sử dụng hơn người trẻ, lớn nhất là 70 tuổi và nhỏ nhất là 12 tuổi

---Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm)
with a as
(
select FORMAT_TIMESTAMP('%Y-%m', created_at) as time,
product_id, product_name,
product_retail_price as sales,
cost,
count(id)*(product_retail_price-cost) as profit
from bigquery-public-data.thelook_ecommerce.inventory_items
group by FORMAT_TIMESTAMP('%Y-%m', created_at),product_id,product_name, product_retail_price, cost
)
select * from (select *,
dense_rank() over(partition by time order by profit desc) as rank
from a 
where time between '2019-01' and '2020-04'
order by time)
where rank<=5

---Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
with a as 
(
select FORMAT_TIMESTAMP('%Y-%m-%d', created_at) as time,
product_category,
product_retail_price as sale,
from bigquery-public-data.thelook_ecommerce.inventory_items
)
select time,product_category,
sum(sale) as revenue from a
where time between '2022-04-15' and '2022-07-15' 
group by time,product_category
order by time 

---------------------------Day 22
---tạo metric trước khi dựng dashboard
/* Giả sử team của bạn đang cần dựng dashboard và có yêu cầu xử lý dữ liệu trước khi kết nối với BI tool. 
Sau khi bàn bạc, team của bạn quyết định các metric cần thiết cho dashboard 
và cần phải trích xuất dữ liệu từ database để ra được 1 dataset như mô tả 
Hãy sử dụng câu lệnh SQL để tạo ra 1 dataset như mong muốn và lưu dataset đó vào VIEW đặt tên là vw_ecommerce_analyst */

-- select * from bigquery-public-data.thelook_ecommerce.orders (month,year)

select FORMAT_TIMESTAMP('%Y-%m', created_at) as month,
extract (year from created_at) 
from bigquery-public-data.thelook_ecommerce.orders

-- select * from bigquery-public-data.thelook_ecommerce.products (product)

select category from bigquery-public-data.thelook_ecommerce.products

--TPV/TPO 
select FORMAT_TIMESTAMP('%Y-%m', created_at) as month,
sum (sale_price) as TPV,
count(order_id) as TPO
from bigquery-public-data.thelook_ecommerce.order_items
group by FORMAT_TIMESTAMP('%Y-%m', created_at)


--Total_cost
with a as
(
select a.id,b.product_id,a.cost,
b.created_at,b.sold_at
from bigquery-public-data.thelook_ecommerce.products as a
inner join bigquery-public-data.thelook_ecommerce.inventory_items as b
on a.id=b.product_id
where b.sold_at is null)
select month, tongchiphi from
( select 
FORMAT_TIMESTAMP('%Y-%m', created_at) as month, sum(cost) as tongchiphi from a
group by FORMAT_TIMESTAMP('%Y-%m', created_at)
)
order by month

----Revenue_growth
with a as
(
select month,TPV,
lead(month) over(order by month asc) as next_month,
lead(TPV) over(order by month asc) as next_TPV,
from (
select FORMAT_TIMESTAMP('%Y-%m', created_at) as month,
sum (sale_price) as TPV,
count(order_id) as TPO
from bigquery-public-data.thelook_ecommerce.order_items
group by FORMAT_TIMESTAMP('%Y-%m', created_at))
order by month
)
select round(((next_TPV-TPV)*100/TPV),2) as revenue_growth
from a

---Order_growth
with a as
(
select month,TPO,
lead(month) over(order by month asc) as next_month,
lead(TPO) over(order by month asc) as next_TPO,
from (
select FORMAT_TIMESTAMP('%Y-%m', created_at) as month,
sum (sale_price) as TPV,
count(order_id) as TPO
from bigquery-public-data.thelook_ecommerce.order_items
group by FORMAT_TIMESTAMP('%Y-%m', created_at))
order by month
)
select round(((next_TPO-TPO)*100/TPO),2) as order_growth
from a

---Total_profit,Profit_to_cost_ratio

with doanhthu as
(select FORMAT_TIMESTAMP('%Y-%m', created_at) as month,
sum (sale_price) as TPV,
count(order_id) as TPO
from bigquery-public-data.thelook_ecommerce.order_items
group by FORMAT_TIMESTAMP('%Y-%m', created_at)),
chiphi as
(
select month, tongchiphi from
  (select 
    FORMAT_TIMESTAMP('%Y-%m', created_at) as month, sum(cost) as tongchiphi from (
  select a.id,b.product_id,a.cost,
  b.created_at,b.sold_at
  from bigquery-public-data.thelook_ecommerce.products as a
  inner join bigquery-public-data.thelook_ecommerce.inventory_items as b
  on a.id=b.product_id
  where b.sold_at is null)
    group by FORMAT_TIMESTAMP('%Y-%m', created_at)
  )
order by month)

 select a.month, a.TPV,b.tongchiphi, 
 a.TPV-b.tongchiphi as loinhuan,
 round((a.TPV-b.tongchiphi)*100/b.tongchiphi,2) as profit_to_cost_ratio 
 from doanhthu as a
 join chiphi as b on a.month=b.month











