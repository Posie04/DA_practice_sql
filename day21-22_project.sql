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

---- Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng  (Từ 1/2019-4/2022)

