-- Create table sales
CREATE TABLE sales
(
	invoice_id	VARCHAR(30) NOT NULL PRIMARY KEY,
branch	VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type	VARCHAR(30) NOT NULL,
gender	VARCHAR(10) NOT NULL,
product_line	VARCHAR(100) NOT NULL,
unit_price	DECIMAL(10, 2) NOT NULL,
quantity	INT NOT NULL,
VAT	DECIMAL(6, 4) NOT NULL,
total DECIMAL(10, 2) NOT NULL,
date DATE NOT NULL,
time TIMESTAMP NOT NULL,
payment_method	VARCHAR(15) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_percentage	DECIMAL(11, 9) NOT NULL,
gross_income DECIMAL(12, 2) NOT NULL,
rating DECIMAL(2, 1) NOT NULL
)

	
--Import data and view file
SELECT * FROM sales



	
---------------------------Feature Engineering-----------------------

-----Add column-time_of_day
SELECT time,
 (
	CASE
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN time BETWEEN '12:00:00' AND '16:00:00' THEN 'Evening'
	ELSE 'Night'
	END
	)
	AS time_of_day
	FROM sales

	
--Add to table
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(10)
--
UPDATE sales
SET time_of_day= (
	CASE
	WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN time BETWEEN '12:00:00' AND '16:00:00' THEN 'Evening'
	ELSE 'Night'
	END
	)
--
SELECT * FROM sales
	


	
-----Add column-name_of_day
SELECT date, TO_CHAR(DATE , 'Dy')
	FROM sales

--Add to table
ALTER TABLE sales
ADD COLUMN name_of_day VARCHAR(3)
--
UPDATE sales
SET 
	name_of_day= (TO_CHAR(DATE , 'Dy'))
--
SELECT * FROM sales


	
-----Add column-month_name
SELECT date, 
	TO_CHAR(date, 'Month')
	FROM sales

--Add to table
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10)
--
UPDATE sales
SET 
	month_name= (TO_CHAR(date, 'Month'))
--
SELECT * FROM sales


	
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

----------------------Business Questions To Answer---------------------

	
-------GENERIC----------

	
--1. How many unique cities does the data have?
SELECT 
	COUNT(DISTINCT city)
FROM sales

	
--2. In which city is each branch?
SELECT  branch, city FROM sales
GROUP BY branch, city
ORDER BY branch



	
-------PRODUCT----------

	
--1. How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line) 
	FROM sales

	
--2. What is the most common payment method?
SELECT payment_method, 
	COUNT(payment_method) as numb
FROM sales
GROUP BY payment_method
ORDER BY numb desc
LIMIT 1

	
--3. What is the most selling product line?
SELECT product_line, 
	COUNT(product_line) as numb
FROM sales
GROUP BY product_line
ORDER BY numb desc
LIMIT 1

	
--4. What is the total revenue by month?
SELECT month_name, SUM(total) as revenue
FROM sales
GROUP BY month_name
ORDER BY revenue desc

	
--5. What month had the largest COGS?
SELECT month_name, SUM(cogs) as max_cogs
FROM sales
GROUP BY month_name
ORDER BY max_cogs desc
LIMIT 1

	
--6. What product line had the largest revenue?
SELECT product_line, SUM(total) as revenue
FROM sales
GROUP BY product_line
ORDER BY revenue desc
LIMIT 1

	
--7. What is the city with the largest revenue?
SELECT city, SUM(total) as revenue
FROM sales
GROUP BY city
ORDER BY revenue desc
LIMIT 1

	
--8. What product line had the largest VAT?
SELECT product_line, AVG(vat) as vat
FROM sales
GROUP BY product_line
ORDER BY vat desc
LIMIT 1


--9. Fetch each product line and add a column to those product line
--showing "Good", "Bad". Good if its greater than average sales
SELECT ROUND(AVG(total),0) as avg_sales 
FROM sales
--
SELECT product_line,
	(
	CASE
	WHEN SUM(total)> 323 THEN 'Good'
	ELSE 'Bad'
	END
	) AS sales
FROM sales
GROUP BY product_line

	
--10. Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) as qty
FROM sales
GROUP BY branch
	HAVING SUM(quantity)> 
	(SELECT AVG(quantity) FROM sales)
ORDER BY SUM(quantity) desc
	LIMIT 1


--11. What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) as qty
FROM sales
GROUP BY gender, product_line
ORDER BY qty desc

	
--12. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) as average
FROM sales
GROUP BY product_line
ORDER BY average desc




-------SALES----------

	
--1. Number of sales made in each time of the day per weekday
SELECT name_of_day, time_of_day, 
		COUNT(total) as number_of_sales
FROM sales
GROUP BY name_of_day, time_of_day
ORDER BY name_of_day, time_of_day 


--2. Which of the customer types brings the most revenue?
SELECT customer_type, COUNT(total) as revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue desc


--3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, AVG(vat) as tax_percentage
FROM sales
GROUP BY city
ORDER BY tax_percentage desc


--4. Which customer type pays the most in VAT?
SELECT customer_type, AVG(vat) as VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT desc




-------CUSTOMER----------

	
--1. How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) as customer_types
FROM sales


--2. How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment_method) as payment_methods
FROM sales


--3. What is the most common customer type?
SELECT customer_type, 
	COUNT(customer_type) as typ
FROM sales
GROUP BY customer_type
ORDER BY typ desc
LIMIT 1


--4. Which customer type buys the most?
SELECT customer_type, 
	COUNT(*) as typ
FROM sales
GROUP BY customer_type
ORDER BY typ desc
LIMIT 1


--5. What is the gender of most of the customers?
SELECT gender, 
	COUNT(gender) as num
FROM sales
GROUP BY gender
ORDER BY num desc
LIMIT 1


--6. What is the gender distribution per branch?
SELECT branch, gender, 
	COUNT(gender) as num
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender


--7. Which time of the day do customers give most ratings?
SELECT time_of_day,  
	ROUND(AVG(rating),2) as rating
FROM sales
GROUP BY time_of_day
ORDER BY rating desc


--8. Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day,  
	ROUND(AVG(rating),2) as rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, rating desc


--9. Which day fo the week has the best avg ratings?
SELECT name_of_day, 
	ROUND(AVG(rating),2) as rating
FROM sales
GROUP BY name_of_day
ORDER BY rating


--10. Which day of the week has the best average ratings per branch?
SELECT branch, name_of_day,  
	ROUND(AVG(rating),2) as rating
FROM sales
GROUP BY branch, name_of_day
ORDER BY branch, rating desc

