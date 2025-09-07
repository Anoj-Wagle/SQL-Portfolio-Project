# SQL-Portfolio-Project
**These projects showcase my proficiency in SQL for data analysis, manipulation, and reporting across various datasets.**

## 1. Customer Revenue Insights:

# Project Overview:
This project analyzes a comprehensive sales dataset spanning from 2015 to 2017. It highlights annual sales revenue, customer trends, churn analysis, and segmentation insights. The primary objective is to present these key metrics through a dynamic and interactive dashboard, enabling data-driven decision-making.

# Tools and Technologies Used
* **SQL** – Data extraction, cleaning, and transformation.
* **Power BI** – Interactive dashboard design, visualization, and reporting.
* **DAX (Data Analysis Expressions)** – Creating custom metrics and calculations.
* **Power Query** – Data shaping and ETL (Extract, Transform, Load) processes.
  
## Dataset Overview
The dataset includes following details.
- Product Sales in 2015
- Product Sales in 2016
- Product Sales in 2017

## Queries
# 1. Merge product table
Using `Union` function merged the product sales of all three years.
```sql
select * from Product_Sales_2015
select * into sales
from product_sales_2015
union 
select * from product_sales_2016
union 
select * from product_sales_2017
```
# 2. Revenue Per Client
A `revenue_per_client` view was created
```sql
create view revenueperclient as 
select distinct 
sum((CAST(s.OrderQuantity AS DECIMAL(10,2)) * CAST(P.ProductPrice AS DECIMAL(10,2)) - 
     CAST(s.OrderQuantity AS DECIMAL(10,2)) * CAST(P.ProductCost AS DECIMAL(10,2)))) AS 'NetRevenue', 
p.ModelName,
p.Productname,
s.CustomerKey,
s.OrderDate
from sales as s
left join products as p 
on s.productkey = p.productkey
group by p.ModelName,
p.Productname,
s.CustomerKey,
s.OrderDate;
```
# 3. Cohort Analysis
This analysis provides an insight to the total people retention each year from 2015 to 2017.
```sql
create view yearly_cohort_customer as 
with yearly_cohort as (
select 
distinct 
CustomerKey,
year(min(orderdate) over(partition by customerkey)) as cohort_year
from 
sales
)
select 
y.cohort_year,
year(s.OrderDate) as Purchase_year,
count(distinct s.customerkey) as UniqueCustomer
from revenueperclient as s
left join yearly_cohort as y
on s.CustomerKey = y.CustomerKey
group by y.cohort_year,year(s.OrderDate)
```
# 4. Customer Segmentation
This provides insights on the customer value from low, median to high values.
```sql
alter view customer_segmentation as 
with revenue as 
(
select 
Modelname,
customerkey,
sum(netrevenue) as netrevenue
from revenueperclient
group by Modelname,customerkey
), customer_segments as (
select 
PERCENTILE_CONT(0.25) within group (order by netrevenue) over(partition by Modelname) as '25_percetile',
PERCENTILE_CONT(0.75) within group  (order by netrevenue) over(partition by Modelname) as '75_percetile',
*
from 
revenue 
), segment_summary as (
select 
case when netrevenue < [25_percetile] then '1 - Low Value Client'
when netrevenue <= [75_percetile] then '1 - Mid Value Client'
else '3- High-value' end as customer_segment,
*
from 
customer_segments
)
select customer_segment,sum(netrevenue) as  netrevenue
from segment_summary
group by customer_segment
```
# 5. Churn Analysis
Customer retention is all about keeping customers. The **churn rate** measures how many customers you lose. An **Active Customer** has purchased in the last six months, while a **Churned Customer** hasn't.
```sql
with getlastpurchase as (
select 
ROW_NUMBER() over (partition by customerkey order by orderdate desc) as rn,
*
from revenueperclient
)
select *,case when orderdate<dateadd(month,-6,(select max(orderdate) from revenueperclient)) then 'Churn'
        else 'Active' end as customer_status
		into churndata
from getlastpurchase where rn= 1
```
# Power BI Dashboard
This dashboard simplifies the results of a SQL analysis of sales dataset from 2015 to 2017. It automatically converts the complex SQL queries into easy-to-understand charts and diagrams for a quick visual summary.

