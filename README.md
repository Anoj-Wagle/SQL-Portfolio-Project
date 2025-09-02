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
## A. 
## 2. Australian Current and Projected Housing Needs 2022 by Local Government Area

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




