--1.Add the time_of_day column

alter table sales
add column time_of_day varchar(30);
update sales
 set time_of_day=  (
	CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00'THEN 'Afternoon'
        ELSE 'Evening'
    END
);
--2.Add day_name column?

alter table sales
add column day_name varchar(20)

update sales 
set day_name =to_char(date,day_name);

select * from sales
--3.	Add month_name column?
alter table sales
add column month_name varchar(20);
update sales 
set month_name=to_char(date,'month')
 --4.	What is the most selling product line?

select product_line,sum(quantity)as qty from sales 
group by product_line
order by qty desc

--5.	What is the total revenue by month?

select month_name,sum(total)as total_revenue from sales
group by month_name
order by total_revenue

--6.	 What month had the largest COGS?
select month_name as month,sum(cogs)as cog
from sales
group by month
order by cog desc

--7.	What product line had the largest revenue?
select product_line,sum(total)as largest_rev from sales
group by product_line
order by largest_rev desc

--8 Fetch each product line and add a column to those product 
--line showing "Good", "Bad". Good if its greater than average sales

with product_sales  as( 
select product_line,round(avg(quantity)) as avg_sales,case when
	 avg(quantity) >5.5 then 'Good'
	else 'Bad' 
	end as remark
	from sales
	group by product_line
	)
	select  * from product_sales 
	
--9.Which branch sold more products than average product sold?
select branch,sum(quantity) ,round(avg(quantity))from sales
group by branch
having sum( quantity) >(select avg(quantity)from sales)

--10.What is the most common product line by gender?
select  product_line, gender,count(gender)as gen_count from sales
group by gender,product_line
order by gen_count desc

--11 What is the average rating of each product line?
select product_line, avg(rating) as avg_rating 
from sales
group by product_line

--12.What is the gender distribution per branch?
select gender,branch,count(gender)as gen_count from sales 
group by gender,branch
order by gen_count desc

--13 Which time of the day do customers give most ratings?
select time_of_day, avg(rating)from sales
group by time_of_day
order by avg(rating) desc;

--14.Number of sales made in each time of the day per weekday?

select
	time_of_day,
	count(*) as total_sales
from sales
where day_name = 'sunday'
group by time_of_day 
order by total_sales desc;

--15 Which city has the largest tax/VAT percent?
select  city,max(tax_pct) from sales group by city

--16.Self-join Retrieve the invoice details (invoice_id, customer_type, and total) for transactions made by customers 
--of the same gender in the same city.
select distinct least(s.invoice_id,s1.invoice_id) as inv_id1,greatest(s.invoice_id,s1.invoice_id)
as inv_id2, s.city,s.gender,s.customer_type,s.total  
from sales s join sales s1 on  s.city=s1.city
and s.gender=s1.gender and s.invoice_id<>s1.invoice_id    limit 20

--17.Use a CTE to find the total gross income for each branch, considering
--the gross income as the sum of the total for each transaction.
with total_gross as (
select branch,sum(total)as total_gross_income
	from sales 
	group by branch
	order by total_gross_income desc
)
select * from total_gross

--18.Create a stored procedure that takes a branch name as input and returns the
--average quantity of products sold in transactions for that branch.

 create procedure avg_quantity1(
	  in branch_name_param varchar(20),
	 inout quantity_param int
 )
 language plpgsql
 as $$ 
 
begin

select avg(quantity) into quantity_param

from sales 
where branch=branch_name_param ;
end;
$$;
 
 call avg_quantity1('A',0);

--19.Rank the transactions based on the total amount in descending order. 
--Include the invoice_id, total, and the rank of each transaction.
	 
select invoice_id, total,rank() over (order by total desc) from sales 

--20.Calculate the running total of gross income over time. 
--Display the date, total gross income, and the running total
select date, gross_income,sum(gross_income) over( order by date )as running_total 
from sales






