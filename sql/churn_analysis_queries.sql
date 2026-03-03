/*
Project: Customer Churn & Revenue Risk Analysis
Author: Paras Grover
Description: Core analytical queries supporting Power BI dashboard insights.
*/

USE digital_wallet_analytics;

------------------------------------------------------------
-- Total Customers
------------------------------------------------------------
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM transactions;


------------------------------------------------------------
-- Total Revenue
------------------------------------------------------------
SELECT 
    SUM(amount) AS total_revenue
FROM transactions;


------------------------------------------------------------
-- Revenue by Risk Segment
------------------------------------------------------------
SELECT 
    risk_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(amount) AS segment_revenue
FROM transactions
GROUP BY risk_segment
ORDER BY segment_revenue DESC;


------------------------------------------------------------
-- Revenue Contribution % by Risk Segment
------------------------------------------------------------
WITH revenue_cte AS (
    SELECT 
        risk_segment,
        SUM(amount) AS segment_revenue
    FROM transactions
    GROUP BY risk_segment
),
total_revenue_cte AS (
    SELECT SUM(amount) AS total_revenue
    FROM transactions
)

SELECT 
    r.risk_segment,
    r.segment_revenue,
    ROUND((r.segment_revenue / t.total_revenue) * 100, 2) 
        AS revenue_percentage
FROM revenue_cte r
CROSS JOIN total_revenue_cte t
ORDER BY revenue_percentage DESC;


------------------------------------------------------------
-- High Risk Revenue (Revenue at Risk)
------------------------------------------------------------
SELECT 
    SUM(amount) AS high_risk_revenue
FROM transactions
WHERE risk_segment = 'High Risk';


------------------------------------------------------------
-- Churn Rate Proxy (High Risk %)
------------------------------------------------------------
SELECT 
    ROUND(
        COUNT(CASE WHEN risk_segment = 'High Risk' THEN 1 END) 
        * 100.0 / COUNT(*),
    2) AS churn_rate_percentage
FROM transactions;


------------------------------------------------------------
-- Purchase Frequency vs Customers
------------------------------------------------------------
SELECT 
    purchase_frequency,
    COUNT(DISTINCT customer_id) AS total_customers
FROM transactions
GROUP BY purchase_frequency
ORDER BY purchase_frequency;


------------------------------------------------------------
-- Failure Group Impact Analysis
------------------------------------------------------------
SELECT 
    failure_group,
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_revenue
FROM transactions
GROUP BY failure_group
ORDER BY total_transactions DESC;


------------------------------------------------------------
-- Customer Lifetime Revenue (CLV Basic)
------------------------------------------------------------
SELECT 
    customer_id,
    COUNT(transaction_id) AS total_transactions,
    SUM(amount) AS lifetime_revenue
FROM transactions
GROUP BY customer_id
ORDER BY lifetime_revenue DESC;


------------------------------------------------------------
-- Monthly Cohort Revenue Trend
------------------------------------------------------------
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(amount) AS monthly_revenue
FROM transactions
GROUP BY cohort_month
ORDER BY cohort_month;


------------------------------------------------------------
-- Monthly Revenue Growth %
------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM transactions
    GROUP BY month
)

SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / LAG(revenue) OVER (ORDER BY month) * 100,
    2) AS revenue_growth_percentage
FROM monthly_revenue;


------------------------------------------------------------
-- High Risk – High Revenue Customers (Priority List)
------------------------------------------------------------
SELECT 
    customer_id,
    SUM(amount) AS total_revenue
FROM transactions
WHERE risk_segment = 'High Risk'
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_rev)
    FROM (
        SELECT SUM(amount) AS total_rev
        FROM transactions
        GROUP BY customer_id
    ) avg_table
)
ORDER BY total_revenue DESC;