CREATE TABLE amazondata2 (
    `Invoice ID` VARCHAR(30),
    `Branch` VARCHAR(5),
    `City` VARCHAR(30),
    `Customer type` VARCHAR(30),
    `Gender` VARCHAR(10),
    `Product line` VARCHAR(100),
    `Unit price` DECIMAL(10, 2),
    `Quantity` INT,
    `Tax 5%` DECIMAL(10, 2),
    `Total` DECIMAL(10, 2),
    `Date` DATE,
    `Time` TIMESTAMP,
    `Payment` VARCHAR(30),
    `cogs` DECIMAL(10, 2),
    `gross margin percentage` DECIMAL(11, 9),
    `gross income` DECIMAL(10, 2),
    `Rating` DECIMAL(2, 1)
);

SELECT * FROM Test.amazondata2;
ALTER TABLE Test.amazondata2
ADD COLUMN timeofday VARCHAR(10),
ADD COLUMN dayname VARCHAR(10),
ADD COLUMN monthname VARCHAR(10);
SET SQL_SAFE_UPDATES = 0;

SHOW FIELDS FROM Test.amazondata2;

-- Step 2: Update the 'timeofday' column based on the time component of the 'Time' column
UPDATE amazondata2
SET timeofday = CASE
    WHEN CAST(SUBSTRING(Time, 1, 2) AS UNSIGNED) < 12 THEN 'Morning'
    WHEN CAST(SUBSTRING(Time, 1, 2) AS UNSIGNED) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;
UPDATE amazondata2
SET dayname = CASE DAYOFWEEK(Date)
    WHEN 1 THEN 'Sun'
    WHEN 2 THEN 'Mon'
    WHEN 3 THEN 'Tue'
    WHEN 4 THEN 'Wed'
    WHEN 5 THEN 'Thu'
    WHEN 6 THEN 'Fri'
    WHEN 7 THEN 'Sat'
END;
UPDATE amazondata2
SET monthname = CASE MONTH(Date)
    WHEN 1 THEN 'Jan'
    WHEN 2 THEN 'Feb'
    WHEN 3 THEN 'Mar'
    WHEN 4 THEN 'Apr'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'Jun'
    WHEN 7 THEN 'Jul'
    WHEN 8 THEN 'Aug'
    WHEN 9 THEN 'Sep'
    WHEN 10 THEN 'Oct'
    WHEN 11 THEN 'Nov'
    ELSE 'Dec'
END;
-- 1.What is the count of distinct cities in the dataset?
SELECT 
    COUNT(DISTINCT City) AS distinct_cities_count
FROM
    amazondata2;
    
-- 2.For each branch, what is the corresponding city?

SELECT DISTINCT
    Branch, City
FROM
    amazondata2;

-- 3.What is the count of distinct product lines in the dataset?
SELECT 
    COUNT(DISTINCT `Product line`) AS distinct_product_lines_count
FROM
    amazondata2;

-- 4. Which payment method occurs most frequently?
SELECT 
    `Payment`, COUNT(*) AS frequency
FROM
    amazondata2
GROUP BY `Payment`
ORDER BY frequency DESC
LIMIT 1;

-- 5.Which product line has the highest sales?
SELECT 
    `Product line`, SUM(`Total`) AS total_sales
FROM
    amazondata2
GROUP BY `Product line`
ORDER BY total_sales DESC
LIMIT 1;

-- 6.How much revenue is generated each month?
/* This query retrieves the year and month from the Date column, calculates the sum of total sales (Total) for each month,
 and groups the results by year and month. It then orders the results by year and month.*/
SELECT 
    MONTH(`Date`) AS month,
    YEAR(`Date`) AS year,
    SUM(`Total`) AS monthly_revenue
FROM 
    amazondata2
GROUP BY 
    YEAR(`Date`),
    MONTH(`Date`)
ORDER BY 
    year,
    month;
    
-- 7. In which month did the cost of goods sold reach its peak?
/* This query calculates the total cost of goods sold (cogs) for each month, grouping the results by year and month.
 It then orders the results in descending order based on the total cost of goods sold and selects only the first row using the LIMIT 1 clause,
 which corresponds to the month with the highest cost of goods sold.
*/

SELECT 
    YEAR(`Date`) AS year,
    MONTH(`Date`) AS month,
    SUM(`cogs`) AS total_cogs
FROM 
    amazondata2
GROUP BY 
    YEAR(`Date`),
    MONTH(`Date`)
ORDER BY 
    total_cogs DESC
LIMIT 1;

-- 8.Which product line generated the highest revenue?
/* This query calculates the total revenue for each product line by summing up the Total column. It then groups the results by Product line,
 orders them in descending order based on total revenue, and selects only the first row using the LIMIT 1 clause,
 which corresponds to the product line with the highest revenue.*/
 
 SELECT 
    `Product line`,
    SUM(`Total`) AS total_revenue
FROM 
    amazondata2
GROUP BY 
    `Product line`
ORDER BY 
    total_revenue DESC
