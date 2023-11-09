--ex1
Select NAME from CITY
Where POPULATION > 120000 and COUNTRYCODE='USA';

--ex2
Select * from CITY
Where COUNTRYCODE ='JPN';

--ex3
select CITY,STATE from STATION;

--ex4
SELECT CITY FROM STATION
Where CITY LIKE 'A%' or CITY LIKE 'E%' or CITY LIKE 'I%'or  CITY LIKE 'O%' or CITY LIKE 'U%';

--ex5
select distinct CITY from STATION
Where CITY Like '%a' or CITY Like '%e' or CITY Like '%i' or CITY Like '%o' or CITY Like '%u'
Order by CITY ASC;

--ex6
select distinct CITY from STATION
Where not (CITY Like 'A%' or CITY Like 'E%' or CITY Like 'I%' or CITY Like 'O%' or CITY Like 'U%')
Order by CITY ASC;

--ex7
select name from Employee
order by name;

--ex8
select name from Employee
where salary > 2000 and months <10
order by employee_id;

--ex9
select product_id from Products
where low_fats ='Y' and recyclable='Y';

--ex10
select name from Customer
where not referee_id = 2 or referee_id is null;

--ex11
select name, population, area from World
where area>=3000000 or population >= 25000000;

--ex12
select distinct author_id AS id from Views
where viewer_id=author_id
order by author_id ASC;

--ex13
SELECT part, assembly_step FROM parts_assembly
where finish_date is null;

--ex14
select * from lyft_drivers
where yearly_salary <= 30000 or yearly_salary >= 70000 ;

--ex15
select advertising_channel from uber_advertising
where money_spent >100000 and year=2019;
