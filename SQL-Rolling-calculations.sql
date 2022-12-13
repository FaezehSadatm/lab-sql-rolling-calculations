use sakila;

#1. Get number of monthly active customers.
create or replace view sakila.customer_activity as
select customer_id, convert(rental_date, date) as Activity_date,
	date_format(convert(rental_date,date), '%m') as Activity_Month,
	date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental;
select * from sakila.customer_activity;

create or replace view sakila.monthly_active_customers as
select Activity_year, Activity_Month, count(distinct customer_id) as Active_customers
from sakila.customer_activity
group by Activity_year, Activity_Month;
select * from monthly_active_customers;


#2. Active users in the previous month.
select Activity_year, Activity_month, Active_customers, 
   lag(Active_customers) over (order by Activity_year, Activity_Month) as Last_month
from sakila.monthly_active_customers;


#3. Percentage change in the number of active customers.
create or replace view sakila.diff_monthly_active_customers as
with cte_view as 
(
	select 
	Activity_year, 
	Activity_month,
	Active_customers, 
	lag(Active_customers) over (order by Activity_year, Activity_Month) as Last_month
	from sakila.monthly_active_customers
)
select 
   Activity_year, 
   Activity_month, 
   Active_customers, 
   Last_month, 
   (Active_customers - Last_month) / last_month * 100 as Difference_percentage 
from cte_view;
select * from sakila.diff_monthly_active_customers;


#4. Retained customers every month.
create or replace view sakila.distinct_customers as
select
	distinct 
	customer_id as Active_id, 
	Activity_year, 
	Activity_month
from sakila.customer_activity
order by Activity_year, Activity_month, customer_id;
select * from sakila.distinct_customers;

create or replace view sakila.retained_customers as
select d1.Active_id, d1.Activity_year, d1.Activity_month, d2.Activity_month as Previous_month from sakila.distinct_customers d1
join sakila.distinct_customers d2
on d1.Activity_year = d2.Activity_year 
and d1.Activity_month = d2.Activity_month+1
and d1.Active_id = d2.Active_id 
order by d1.Active_id, d1.Activity_year, d1.Activity_month;
select * from sakila.retained_customers;

create or replace view sakila.total_retained_customers as
select Activity_year, Activity_month, count(Active_id) as retained_customers from retained_customers
group by Activity_year, Activity_month;
select * from sakila.total_retained_customers;
