--- ex1
select productline,year_id, dealsize,
sum(sales) as revenue
from public.sales_dataset_rfm_prj
group by productline,year_id, dealsize
order by productline,year_id, dealsize

---ex2
select * from 
(select year_id,month_id,ordernumber, revenue,
row_number() over(partition by year_id order by revenue desc) as row
from 
(select year_id,month_id,ordernumber,
sum(sales) over(partition by year_id, month_id, ordernumber) as revenue
from public.sales_dataset_rfm_prj) as a) as b
where row =1 

---ex3
select productline, month_id,revenue,ordernumber from
(
select *,
row_number() over(partition by year_id order by revenue desc) as rank from
(select productline,year_id, month_id,
sum(sales) as revenue,
sum(ordernumber) as ordernumber
from public.sales_dataset_rfm_prj
where month_id=11
group by productline, year_id,month_id
order by year_id, sum(sales) desc) as a) as b
where rank=1

---ex4
select year_id, productline, revenue,
dense_rank() over(partition by year_id order by revenue desc) from
(select productline,year_id,country,
sum(sales) as revenue
from public.sales_dataset_rfm_prj
where country='UK'
group by productline,year_id,country
order by year_id) as a

---ex5
with customer_rfm as 
(
select customername,
current_date - max(orderdate) as R,
count(customername) as F,
sum(sales) as M
from public.sales_dataset_rfm_prj 
group by customername
	),
	rfm_score as
	(
select customername,
ntile(5) over(order by r desc) as r_score,
ntile(5) over(order by f desc) as f_score,
ntile(5) over(order by m desc) as m_score
from customer_rfm
		),
		rfm_final as
		(
		select customername,
		cast(r_score as varchar)||cast(f_score as varchar)||cast(m_score as varchar) as rfm_score
		from rfm_score
			)
			select segment,count(*) from (
			select a.customername, b.segment from
			rfm_final a
			join segment_score b on a.rfm_score=b.scores) as a
			group by segment
			order by count(*)



