-- Create a table represent the dataset
CREATE TABLE sales (
    row_id INT,
    order_id CHAR(14),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(64),
    customer_id CHAR(8),
    customer_name VARCHAR(255),
    segment VARCHAR(255),
    country VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    postal_code INT,
    region VARCHAR(255),
    product_id CHAR(15),
    category VARCHAR(255),
    sub_category VARCHAR(255),
    product_name VARCHAR(255),
    sales FLOAT,
    quantity INT,
    discount FLOAT,
    profit INT
);


-- View sales table
SELECT *
FROM sales;

-- Sales by region
select region, count(order_id) as total_orders, sum(sales) as total_sales, avg(sales) as avg_sales
from sales
group by region
order by total_sales desc;

-- Sales revenue by category. 
SELECT category,
    COUNT(order_id) AS total_orders,
    SUM(sales) AS total_sales
FROM sales
GROUP BY category
ORDER BY total_sales DESC;

-- Create a new column for year and month
ALTER TABLE sales
ADD order_year INT,
ADD order_month INT;

UPDATE sales 
SET order_year = YEAR(order_date),
order_month = MONTH(order_date);

-- Monthly sales trends
SELECT order_month, 
       SUM(sales) as total_sales
FROM sales
GROUP BY order_month
ORDER BY order_month;


-- Over the years which month had highest sales for each category.
with cte as 
	(SELECT order_month, category, sum(sales) as total_sales
     from sales
     GROUP BY category, order_month
     order by category, total_sales desc)

select category, order_month, total_sales,
row_number() over(partition by category) as row_num
from cte
order by row_num
limit 3;

-- Total sales by customer segment
SELECT segment, SUM(sales) as total_sales
FROM sales
GROUP BY segment
ORDER BY total_sales desc;


-- Find top 10 highest selling states
select state, sum(sales) as total_sales
from sales
group by state
order by total_sales desc
limit 10;

-- Find the top 10 highest selling products
select product_name, sum(sales) as total_sales
from sales
group by product_name
order by total_sales desc
limit 10;

-- Find month over month growth comparison for 2014 to 2017 sales
with cte as (
select order_year, order_month, sum(sales) as monthly_sales
from sales
group by order_year, order_month
)

SELECT order_month,
sum(case when order_year = 2014 then monthly_sales else 0 end) as sales_2014,
sum(case when order_year = 2015 then monthly_sales else 0 end) as sales_2015,
sum(case when order_year = 2016 then monthly_sales else 0 end) as sales_2016,
sum(case when order_year = 2017 then monthly_sales else 0 end) as sales_2017
from cte 
group by order_month
order by order_month;


-- which category had highet growth percentage by profit last two years.
with cte as (
select category, order_year, sum(sales) as total_sales
from sales
group by category, order_year
having order_year in (2016, 2017)
),
cte2 as (
select category,
sum(case when order_year = 2016 then total_sales else 0 end) as sales_2016,
sum(case when order_year = 2017 then total_sales else 0 end) as sales_2017
from cte
group by category
)

select category,
(sales_2017 - sales_2016) * 100 / sales_2016 as growth
from cte2
order by growth desc;






