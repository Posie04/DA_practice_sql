select distinct CITY from STATION
Where not (CITY Like 'A%' or CITY Like 'E%' or CITY Like 'I%' or CITY Like 'O%' or CITY Like 'U%')
Order by CITY ASC;
