

-- How many customers do we have in the data

SELECT COUNT(distinct(customer_id))as total_customer
FROM sales_table

--How many different cities do we have in the data?

SELECT   count(distinct(shipping_city)) as total_city
FROM sales_table

--Show the total spent by customers from low to high.


SELECT customer_id, SUM(order_sales) AS total_spend, customer_name,sum(order_profits)
FROM sales_table
where order_profits=5
GROUP BY customer_id, customer_name
ORDER BY 1 ASC;

--What is the most profitable city in the State of Tennessee?
--What’s the average annual profit for that city across all years?

SELECT top 10
shipping_city,shipping_state,  sum(order_profits) as most_profitable,avg(order_profits) as avg_profit
FROM sales_table
where shipping_state like '%Tennessee%'
group by shipping_state, shipping_city
order by most_profitable desc


--What is the distribution of customer types in the data?
select count(distinct(customer_id)),customer_segment
from sales_table
group by customer_segment

--What’s the most profitable product category on average in Iowa across all years?

select shipping_state, avg(order_profits)as avg_profit ,product_category
from sales_table
where shipping_state like '%Iowa%'
group by shipping_state,product_category
order by avg_profit desc



--What is the most popular product in that category across all states in 2016?
with h_ as
(select  distinct(product_name)as p_n, quantity,YEAR(CONVERT(datetime, order_date, 120)) AS order_year
from sales_table
where product_category like 'Furniture' 

)
select order_year,p_n, sum(quantity) as total
from h_
where order_year= 2016
group by order_year,p_n
order by 3 desc

--Which customer got the most discount in the data (in total amount)
with t_s as
(select  customer_id,  order_sales,order_sales/( 1-order_discount)as  original_price
from sales_table
)
select customer_id, order_sales-original_price as dis_am
from t_s
order by 2 desc


--Which order was the highest in term of sales in 2015?

 with sales_H as
(select order_id, order_sales, YEAR(CONVERT(datetime, order_date, 120)) as date_year
from sales_table
)
SELECT *
from sales_H
where date_year=2015
order by 2 desc


--What was the rank of each city in terms of the amount in the East region in 2015
with sales_H as
(select shipping_city,quantity, YEAR(CONVERT(datetime, order_date, 120)) as date_year,
RANK() OVER (PARTITION BY shipping_city ORDER BY quantity desc) AS rank
from sales_table
where shipping_region like 'East'
group by shipping_city,quantity,order_date
)
select shipping_city, quantity ,
RANK() OVER (PARTITION BY shipping_city ORDER BY quantity asc)
from sales_H
where date_year= 2015

order by 3




SELECT *
from sales_H
where date_year=2015
order by 4 asc

--Display customer names for customers who are in the
--segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total

with total_c_c as
(select distinct(customer_id), customer_segment  
from sales_table
where customer_segment in ('Consumer' , 'Corporate'))
select COUNT(*) as total_customer
from total_c_c


--Calculate the difference between the largest and smallest order 
--quantities for product id ‘100.’

SELECT product_id ,min(quantity)as min_q, MAX(quantity)as max_q,(min(quantity)- MAX(quantity)) as q_dif
FROM sales_table
WHERE product_id = 100
group by product_id

--Calculate the percent of products that are within the category ‘Furniture.’ 

SELECT 
  (SUM(quantity) * 100 / (SELECT SUM(quantity) FROM sales_table)) AS percentage
FROM sales_table
WHERE product_category = 'Furniture'



--Display the number of duplicate products based on their product manufacturer. 

Select distinct(product_manufacturer), count(*)
from sales_table
where product_manufacturer like 'SanDisk'
group by product_manufacturer
having count(*)>1;

--	Show the product_subcategory and the total number of products in the subcategory. 
--Show the order from most to least products and 
--then by product_subcategory name ascending.

select sum(quantity) as total_number,product_subcategory
from sales_table
group by product_subcategory
order by  1 desc  

--Show the product_id(s), the sum of quantities, 
--where the total sum of its product quantities is greater than or equal to 100.

select product_id , sum(quantity)
from sales_table
where quantity > 100
group by product_id