![1755064585095](https://github.com/user-attachments/assets/a5b88b84-fc54-49ef-804d-f196faea65a0)

# Dashboard Overview
# 1. Cohort Analysis Impact on Net Revenue
This analysis highlights the net revenue generated from customers, focusing on their repeat activity. It compares the revenue contributed by these returning customers in 2016 and 2017 against the baseline year of 2015.

<img width="1375" height="802" alt="image" src="https://github.com/user-attachments/assets/441f5fcf-304b-4595-8934-0bf98795ec8a" />

# 2. Customer Segmentation
This pie chart illustrates the distribution of total customer revenue across three segments: low, medium, and high.

<img width="1353" height="777" alt="image" src="https://github.com/user-attachments/assets/e302955e-e0bf-426f-834a-777c3893244e" />

# 3. Churn Analysis:
This donut chart shows the distribution of customers based on their activity within the past six months. Active customers are those who engaged during this period, while the churn segment represents those who have not been active for six months or more, as identified through churn analysis.

<img width="1199" height="741" alt="Screenshot 2025-09-07 112427" src="https://github.com/user-attachments/assets/41983bcc-9889-432e-8d1f-46752938ecf4" />

# 4. The first KPI cards provides information about the total revenue of $ 8.48 Million from customers.

# 5. The second KPI provides insights on total customers (14K).

# Business Insights
## 1. Providing insights into customer retention and highlighting the revenue impact every year.
## 2. The business can analyze the number of active customers in the past six months and identify the types of customers who remain active.
## 3. Categorize customers based on their spending patterns, classifying them into high, medium, and low revenue segments, which also reflects their level of activity.

# You can download project here: [Download Now](https://github.com/Anoj-Wagle/SQL-Portfolio-Project/tree/main/Revenue%20Insights)


# 2. Australian Current and Projected Housing Needs 2022 by Local Government Area

# Project Overview:
This project analyzes Australian projected housing demand at the Local Government Area (LGA) level in year 2022, highlighting regions under significant pressure by quantifying the impact of unmet housing needs. It identifies the top 10 LGAs with the highest unmet demand and the top 10 with the most severe homelessness rates in each state. Furthermore, it tracks the quarterly dynamics of the rental market by measuring the movement in rental stress between **Q1** and **Q2**.

# Data Source:
The analysis presented in this report is based on the National Current and Projected Housing Needs (2022): Sourced from the Australian Housing Data Analytics Platform (AHDAP). The data was retrieved from the AHDAP Data Exchange [National Current and Projected Housing Needs 2022](https://housing-data-exchange.ahdap.org/).

# Tools and Technologies Used:
* **SQL** – Data extraction, cleaning, and transformation.
* **Power BI** – Interactive dashboard design, visualization, and reporting.

# Dataset Overview
The dataset includes following columns
1. LGA - Local Government Area
2. LGA_Code
3. Household at 2021
4. State
5. Current unmet need estimate
6. Current unmet need all households
7. Source of unmet need Q1 rent stress
8. Source of unmet need Q2 rent stress
9. Source of unmet need manifest homeless
10. Current Social housing at 2021
11. Current social housing all need met unmet
12. Projected need by 2041 estimate
13.	Projected_need_by_2041_As_annual_SH_growth
14.	Projected_need_by_2041_As_average_annual_build

# SQL Queries and Transformation Steps
## 1. Top 10 LGA by unmeet Household 
A view was created to extract top 10 LGA where household requirements unmet.
```sql
create view Top10_LGA_by_unmeet_household as 
with ranking_top10LGA as (
select
row_number() over(partition by state order by current_unmet_need_all_households desc) as rn, * from LGA
)
select * from ranking_top10LGA
where rn <= 10;
```
## 2. Rental Stress Movement
Create a view to calculate the rental stress movement from **Q1** to **Q2**.
```sql
alter view rentalstressmovementQ1toQ2 as 
with Q1toQ2rentalstressmovement as (
select 
row_number() over (partition by state order by (
				cast(Source_of_unmet_need_Q1_rent_stress as decimal(19,2))-
				cast(Source_of_unmet_need_Q2_rent_stress as decimal(19,2))) DESC ) as rn,
*
from LGA 
where Source_of_unmet_need_Q1_rent_stress <> '-'
)
select *,
(cast(Source_of_unmet_need_Q1_rent_stress as decimal(19,2))-
cast(Source_of_unmet_need_Q2_rent_stress as decimal(19,2))) as Pert_Diff_Q1toQ2
from 
Q1toQ2rentalstressmovement
where rn<=10;
```
## 3. LGA Categorization
Create a view for LGA categorization with **Extremely High Impactful LGA**, **High Impactful LGA**,
**Median Impactful LGA** and **Low Impactful LGA**.
```sql
alter view lga_categorization1 as 
with percentiles as (
select distinct 
state,
PERCENTILE_CONT(0.50) within group(order by cast(current_unmet_need_all_households as decimal(19,2))) over(partition by state) as Q2,
PERCENTILE_CONT(0.25) within group(order by cast(current_unmet_need_all_households as decimal(19,2))) over(partition by state) as Q1,
PERCENTILE_CONT(0.75) within group(order by cast(current_unmet_need_all_households as decimal(19,2))) over(partition by state) as Q3,
a.current_unmet_need_all_households
from LGA a 
where current_unmet_need_all_households <> '-'
), calculate_percentile as (
select  
(Q3-Q1) as IQR,
Q1-1.5*((Q3-Q1)) as lower_fence,
Q3+1.5*((Q3-Q1)) as Upper_fence,
case when current_unmet_need_all_households > Q3+1.5*((Q3-Q1)) then 'Extremely High Impactful LGA'
when current_unmet_need_all_households >= Q3 then 'High Impactful LGA'
when current_unmet_need_all_households >= Q2 then 'Median Impactful LGA'
when current_unmet_need_all_households >= Q1 then 'Low Impactful LGA' else 'Low Impactful LGA' end as usages,
state
from percentiles
)
select state,usages,count(*) as Count from calculate_percentile
group by state,usages;
```
## 4. Top 10 LGA by Homeless
I created a view to see the top 10 LGA from each state to see homeless people.
```sql
alter view top10LGAbyHomeless as 
with ranking_top10Homeless as (
select 
row_number() over(partition by state order by Source_of_unmet_need_Manifest_homeless desc) as rn,*
from LGA
)
select * from ranking_top10Homeless
where rn <=10;
```
## 5. Slicer and KPI
These provide insights about the total number of local government area and states.

# Power BI Dashboard Overview
This dashboard simplifies the results of a SQL analysis of Australian Current and Projected Housing Need. It automatically converts the complex SQL queries into easy-to-understand charts and diagrams for a quick visual summary.

<img width="1348" height="929" alt="image" src="https://github.com/user-attachments/assets/cbc704cb-e3e7-474b-b1b7-ef9dc8d5aa41" />

# Key Dashboard Features
1. LGA Impact Analysis:
The resulting donut chart will clearly show the percentage breakdown of LGAs by impact level within each state. For example, you can quickly see what percentage of LGAs in New South Wales are categorized as 'High Impactful' compared to those in Victoria. The chart will also show the total count of LGAs in the center, providing context. This makes it an effective way to communicate the findings of your SQL analysis at a glance.
2. Top 10 LGA by unmeet needs:
This bar chart serves as a direct ranking of the top 10 local government areas with the highest number of households in unmet need. It quickly highlights the most critical areas, with the height of each bar representing the total count of households in need, making it easy to identify which regions require the most urgent attention.
3. Top 10 LGAs Rental Stress Movement Between **Q1** to **Q2**:
This horizontal bar chart visualizes the change in rental stress over time. By showing the percentage difference between two quarters (Q1 and Q2), it effectively identifies the top 10 LGAs where rental affordability is worsening most rapidly, helping to pinpoint emerging issues and areas of concern for renters.
4. Top 10 LGAs homeless household by Local_government_area:
This horizontal bar chart is designed to clearly rank the top 10 LGAs by the number of homeless households. It provides a straightforward and impactful visualization of the regions most affected by homelessness, making it a critical tool for directing resources and support to the areas with the highest needs.

    **Business Insights**
* **Top LGAs with High Housing Needs** : The data identifies the specific areas with the most urgent demand for housing, guiding where to build or invest.
* **Worsening Rental Markets** : It shows which LGAs have the fastest-growing rental stress, alerting businesses to potential risks or opportunities in those markets.
* **Areas for Intervention** : The dashboard highlights the top areas for homelessness and unmet needs, helping organizations focus their efforts where they can have the biggest impact.
* **Strategic Planning** : Businesses and policymakers can use this information to plan future projects and resource allocation more effectively.

# You can download project here : [Download Now](https://github.com/Anoj-Wagle/SQL-Portfolio-Project/tree/main/Housing%20Demand%20by%20LGA)

## Contribution
Your input is valuable! Please fork, suggest improvements, or share ideas for future SQL and Power BI tools. We're committed to delivering more impactful Excel-based solutions, so expect exciting updates soon! 🚀

**✨ Stay tuned as I continue to roll out more valuable Excel-based solutions!**




