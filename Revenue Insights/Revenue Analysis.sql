use Gold;
select Year(OrderDate) as Year, Month(OrderDate) as Month, count(*) as count
from Product_Sales_2015
group by Year(OrderDate),Month(OrderDate)
order by 1,2;
select Year(OrderDate) as Year, Month(OrderDate) as Month, count(*) as count
from Product_Sales_2016
group by Year(OrderDate),Month(OrderDate)
order by 1,2;
select Year(OrderDate) as Year, Month(OrderDate) as Month, count(*) as count
from Product_Sales_2017
group by Year(OrderDate),Month(OrderDate)
order by 1,2;
drop table if exists Sales;
select * INTO Sales
from Product_Sales_2015
union
select * from Product_Sales_2016
union
select * from Product_Sales_2017;
select * from Sales;
select * from Products
-- Product Cost * Quantity = Cost Price
-- Product Price * Quantity = Selling Price
select 
Cast(S.OrderQuantity as Decimal(10,2)) * cast(P.ProductCost as Decimal (10,2)) as CostPrice,
cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductPrice as Decimal(10,2)) as SellingPrice,
(cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductPrice as Decimal(10,2))- (cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductCost as Decimal(10,2)))) as TotalRevenue
from sales as s
left join Products as P
on s.productkey=p.productkey;
alter VIEW Revenuebyclient as
select distinct
(sum(cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductPrice as Decimal(10,2))- (cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductCost as Decimal(10,2))))) as netrevenue,
P.ModelName,
P.ProductName,
s.customerkey,
s.OrderDate
from sales as s
left join Products as P
on s.productkey=p.productkey
group by 
(cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductPrice as Decimal(10,2))- (cast(s.OrderQuantity as Decimal(10,2)) * cast(P.ProductCost as Decimal(10,2)))),
P.ModelName,
P.ProductName,
s.CustomerKey,
s.OrderDate;
--select * from Revenuebyclient;
--select * from Sales;
--create clustered index idx_orderid on sales(ordernumber);
--create nonclustered index idx_productid on sales(ProductKey);
--select distinct customerkey, min(orderdate) over(partition by customerkey) as Cohortyear from sales;
--select * from sales where customerkey in (17830,21521) order by customerkey;
-- Cohort Analysis--
alter view yearly_cohort as
with yearly_cohort as (
select distinct
customerkey,
year(min(cast(orderdate as date)) over (partition by customerkey)) as CohortYear
from sales
)
select a.CohortYear,year(s.orderdate) as Purchaseyear,sum(netrevenue) as netrevenue from Revenuebyclient as s 
left join yearly_cohort as a
on a.customerkey = s.customerkey
--where s.customerkey in (11767)
group by a.cohortyear,
year(s.orderdate);
select * from yearly_cohort;
create view customer_segmentation as
with revenue as (
select 
ModelName,
CustomerKey,sum(netrevenue) as netrevenue from Revenuebyclient
group by ModelName,CustomerKey
), customer_segment as (
select
PERCENTILE_CONT(0.25) within group (order by netrevenue) over (partition by modelname) as '25 percentile',
PERCENTILE_CONT(0.75) within group (order by netrevenue) over (partition by modelname) as '75 percentile',
*from revenue
), segment_summary as (
select
case when netrevenue < [25 Percentile] then '1- Low value Client'
when netrevenue <= [75 Percentile] then '2- Mid value Client' else '3- High Value Client' end as customer_segment,
* from customer_segment
)
select customer_segment, sum(netrevenue) as netrev, count(distinct CustomerKey) as Totalcustomer
from segment_summary
group by customer_segment;
-- Churn Data
select max(cast(orderdate as Date)) from Revenuebyclient ;
select dateadd(month,-6,'2017-06-30')--(came from above line)--
with getlastpurchase as (
select row_number() over ( partition by customerkey order by orderdate desc) as rn, * from Revenuebyclient
)
select *, case when OrderDate<dateadd(month,-6,'2017-06-30') then 'Churn' else 'Active' end as customer_status into churndata from getlastpurchase 
where rn=1;
select sum(netrevenue) as total_revenue into Totalrevenue from Revenuebyclient;
SELECT COUNT(DISTINCT CustomerKey) AS TotalCustomers InTo TotalCustomers
FROM Sales;