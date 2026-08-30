SELECT * FROM orders
SELECT * FROM customers
SELECT * FROM returns
SELECT * FROM products

--Q1. Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

--Q2. Total Quantity Sold
SELECT SUM(quantity) AS total_quantity
FROM orders;

--Q3. Average Quantity per Order
SELECT ROUND(AVG(quantity), 2) AS avg_quantity
FROM orders;

--Q4. Maximum Quantity
SELECT MAX(quantity) AS max_quantity
FROM orders;

--Q5. Minimum Quantity
SELECT MIN(quantity) AS min_quantity
FROM orders;

--Q6. Total Discount
SELECT SUM(discount) AS total_discount
FROM orders;

--Q7. Average Discount
SELECT ROUND(AVG(discount), 2) AS avg_discount
FROM orders;

--Q8. Payment Method-wise Orders
SELECT payment_method, COUNT(*) AS total_orders
FROM orders
GROUP BY payment_method;

--Q9. Region-wise Orders
SELECT region, COUNT(*) AS total_orders
FROM orders
GROUP BY region;

--Q10. Region-wise Total Quantity
SELECT region, SUM(quantity) AS total_quantity
FROM orders
GROUP BY region;

--GROUP BY + Business Analysis

--Q1. Region-wise Average Discount
SELECT region,
       ROUND(AVG(discount), 2) AS avg_discount
FROM orders
GROUP BY region;

--Q2. Payment Method-wise Total Quantity
SELECT payment_method,
       SUM(quantity) AS total_quantity
FROM orders
GROUP BY payment_method;

--Q3. Region-wise Average Quantity
SELECT region,
       ROUND(AVG(quantity), 2) AS avg_quantity
FROM orders
GROUP BY region;

--Q4. Monthly Orders
SELECT EXTRACT(MONTH FROM order_date) AS month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY 1
ORDER BY 1;

--Q5. Monthly Quantity Sold
SELECT EXTRACT(MONTH FROM order_date) AS month,
       SUM(quantity) AS total_quantity
FROM orders
GROUP BY 1
ORDER BY 1;

--Q6. Payment Method-wise Average Discount
SELECT payment_method,
       ROUND(AVG(discount), 2) AS avg_discount
FROM orders
GROUP BY payment_method;

--Q7. Region with Highest Quantity
SELECT region,
       SUM(quantity) AS total_quantity
FROM orders
GROUP BY region
ORDER BY total_quantity DESC
LIMIT 1;

--Q8. Region with Lowest Quantity
SELECT region,
       SUM(quantity) AS total_quantity
FROM orders
GROUP BY region
ORDER BY total_quantity ASC
LIMIT 1;

--Q9. Orders Greater Than Average Quantity
SELECT order_id,
       quantity
FROM orders
WHERE quantity > (
    SELECT AVG(quantity)
    FROM orders
);

--Q10. Payment Method with Highest Average Quantity
SELECT payment_method,
       ROUND(AVG(quantity), 2) AS avg_quantity
FROM orders
GROUP BY payment_method
ORDER BY avg_quantity DESC
LIMIT 1;

--JOINs
--Q1. Order + Customer Name
SELECT o.order_id,
       c.customer_name
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

--Q2. Order + Product Name + Category
SELECT o.order_id,
       p.product_name,
       p.category
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

--Q3. Customer-wise Total Orders
SELECT c.customer_id,
       c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

--Q4. Product-wise Total Quantity
SELECT p.product_name,
       SUM(o.quantity) AS total_quantity
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.product_name;

--Q5. Category-wise Total Quantity
SELECT p.category,
       SUM(o.quantity) AS total_quantity
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.category;

--Q6. Customer-wise Total Quantity
SELECT c.customer_name,
       SUM(o.quantity) AS total_quantity
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

--Q7. Top 5 Products by Quantity
SELECT p.product_name,
       SUM(o.quantity) AS total_quantity
FROM products p
JOIN orders o
ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

--Q8. Top 5 Customers by Orders
SELECT c.customer_name,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY total_orders DESC
LIMIT 5;

--Q9. Region + Category-wise Quantity
SELECT o.region,
       p.category,
       SUM(o.quantity) AS total_quantity
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY o.region, p.category;

--Q10. Highest Region + Category Combination
SELECT o.region,
       p.category,
       SUM(o.quantity) AS total_quantity
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY o.region, p.category
ORDER BY total_quantity DESC
LIMIT 1;

--Sales & Profit Analysis

-- 1 Total Sales nikalo.
SELECT 
    SUM(p.price * o.quantity * (1 - o.discount)) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

-- 2 Total Cost nikalo.
SELECT 
    SUM(o.quantity * p.cost) AS total_cost
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

-- 3 Total Profit nikalo
SELECT 
    SUM(
        (p.price * o.quantity * (1 - o.discount))
        - (p.cost * o.quantity)
    ) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id;

-- 4 Product-wise Total Sales nikalo.
SELECT 
    p.product_name,
    SUM(p.price * o.quantity * (1 - o.discount)) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name;

