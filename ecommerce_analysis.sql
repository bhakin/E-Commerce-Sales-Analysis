CREATE DATABASE ecommerce;

-- Creating tables with variables 
CREATE TABLE online_retail (
    invoiceno VARCHAR(10),
    stockcode VARCHAR(20),
    description TEXT,
    quantity INT,
    invoicedate TIMESTAMP,
    unitprice DECIMAL(10, 2),
    customerid VARCHAR(10),
    country VARCHAR(50)
);

-- Adding the data to the table
COPY online_retail
FROM '/Users/bhakinphanakesiri/Desktop/online_retail.csv'
DELIMITER ','
CSV HEADER
QUOTE '"';

-- Checking the first 10 rows of the csv file
SELECT * FROM online_retail LIMIT 10;

-- Remove all of the invoices with C since it was cancelled
DELETE FROM online_retail
WHERE invoiceno LIKE 'C%';

-- Remove rows with negative quantities or prices
DELETE FROM online_retail
WHERE quantity <= 0 OR unitprice <= 0;

-- Add a TotalPrice Column
ALTER TABLE online_retail
ADD COLUMN totalprice DECIMAL(10,2);
UPDATE online_retail
SET totalprice = quantity * unitprice;

-- Checking the 10 rows of the cleaned data
SELECT * FROM online_retail LIMIT 10;

-- Calulcating the Total Revenue
SELECT ROUND(SUM(totalprice),2) AS total_revenue
FROM online_retail;

-- Calculating the number of unique customers
SELECT COUNT(DISTINCT customerid) AS unique_customers
FROM online_retail;

-- Calculating the total number of orders
SELECT COUNT(DISTINCT invoiceno) AS total_orders
FROM online_retail;

-- Calculating the Average Order Value (AOV)
SELECT ROUND(SUM(totalprice) / COUNT(DISTINCT invoiceno),2) AS avg_order_value
FROM online_retail;

-- Calculating monthly revenue trend
SELECT 
    date_trunc('MONTH', invoicedate) AS month,
    ROUND(SUM(totalprice), 2) AS monthly_revenue
FROM online_retail
GROUP BY month
ORDER BY month;

-- Calculating top 10 products by Revenue
SELECT
    description,
    ROUND(SUM(totalprice),2) AS product_revenue
FROM online_retail
GROUP BY description
ORDER BY product_revenue DESC
LIMIT 10;

-- Calculating revenue by country
a

-- Calculating number of orders per country
SELECT
    country,
    COUNT(DISTINCT invoiceno) AS total_orders
FROM online_retail
GROUP BY country
ORDER BY total_orders DESC;

-- Calculating total quantity sold by product
SELECT
    description, 
    SUM(quantity) AS total_quantity_sold
FROM online_retail
GROUP BY description
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Calculating the best sales day of the week
SELECT
    TO_CHAR(invoicedate, 'Day') AS day_of_week,
    ROUND(SUM(totalprice),2) AS total_revenue
FROM online_retail
GROUP BY day_of_week
ORDER BY total_revenue DESC;

-- Calculating average order size (how much unit per order) (???????)
SELECT
    ROUND(SUM(quantity)::decimal / COUNT(DISTINCT invoiceno),2) AS avg_order_size
FROM online_retail;

-- Calculating top 10 countries by Average Order Value
SELECT
    country,
    ROUND(SUM(totalprice) / COUNT(DISTINCT invoiceno), 2) AS avg_order_value
FROM online_retail
GROUP BY country
ORDER BY avg_order_value DESC
LIMIT 10;

-- Calculating Revenue Growth by each month
WITh monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', invoicedate) AS month,
        SUM(totalprice) AS revenue
    FROM online_retail
    GROUP BY month
    ORDER BY month
)
SELECT
    month,
    revenue,
    ROUND(((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month)) * 100, 2) AS growth_percentage
FROM monthly_revenue;

-- Calculating what percentage of total revenue comes from the top 10 products
WITH total_revenue AS (
    SELECT SUM(totalprice) AS overall_revenue
    FROM online_retail
),
top_10_revenue AS(
    SELECT SUM(totalprice) AS top_revenue
    FROM online_retail
    WHERE description IN (
        SELECT description
        FROM online_retail
        GROUP BY description
        ORDER BY SUM(totalprice) DESC
        LIMIT 10
    )
)
SELECT
    ROUND((top_revenue / overall_revenue) * 100, 2) AS top_10_revenue_percent
FROM total_revenue, top_10_revenue;

