/*
Project: Customer Churn & Revenue Risk Analysis
Author: Paras Grover
Description: Data cleaning and preprocessing queries.
*/

USE digital_wallet_analytics;

-- Replace NULL failure group
UPDATE transactions
SET failure_group = 'No Failure'
WHERE failure_group IS NULL;

-- Trim unwanted spaces in risk segment
UPDATE transactions
SET risk_segment = TRIM(risk_segment);

-- Remove negative or invalid revenue
DELETE FROM transactions
WHERE amount < 0;

-- Ensure date format is correct
ALTER TABLE transactions
MODIFY transaction_date DATE;

-- Check for duplicate transactions
SELECT transaction_id, COUNT(*)
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;