-- 5 Category-wise Total Sales nikalo.
SELECT 
    p.category,
    SUM(p.price * o.quantity * (1 - o.discount)) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category;

-- 6 Category-wise Total Profit nikalo.
SELECT 
    p.category,
    SUM(
        (p.price * o.quantity * (1 - o.discount))
        - (p.cost * o.quantity)
    ) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category;

-- 7 Top 5 Products by Sales nikalo.
SELECT 
    p.product_name,
    SUM(p.price * o.quantity * (1 - o.discount)) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 5;

-- 8 Top 5 Products by Profit nikalo.
SELECT 
    p.product_name,
    SUM(
        (p.price * o.quantity * (1 - o.discount))
        - (p.cost * o.quantity)
    ) AS total_profit
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC
LIMIT 5;

-- 9 Region-wise Total Sales nikalo
SELECT 
    o.region,
    SUM(p.price * o.quantity * (1 - o.discount)) AS total_sales
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY o.region
ORDER BY total_sales DESC;


-- 10 Har category ka Profit Margin % nikalo.
SELECT 
    p.category,

    SUM(
        p.price * o.quantity * (1 - o.discount)
    ) AS total_sales,

    SUM(
        (p.price * o.quantity * (1 - o.discount))
        - (p.cost * o.quantity)
    ) AS total_profit,

    ROUND(
        (
            SUM(
                (p.price * o.quantity * (1 - o.discount))
                - (p.cost * o.quantity)
            ) * 100.0
            /
            NULLIF(
                SUM(p.price * o.quantity * (1 - o.discount)),
                0
            )
        ),
        2
    ) AS profit_margin
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY profit_margin DESC;


--Advance SQL

--Har product ka total profit nikalo aur profit ke basis par overall rank do.
SELECT p.product_name,
SUM((o.quantity * p.price*(1-o.discount))-(o.quantity * p.cost)) as Total_Profit,
DENSE_RANK() OVER(ORDER BY SUM((o.quantity * p.price * (1-o.discount))-(o.quantity*p.cost))DESC) AS profit_rank
FROM orders o
JOIN products p 
ON o.product_id=p.product_id
GROUP BY p.product_id,p.product_name
ORDER BY profit_rank ASC;

-- 2 Har category ke andar products ko profit ke basis par rank karo.
DENSE_RANK() OVER (
    PARTITION BY p.category
    ORDER BY SUM(
        (o.quantity * p.price * (1 - o.discount))
        - (o.quantity * p.cost)
    ) DESC
)

-- 3 Har category ke Top 3 products by profit nikalo.
WITH RankedProducts AS (
    SELECT 
        p.category,
        p.product_name,
        -- 1. Net Profit calculate kiya
        SUM((o.quantity * p.price * (1 - o.discount)) - (o.quantity * p.cost)) AS total_profit,
        -- 2. Category ke andar ranking di
        DENSE_RANK() OVER (
            PARTITION BY p.category 
            ORDER BY SUM((o.quantity * p.price * (1 - o.discount)) - (o.quantity * p.cost)) DESC
        ) AS category_rank
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
-- 3. Baher waali query mein sirf Top 3 products ko filter kiya
SELECT 
    category,
    product_name,
    total_profit,
    category_rank
FROM RankedProducts
WHERE category_rank <= 3
ORDER BY category ASC, category_rank ASC;

-- 4 Har category ke Top 3 products by sales nikalo.
WITH Ranked_Sale AS(
SELECT p.category,p.product_name,
SUM(o.quantity*p.price*(1-o.discount))as Total_Sale,
DENSE_RANK()OVER(PARTITION BY p.category ORDER BY SUM(o.quantity*p.price*(1-o.discount))DESC
)AS category_rank
FROM orders o
JOIN products p
ON o.product_id=p.product_id
GROUP BY 1,2
)
SELECT category,product_name,Total_Sale,category_rank
FROM Ranked_Sale
WHERE category_rank<=3
ORDER BY category ASC,category_rank ASC;

-- 5 Har customer ka total purchase value nikalo aur customer ranking do.
SELECT c.customer_id,c.customer_name,
SUM(o.quantity*p.price*(1-o.discount))as total_purchase,
DENSE_RANK()OVER(ORDER BY SUM(o.quantity*p.price*(1-o.discount))DESC)AS customer_rank
FROM orders o
JOIN products p
ON o.product_id=p.product_id
JOIN customers c 
ON o.customer_id=c.customer_id
GROUP BY 1,2
ORDER BY customer_rank ASC;

-- 6 Har region ke andar customers ko total purchase value ke basis par rank karo.
SELECT 
    o.region,
    c.customer_id,
    c.customer_name,
    -- 1. Net purchase value (discount ke baad)
    SUM(o.quantity * p.price * (1 - o.discount)) AS total_purchase_value,
    -- 2. Har region ke andar customers ki ranking
    DENSE_RANK() OVER (
        PARTITION BY o.region 
        ORDER BY SUM(o.quantity * p.price * (1 - o.discount)) DESC
    ) AS region_customer_rank
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.region, c.customer_id, c.customer_name
ORDER BY o.region ASC, region_customer_rank ASC;


-- 7 Har region ka Top 3 customer nikalo based on purchase value.
WITH RankedRegionalCustomers AS (
    SELECT 
        o.region,
        c.customer_id,
        c.customer_name,
        -- 1. Har customer ka net purchase value calculate kiya
        SUM(o.quantity * p.price * (1 - o.discount)) AS total_purchase_value,
        -- 2. Region ke andar purchase value ke basis par rank diya
        DENSE_RANK() OVER (
            PARTITION BY o.region 
            ORDER BY SUM(o.quantity * p.price * (1 - o.discount)) DESC
        ) AS region_customer_rank
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.region, c.customer_id, c.customer_name
)
-- 3. Sirf wahi customers select kiye jinki rank 1, 2, ya 3 hai
SELECT 
    region,
    customer_id,
    customer_name,
    total_purchase_value,
    region_customer_rank
FROM RankedRegionalCustomers
WHERE region_customer_rank <= 3
ORDER BY region ASC, region_customer_rank ASC;

--8 Har month ki total sales nikalo aur monthly sales ranking do.
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
    SUM(o.quantity * p.price * (1 - o.discount)) AS total_sales,
    DENSE_RANK() OVER (
        ORDER BY SUM(o.quantity * p.price * (1 - o.discount)) DESC
    ) AS monthly_sales_rank
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY monthly_sales_rank;

--9 Monthly sales ka running total nikalo.
WITH MonthlySales AS (
    SELECT 
        TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
        SUM(o.quantity * p.price * (1 - o.discount)) AS total_sales
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)

SELECT 
    sales_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY sales_month
    ) AS running_total_sales
