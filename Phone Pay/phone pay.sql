DROP TABLE IF EXISTS transactions;


CREATE TABLE users (
    user_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    age INTEGER,
    join_date DATE
);

CREATE TABLE transactions (
    transaction_id VARCHAR(30) PRIMARY KEY,
    amount NUMERIC(12,2),
    user_id VARCHAR(20),
    service VARCHAR(50),
    service_type VARCHAR(100),
    payment_status VARCHAR(50),
    reason VARCHAR(100),
    date DATE,
    transaction_result VARCHAR(20),
    month DATE,
    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

SELECT *
FROM transactions
LIMIT 5;


SELECT *
FROM users
LIMIT 5;


--Total Transactions, Total Transaction Value, Average Transaction Value 
SELECT COUNT(*) AS Total_transaction,
	SUM(amount)AS Total_transaction_value,
	ROUND(AVG(amount),2)as Average_transaction_value
FROM transactions;

--Success vs Failure

SELECT transaction_result,
	COUNT(*)AS Total_transaction,
	ROUND(
		COUNT(*)*100.0/SUM(COUNT(*)) OVER(),
		2
	)AS percentage
FROM transactions
GROUP BY transaction_result
ORDER BY Total_transaction DESC;

--Kaunsi service sabse zyada transactions aur transaction value generate karti hai?
SELECT service,
	COUNT(*)AS Total_transaction,
	SUM(amount)as Total_amount
FROM transactions
GROUP BY service
ORDER BY 2 DESC;

--Kaunsi service ka failure rate sabse zyada hai?
SELECT service,
	COUNT(*) as Total_transaction,
	SUM(
		CASE
			WHEN transaction_result='Failed' THEN 1
			ELSE 0
			END
	)AS failed_transaction,
	ROUND(
			SUM(
				CASE
					WHEN transaction_result='Failed' THEN 1
					ELSE 0
					END
			)*100.0/COUNT(*),
			2
	)AS failure_rate_percentage
FROM transactions
GROUP BY service
ORDER BY failure_rate_percentage DESC;

--Failure Reason Analysis
SELECT reason,
		COUNT(*)AS failed_transaction,
		ROUND(
			COUNT(*)*100.0/SUM(COUNT(*)) over(),
			2
		)as failure_share_percentage
FROM transactions
WHERE transaction_result='Failed'
GROUP BY reason
ORDER BY failed_transaction DESC;


--Top 10 Customers by Transaction Value
SELECT u.user_id,u.name,u.age,
		COUNT(t.transaction_id)as Total_transaction,
		SUM(t.amount)AS Total_transaction_value,
		ROUND(AVG(t.amount),2)as Average_amount
FROM users u
JOIN transactions t
ON u.user_id=t.user_id
GROUP BY 1,2,3
ORDER BY 5 DESC
LIMIT 10;

--Top Active Customers
SELECT u.user_id,u.name,u.age,
	COUNT(t.transaction_id)as Total_transaction,
	SUM(t.amount)as Total_transaction_value,
	ROUND(AVG(t.amount),2)as average_transaction
FROM users u
JOIN transactions t
ON u.user_id=t.user_id
GROUP BY 1,2,3
ORDER BY 4 DESC,5 DESC
LIMIT 10;

--Har service ke andar top customers kaun hain?

WITH customer_service_sale AS(
SELECT t.service,u.user_id,u.name,
		SUM(t.amount)as total_transaction_value
FROM transactions t
JOIN users u
	ON t.user_id=u.user_id
GROUP BY 1,2,3
),

ranked_customer as(
SELECT service,user_id,name,
total_transaction_value,
RANK()OVER(
	PARTITION BY service
	ORDER BY total_transaction_value DESC
)as customer_rank
FROM customer_service_sale
)

SELECT * 
FROM ranked_customer
WHERE customer_rank <=3
ORDER BY 1,customer_rank;

--Monthly Service Performance
SELECT month,
	service,
	COUNT(*)AS Total_transaction,
	SUM(amount)as total_transaction_value,
	ROUND(AVG(amount),2)AS average_transaction_value
FROM transactions
GROUP BY month,service
ORDER BY month,total_transaction_value DESC;


--Har month ka highest-value service kaunsa tha?
WITH monthly_service AS (
    SELECT
        month,
        service,
        COUNT(*) AS total_transactions,
        SUM(amount) AS total_transaction_value
    FROM transactions
    GROUP BY month, service
),

ranked_services AS (
    SELECT
        month,
        service,
        total_transactions,
        total_transaction_value,
        ROW_NUMBER() OVER (
            PARTITION BY month
            ORDER BY total_transaction_value DESC
        ) AS service_rank
    FROM monthly_service
)

SELECT
    month,
    service,
    total_transactions,
    ROUND(total_transaction_value, 2) AS total_transaction_value
FROM ranked_services
WHERE service_rank = 1
ORDER BY month;

--Repeat Customer Analysis

SELECT
    transaction_count,
    COUNT(*) AS customers
FROM (
    SELECT
        user_id,
        COUNT(*) AS transaction_count
    FROM transactions
    GROUP BY user_id
) AS customer_transactions
GROUP BY transaction_count
ORDER BY transaction_count;

--One-time vs Repeat Customers

SELECT
    CASE
        WHEN transaction_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM (
    SELECT
        user_id,
        COUNT(*) AS transaction_count
    FROM transactions
    GROUP BY user_id
) AS customer_transactions
GROUP BY
    CASE
        WHEN transaction_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY customers DESC;

--Repeat customers kitni value generate karte hain?

WITH customer_transactions AS (
    SELECT
        user_id,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY user_id
)

SELECT
    CASE
        WHEN transaction_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customers,
    SUM(transaction_count) AS total_transactions,
    ROUND(SUM(total_amount), 2) AS total_transaction_value,
    ROUND(AVG(total_amount), 2) AS avg_customer_value
FROM customer_transactions
GROUP BY
    CASE
        WHEN transaction_count = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY total_transaction_value DESC;

--repeat customers ki actual business value
WITH customer_transaction AS(
SELECT user_id,
		COUNT(*)AS transaction_count,
		SUM(amount)as total_amount
	FROM transactions
GROUP BY 1
)
SELECT
	CASE
		WHEN transaction_count=1 THEN 'One-Time Customer'
		ELSE 'Repeat Customer'
	END AS customer_type,
	COUNT(*)AS customer,
	SUM(transaction_count)as total_transaction,
	ROUND(SUM(total_amount),2)as total_transaction_value,
	ROUND(AVG(total_amount),2)as avg_transaction_value
FROM customer_transaction
GROUP BY 
	CASE
		WHEN transaction_count=1 THEN 'One-Time Customer'
		ELSE 'Repeat Customer'
	END
ORDER BY total_transaction_value DESC;
	
--Monthly Transaction Trend
SELECT 
	month,
	COUNT(*)AS total_transactions,
	ROUND(SUM(amount),2)as total_transaction_value,
	ROUND(AVG(amount),2)as avg_transaction_value
FROM transactions
GROUP BY 1
ORDER BY 3 DESC;

--Monthly Success Rate
SELECT 
	month,
	COUNT(*)AS total_tranactions,
	SUM(
		CASE
			WHEN transaction_result='Failed' THEN 1
			ELSE 0
			END
	)as failed_transaction,
ROUND(
	SUM(
		CASE
			WHEN transaction_result='Failed' THEN 1
			ELSE 0
			END
	)*100.0/COUNT(*),
	2
)AS failure_rate_percentage
FROM transactions
GROUP BY month
ORDER BY month;

--Age Group Performance
SELECT 
	CASE
		WHEN u.age <= 25 THEN '18-25'
		WHEN u.age <= 35 THEN '26-35'
		WHEN u.age <=45 THEN '36-45'
		WHEN u.age <= 55 THEN '46-55'
		ELSE '56-60'
	END AS age_group,
	COUNT(DISTINCT u.user_id)as customers,
	COUNT(t.transaction_id)as total_transactions,
	ROUND(SUM(t.amount),2)as total_transaction_value,
	ROUND(AVG(t.amount),2)as average_transaction_value
FROM users u
JOIN transactions t
ON u.user_id=t.user_id
GROUP BY 
	CASE
		WHEN u.age <= 25 THEN '18-25'
		WHEN u.age <= 35 THEN '26-35'
		WHEN u.age <=45 THEN '36-45'
		WHEN u.age <= 55 THEN '46-55'
		ELSE '56-60'
	END 
ORDER BY total_transaction_value DESC;

--Service Type Analysis
SELECT service_type,
	COUNT(*)AS total_transaction,
	ROUND(SUM(amount),2)as total_transaction_value,
	ROUND(AVG(amount),2)as avg_transaction_value
FROM transactions
GROUP BY 1
ORDER BY total_transaction_value DESC;

--Service Type + Failure Rate
SELECT
    service_type,
    COUNT(*) AS total_transactions,
    SUM(
        CASE
            WHEN transaction_result = 'Failed' THEN 1
            ELSE 0
        END
    ) AS failed_transactions,
    ROUND(
        SUM(
            CASE
                WHEN transaction_result = 'Failed' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS failure_rate_percentage
FROM transactions
GROUP BY service_type
ORDER BY failure_rate_percentage DESC;







CREATE OR REPLACE VIEW vw_phonepe_dashboard AS
SELECT
    t.transaction_id,
    t.amount,
    t.user_id,
    u.name,
    u.age,

    CASE
        WHEN u.age <= 25 THEN '18-25'
        WHEN u.age <= 35 THEN '26-35'
        WHEN u.age <= 45 THEN '36-45'
        WHEN u.age <= 55 THEN '46-55'
        ELSE '56-60'
    END AS age_group,

    u.join_date,
    t.service,
    t.service_type,
    t.payment_status,
    t.reason,
    t.date AS transaction_date,
    t.month,
    t.transaction_result

FROM transactions t
LEFT JOIN users u
    ON t.user_id = u.user_id;


SELECT *
FROM vw_phonepe_dashboard
LIMIT 5;