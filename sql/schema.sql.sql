/*Project: Customer Churn & Revenue Risk Analysis
Author: Paras Grover
Description: Database schema definition for churn analysis project.*/


-- Create Database
CREATE DATABASE IF NOT EXISTS digital_wallet_analytics;
USE digital_wallet_analytics;

-- Drop table if exists (for clean re-run)
DROP TABLE IF EXISTS transactions;

-- Create Transactions Table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    transaction_date DATE,
    amount DECIMAL(10,2),
    failure_group VARCHAR(50),
    purchase_frequency INT,
    risk_segment VARCHAR(20)
);