LIMIT 1;

-- 9.In which city was the highest revenue recorded?
/* This query calculates the total revenue for each city by summing up the Total column. It then groups the results by City, orders them in descending order based on total revenue,
 and selects only the first row using the LIMIT 1 clause,
 which corresponds to the city with the highest revenue.*/
 
 SELECT 
    `City`,
    SUM(`Total`) AS total_revenue
FROM 
    amazondata2
GROUP BY 
    `City`
ORDER BY 
    total_revenue DESC
LIMIT 1;

-- 10.Which product line incurred the highest Value Added Tax?
/* This query calculates the total VAT for each product line by summing up the VAT column. It then groups the results by Product line, orders them in descending order based on total VAT,
 and selects only the first row using the LIMIT 1 clause, which corresponds to the product line with the highest VAT.*/
 
 SELECT 
    `Product line`,
    SUM(`Tax 5%`) AS total_vat
FROM 
    amazondata2
GROUP BY 
    `Product line`
ORDER BY 
    total_vat DESC
LIMIT 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
/* This query first calculates the total sales for each product line using a subquery and calculates the average sales across all product lines. Then,
 it compares the total sales of each product line with the average sales. If the total sales are above the average, it assigns "Good" to the sales_status column; otherwise,
 it assigns "Bad".*/
SELECT
    *,
    CASE
        WHEN total_sales > avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS sales_status
FROM
    (
    SELECT
        `Product line`,
        SUM(`Total`) AS total_sales,
        (SELECT AVG(`Total`) FROM amazondata2) AS avg_sales
    FROM
        amazondata2
    GROUP BY
        `Product line`
    ) AS subquery;
    
-- 12. Identify the branch that exceeded the average number of products sold.
/* This query calculates the total quantity of products sold for each branch and compares it with the average quantity of products sold across all branches.
 It retrieves the branches where the total quantity
 exceeds the average quantity. */
 SELECT
    `Branch`,
    SUM(`Quantity`) AS total_quantity,
    (SELECT AVG(`Quantity`) FROM amazondata2) AS avg_quantity
FROM
    amazondata2
GROUP BY
    `Branch`
HAVING
    total_quantity > avg_quantity;
    
-- 13. Which product line is most frequently associated with each gender?
/* This query groups the data by Gender and Product line, and then calculates the frequency of each product line for each gender. It then orders the results by gender and frequency 
in descending order.*/

SELECT 
    Gender,
    `Product line`,
    COUNT(*) AS frequency
FROM 
    amazondata2
GROUP BY 
    Gender, `Product line`
ORDER BY 
    Gender, frequency DESC;
    
-- 14.Calculate the average rating for each product line.
/* 
This query calculates the average rating for each product line by using the AVG() function on the Rating column and grouping the results by the Product line.
*/
SELECT
    `Product line`,
    AVG(`Rating`) AS average_rating
FROM
    amazondata2
GROUP BY
    `Product line`;
    
-- 15. Count the sales occurrences for each time of day on every weekday.
/* This query calculates the sales occurrences for each combination of dayname and timeofday. It groups the results by dayname and timeofday, and then orders the results
 first by dayname and then by timeofday in the order of Morning,
 Afternoon, and Evening.*/
SELECT
    dayname,
    timeofday,
    COUNT(*) AS sales_occurrences
FROM
    amazondata2
GROUP BY
    dayname,
    timeofday
ORDER BY
    dayname,
    CASE
        WHEN timeofday = 'Morning' THEN 1
        WHEN timeofday = 'Afternoon' THEN 2
        WHEN timeofday = 'Evening' THEN 3
    END; 
 
 -- 16. Identify the customer type contributing the highest revenue.
 /* This query calculates the total revenue for each customer type by summing up the Total column. It then groups the results by Customer type, orders them in descending order 
 based on total revenue, and selects only the first row using the LIMIT 1 clause, which corresponds to the customer type contributing the highest revenue. 
 */
 SELECT
    `Customer type`,
    SUM(`Total`) AS total_revenue
FROM
    amazondata2
GROUP BY
    `Customer type`
ORDER BY
    total_revenue DESC
LIMIT 1;

-- 17. Determine the city with the highest VAT percentage.
/* This query calculates the VAT percentage for each city by dividing the total VAT by the total sales (Total) for each city and then multiplying by 100 to get the percentage.
 It then groups the results by City, orders them in descending order based on the VAT percentage, and selects only the first row using the LIMIT 1 clause, which corresponds to the
 city with the highest VAT percentage.
*/

SELECT
    City,
    (SUM(`Tax 5%`) / SUM(Total)) * 100 AS vat_percentage
FROM
    amazondata2
GROUP BY
    City
ORDER BY
    vat_percentage DESC
LIMIT 1;

 
-- 18. Identify the customer type with the highest VAT payments.
/* This query calculates the total VAT payments for each customer type by summing up the Tax 5% column. It then groups the results by Customer type,
 orders them in descending order based on total VAT payments, and selects only the first row using the LIMIT 1 clause, which corresponds to the customer
 type with the highestVAT payments.
*/