FROM MonthlySales
ORDER BY sales_month;

--10 Har category mein sabse profitable product kaunsa hai?
WITH CategoryProfitRank AS (
    SELECT 
        p.category,
        p.product_name,
        -- 1. Net Profit calculate kiya
        SUM((o.quantity * p.price * (1 - o.discount)) - (o.quantity * p.cost)) AS total_profit,
        -- 2. Har category ke andar products ko profit ke basis par rank kiya
        DENSE_RANK() OVER (
            PARTITION BY p.category 
            ORDER BY SUM((o.quantity * p.price * (1 - o.discount)) - (o.quantity * p.cost)) DESC
        ) AS product_rank
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
-- 3. Sirf wahi products select kiye jo apni category mein Rank 1 par hain
SELECT 
    category,
    product_name,
    total_profit
FROM CategoryProfitRank
WHERE product_rank = 1
ORDER BY total_profit DESC;


--Returns Analysis
--Q1 — Total Returned Orders
SELECT * FROM returns;

SELECT COUNT(*) AS Total_Return 
FROM returns;


--Q2 — Return Rate %
SELECT 
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS return_rate
FROM orders o
LEFT JOIN returns r
    ON o.order_id = r.order_id;


--Q3 _Most Returned Products — Top 5
SELECT p.product_name,COUNT(DISTINCT r.order_id)as returned_orderd
FROM returns r
JOIN orders o
ON r.order_id=o.order_id
JOIN products p
ON o.product_id=p.product_id
GROUP BY p.product_id,p.product_name
ORDER BY returned_orderd DESC LIMIT 5;

-- Q4 . Most Common Return Reason
SELECT return_reason,COUNT(*) AS Total_Return
FROM returns
GROUP BY return_reason
ORDER BY Total_Return DESC LIMIT 1;

--Q5 Category-wise Returns
SELECT 
    p.category,
    COUNT(DISTINCT r.order_id) AS total_returns
FROM returns r
JOIN orders o
    ON r.order_id = o.order_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_returns DESC;

-- Q6 Region-wise Returns
SELECT o.region,COUNT(DISTINCT r.order_id)AS Total_return
FROM orders o
JOIN returns r
ON o.order_id=r.order_id
GROUP BY 1
ORDER BY 1 DESC;

-- Q7 Return Rate by Category
WITH CategoryOrders AS (
    SELECT 
        p.category,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.category
),

CategoryReturns AS (
    SELECT 
        p.category,
        COUNT(DISTINCT r.order_id) AS returned_orders
    FROM returns r
    JOIN orders o
        ON r.order_id = o.order_id
    JOIN products p
        ON o.product_id = p.product_id
    GROUP BY p.category
)

SELECT 
    co.category,
    co.total_orders,
    COALESCE(cr.returned_orders, 0) AS returned_orders,
    ROUND(
        COALESCE(cr.returned_orders, 0) * 100.0
        / NULLIF(co.total_orders, 0),
        2
    ) AS return_rate
FROM CategoryOrders co
LEFT JOIN CategoryReturns cr
    ON co.category = cr.category
ORDER BY return_rate DESC;

--Q8 Customers with Most Returns — Top 5
SELECT c.customer_id,c.customer_name,
COUNT(DISTINCT r.order_id)as Total_return
FROM returns r
JOIN orders o
ON r.order_id=o.order_id
JOIN customers c
ON o.customer_id=c.customer_id
GROUP BY 1,2
ORDER BY 3 DESC LIMIT 5;