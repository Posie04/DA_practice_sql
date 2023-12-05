--Hãy làm sạch dữ liệu theo hướng dẫn sau:
---Chuyển đổi kiểu dữ liệu phù hợp cho các trường ( sử dụng câu lệnh ALTER) 

alter table public.sales_dataset_rfm_prj
alter column priceeach type numeric using(trim(priceeach)::numeric)

alter table public.sales_dataset_rfm_prj
alter column ordernumber type numeric using(trim(ordernumber)::numeric),
alter column quantityordered type numeric using(trim(quantityordered)::numeric),
alter column orderlinenumber type numeric using(trim(orderlinenumber)::numeric),
alter column msrp type numeric using(trim(msrp)::numeric),
alter column sales type decimal(10,2), ---- có cách nào chuyển sang float không ạ
alter orderdate type TIMESTAMP USING orderdate::TIMESTAMP; /* sự khác biệt giữa timestamp with time zone: tự động chỉnh theo địa phương >< timestamp without time zone: không tự động chỉnh */
  
---Check NULL/BLANK (‘’)  ở các trường: ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE.

SELECT * FROM  public.sales_dataset_rfm_prj
WHERE ordernumber IS NULL 
---
select 
sum(case when ordernumber is null then 1
	else 0 end ) as order_null,
sum(case when quantityordered is null then 1
	else 0 end ) as quan_null,
sum(case when priceeach is null then 1
	else 0 end ) as price_null,
sum(case when orderlinenumber is null then 1
	else 0 end ) as orderline_null,
sum(case when sales is null then 1
	else 0 end ) as sales_null,
sum(case when orderdate is null then 1
	else 0 end ) as orderdate_null
from public.sales_dataset_rfm_prj
=> outcome: ko có null
  
---Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 

-- tạo cột CONTACTLASTNAME
  --b1: 
  alter table public.sales_dataset_rfm_prj
  add column contactfirstname VARCHAR(50)
  --b2:
  select * from sales_dataset_rfm_prj
  --b3: 
  update public.sales_dataset_rfm_prj
  set contactfirstname = (left(contactfullname, position('-' in contactfullname)-1))

-- tạo cột CONTACTFIRSTNAME
  --b1: 
  alter table public.sales_dataset_rfm_prj
  add column contactlastname VARCHAR(50)
  --b2:
  select * from sales_dataset_rfm_prj
  --b3: 
  update public.sales_dataset_rfm_prj
  set contactlastname = right(contactfullname,length(contactfullname)-position('-' in contactfullname))
  
---Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên viết hoa, chữ cái tiếp theo viết thường. /* không hiểu sao dùng lệnh insert được? */
Gợi ý: ( ADD column sau đó INSERT)
----- sửa
update public.sales_dataset_rfm_prj
set contactlastname = upper(left(contactlastname,1)) || right(contactlastname,length(contactlastname)-1)

update public.sales_dataset_rfm_prj
set contactfirstname = upper(left(contactfirstname,1)) || right(contactfirstname,length(contactfirstname)-1)	
-----
select 
upper(left(contactfirstname,1)) || right(contactfirstname,length(contactfirstname)-1) as up_first_name,
upper(left(contactlastname,1)) || right(contactlastname,length(contactlastname)-1) as up_last_name
from sales_dataset_rfm_prj
  
---Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, năm được lấy ra từ ORDERDATE 

  -- cột month
alter table public.sales_dataset_rfm_prj
add column month_id numeric
update public.sales_dataset_rfm_prj
set month_id=extract (month from orderdate)

  -- cột year
alter table public.sales_dataset_rfm_prj
add column year_id numeric
update public.sales_dataset_rfm_prj
set year_id=extract (year from orderdate)

  --cột quý
alter table public.sales_dataset_rfm_prj
add column qtr_id numeric
update public.sales_dataset_rfm_prj
set qtr_id=extract (quarter from orderdate)
  
---Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED và hãy chọn cách xử lý cho bản ghi đó (2 cách) ( Không chạy câu lệnh trước khi bài được review)
---- cách 1: boxplot
  with box_plot as (
select Q1-1.5*IQR AS min_value,
Q1+1.5*IQR AS max_value
from(
select
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered) as Q1,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) as Q3,
percentile_cont(0.75) WITHIN GROUP (ORDER BY quantityordered) - 
percentile_cont(0.25) WITHIN GROUP (ORDER BY quantityordered)
as IQR
from sales_dataset_rfm_prj) as a)

select * from public.sales_dataset_rfm_prj
where quantityordered < (select min_value from box_plot)
or quantityordered > (select max_value from box_plot)

------cách xử lí
Delete from sales_dataset_rfm_prj
where quantityordered < (select min_value from box_plot)
or quantityordered > (select max_value from box_plot)
  
---- cách 2: z-score
with cte as
(
select *,
(select avg(quantityordered) from public.sales_dataset_rfm_prj) as avg,
(select stddev(quantityordered) from public.sales_dataset_rfm_prj) as stddev
from public.sales_dataset_rfm_prj)

select *, 
(quantityordered-avg)/stddev as z_score
from cte
where abs ((quantityordered-avg)/stddev) >2

------cách xử lí
Delete from sales_dataset_rfm_prj
where abs ((quantityordered-avg)/stddev) >2

---Sau khi làm sạch dữ liệu, hãy lưu vào bảng mới tên là SALES_DATASET_RFM_PRJ_CLEAN
SELECT *
INTO SALES_DATASET_RFM_PRJ_CLEAN
FROM sales_dataset_rfm_prj
  
Lưu ý: với lệnh DELETE ko nên chạy trước khi bài được review