SELECT
    `Customer type`,
    SUM(`Tax 5%`) AS total_vat_payments
FROM
    amazondata2
GROUP BY
    `Customer type`
ORDER BY
    total_vat_payments DESC
LIMIT 1;

-- 19. What is the count of distinct customer types in the dataset?
/* 
This query counts the number of distinct values in the Customer type column of the amazondata2 table using the COUNT() function with the DISTINCT keyword.
*/

SELECT 
    COUNT(DISTINCT `Customer type`) AS distinct_customer_types_count
FROM
    amazondata2;
    
-- 20. What is the count of distinct payment methods in the dataset?
/* This query counts the number of distinct values in the Payment column of the amazondata2 table using the COUNT() function with the DISTINCT keyword.*/

SELECT COUNT(DISTINCT `Payment`) AS distinct_payment_methods_count
FROM amazondata2;

-- 21. Which customer type occurs most frequently?
/* 
This query counts the occurrences of each customer type in the dataset using the COUNT() function, groups the results by Customer type, orders them in descending 
order based on frequency, and selects only the first row using the LIMIT 1 clause, which corresponds to the customer
 type that occurs most frequently.
*/

SELECT `Customer type`, COUNT(*) AS frequency
FROM amazondata2
GROUP BY `Customer type`
ORDER BY frequency DESC
LIMIT 1;

-- 22. Identify the customer type with the highest purchase frequency.
/* This query counts the occurrences of each customer type in the dataset using the COUNT() function, groups the results by Customer type, orders them in descending
 order based on purchase frequency, and selects only the first row using the LIMIT 1 clause, which corresponds to the customer type with the highest
 purchase frequency.*/
 
 SELECT 
    `Customer type`,
    COUNT(*) AS purchase_frequency
FROM 
    amazondata2
GROUP BY 
    `Customer type`
ORDER BY 
    purchase_frequency DESC
LIMIT 1;

-- 23. Determine the predominant gender among customers.
/* 
This query counts the occurrences of each gender in the dataset using the COUNT() function, groups the results by Gender, orders them in descending order based on the number
 of customers, and selects only the first row using the LIMIT 1 clause, which corresponds to the predominant
 gender among customers.
*/

SELECT 
    Gender,
    COUNT(*) AS customer_count
FROM 
    amazondata2
GROUP BY 
    Gender
ORDER BY 
    customer_count DESC
LIMIT 1;

-- 24. Examine the distribution of genders within each branch.
/*
This query counts the occurrences of each gender within each branch using the COUNT() function, grouping the results by both Branch and Gender. It then orders the results
 first by Branch and then by the number of customers in descending 
order for each branch.
*/

SELECT 
    Branch,
    Gender,
    COUNT(*) AS gender_count
FROM 
    amazondata2
GROUP BY 
    Branch, Gender
ORDER BY 
    Branch, gender_count DESC;


-- 25. Identify the time of day when customers provide the most ratings.
/* 
This query counts the occurrences of ratings provided by customers for each time of day (morning, afternoon, evening), using the COUNT() function. It then groups the results
 by timeofday, orders them in descending order based on the number of ratings, and selects only the first row using the LIMIT 1 clause, which corresponds to the time
 of day with the most ratings.
*/

SELECT 
    timeofday,
    COUNT(*) AS rating_count
FROM 
    amazondata2
GROUP BY 
    timeofday
ORDER BY 
    rating_count DESC
LIMIT 1;


-- 26. Determine the time of day with the highest customer ratings for each branch.
/* 
This query counts the occurrences of customer ratings for each time of day (morning, afternoon, evening) within each branch, using the COUNT() function. It then groups the results by both Branch and timeofday, and orders them first by Branch and then by the number of ratings in descending
 order for each branch.
*/

SELECT 
    Branch,
    timeofday,
    COUNT(*) AS rating_count
FROM 
    amazondata2
GROUP BY 
    Branch, timeofday
ORDER BY 
    Branch, rating_count DESC;

-- 27. Identify the day of the week with the highest average ratings.
/*
This query calculates the average rating for each day of the week using the AVG() function and groups the results by dayname. It then orders the results in descending
 order based on the average rating and selects only the first row using the LIMIT 1 clause, which corresponds to the day of the week with
 the highest average ratings.
*/

SELECT 
    dayname,
    AVG(rating) AS average_rating
FROM 
    amazondata2
GROUP BY 
    dayname
ORDER BY 
    average_rating DESC
LIMIT 1;


-- 28. Determine the day of the week with the highest average ratings for each branch.
/* This query calculates the average rating for each day of the week within each branch using the AVG() function and groups the results by both
 Branch and dayname. It then orders the results first by Branch and then by the average rating in descending order for each branch.*/
 
 SELECT 
    Branch,
    dayname,
    AVG(rating) AS average_rating
FROM 
    amazondata2
GROUP BY 
    Branch, dayname
ORDER BY 
    Branch, average_rating DESC;
 
