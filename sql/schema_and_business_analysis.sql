-- Create table, then import the cleaned CSV through pgAdmin Import/Export.
CREATE TABLE IF NOT EXISTS telco_customer_churn (
 customer_id VARCHAR(20) PRIMARY KEY, gender VARCHAR(10), senior_citizen VARCHAR(3),
 partner VARCHAR(3), dependents VARCHAR(3), tenure INTEGER, phone_service VARCHAR(3),
 multiple_lines VARCHAR(30), internet_service VARCHAR(30), online_security VARCHAR(30),
 online_backup VARCHAR(30), device_protection VARCHAR(30), tech_support VARCHAR(30),
 streaming_tv VARCHAR(30), streaming_movies VARCHAR(30), contract VARCHAR(30),
 paperless_billing VARCHAR(3), payment_method VARCHAR(40),
 monthly_charges NUMERIC(10,2), total_charges NUMERIC(12,2),
 churn VARCHAR(3) CHECK (churn IN ('Yes','No'))
);
select * from telco_customer_churn limit 10;
SELECT COUNT(*)
FROM telco_customer_churn;
SELECT
    churn,
    COUNT(*) AS total_customers
FROM telco_customer_churn
GROUP BY churn;

select round(((count(*)::numeric/(select count(churn) from telco_customer_churn))*100),2) from telco_customer_churn where churn='Yes';
-- 01 Overall churn rate
SELECT COUNT(*) FILTER (WHERE churn='Yes') AS churned,
 COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn;
select contract,count(*) as customers,round((count(*) filter(where churn='Yes')::numeric/count(*))*100,2) as churn_rate_pct from telco_customer_churn group by contract
-- 02 Churn by contract
SELECT contract, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY contract ORDER BY churn_rate_pct DESC;

-- 03 Churn by payment method
SELECT payment_method, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY payment_method ORDER BY churn_rate_pct DESC;

-- 04 Churn by internet service
SELECT internet_service, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY internet_service ORDER BY churn_rate_pct DESC;

-- 05 Churn by senior citizen status
SELECT senior_citizen, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY senior_citizen;

-- 06 Churn by gender
SELECT gender, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY gender;

-- 07 Churn by partner and dependents
SELECT partner, dependents, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY 1,2 ORDER BY churn_rate_pct DESC;

-- 08 Churn by tenure segment
SELECT CASE WHEN tenure<=12 THEN '0-12 months'
 WHEN tenure<=24 THEN '13-24 months' WHEN tenure<=48 THEN '25-48 months'
 ELSE '49+ months' END AS tenure_band,
 COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY 1 ORDER BY MIN(tenure);

-- 09 Average tenure by churn status
SELECT churn, ROUND(AVG(tenure),2) AS avg_tenure_months
FROM telco_customer_churn GROUP BY churn;

-- 10 Average monthly charges by churn status
SELECT churn, ROUND(AVG(monthly_charges),2) AS avg_monthly_charges
FROM telco_customer_churn GROUP BY churn;

-- 11 Churned customer monthly charge exposure (not realized loss)
SELECT ROUND(SUM(monthly_charges),2) AS monthly_charge_exposure
FROM telco_customer_churn WHERE churn='Yes';

-- 12 Churn by tech support
SELECT tech_support, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY tech_support ORDER BY churn_rate_pct DESC;

-- 13 Churn by online security
SELECT online_security, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY online_security ORDER BY churn_rate_pct DESC;

-- 14 Churn by paperless billing
SELECT paperless_billing, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY paperless_billing;

-- 15 Churn by phone service
SELECT phone_service, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY phone_service;

-- 16 Contract x tenure analysis
SELECT contract,
 CASE WHEN tenure<=12 THEN '0-12' WHEN tenure<=24 THEN '13-24'
 WHEN tenure<=48 THEN '25-48' ELSE '49+' END AS tenure_band,
 COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY 1,2 ORDER BY 1,2;

-- 17 CTE + window function: rank contract types by churn rate
WITH contract_kpis AS (
 SELECT contract, COUNT(*) AS customers,
 COUNT(*) FILTER (WHERE churn='Yes')::numeric/COUNT(*) AS churn_rate
 FROM telco_customer_churn GROUP BY contract
)
SELECT *, DENSE_RANK() OVER(ORDER BY churn_rate DESC) AS risk_rank
FROM contract_kpis;

-- 18 Rank customers by monthly charges
SELECT customer_id, monthly_charges,
 DENSE_RANK() OVER(ORDER BY monthly_charges DESC) AS charge_rank
FROM telco_customer_churn ORDER BY charge_rank LIMIT 25;

-- 19 Churned monthly-charge exposure by contract
SELECT contract, COUNT(*) AS churned_customers,
 ROUND(SUM(monthly_charges),2) AS monthly_exposure
FROM telco_customer_churn WHERE churn='Yes'
GROUP BY contract ORDER BY monthly_exposure DESC;

-- 20 Churn by contract and payment method
SELECT contract, payment_method, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY 1,2 ORDER BY 1,2;

-- 21 High monthly charge customers (75th percentile and above)
SELECT customer_id, contract, tenure, monthly_charges, churn
FROM telco_customer_churn
WHERE monthly_charges >= (SELECT PERCENTILE_CONT(0.75)
 WITHIN GROUP(ORDER BY monthly_charges) FROM telco_customer_churn)
ORDER BY monthly_charges DESC;

-- 22 Reusable customer segmentation view
CREATE OR REPLACE VIEW customer_churn_segments AS
SELECT *,
 CASE WHEN tenure<=12 THEN 'New' WHEN tenure<=48 THEN 'Established'
 ELSE 'Long-term' END AS tenure_segment,
 CASE WHEN monthly_charges>=80 THEN 'High'
 WHEN monthly_charges>=50 THEN 'Medium' ELSE 'Low' END AS charge_segment
FROM telco_customer_churn;

-- 23 Churn by tenure and charge segments
SELECT tenure_segment, charge_segment, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER(WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM customer_churn_segments GROUP BY 1,2 ORDER BY churn_rate_pct DESC;

-- 24 High-charge early-tenure customers who churned
SELECT customer_id, tenure, contract, monthly_charges, payment_method
FROM telco_customer_churn
WHERE churn='Yes' AND tenure<=12 AND monthly_charges>=70
ORDER BY monthly_charges DESC;

-- 25 Missing-value audit
SELECT COUNT(*) FILTER(WHERE total_charges IS NULL) AS missing_total_charges,
 COUNT(*) FILTER(WHERE monthly_charges IS NULL) AS missing_monthly_charges
FROM telco_customer_churn;

-- 26 Churn by add-on service count
WITH service_counts AS (
 SELECT customer_id, churn,
 (CASE WHEN online_security='Yes' THEN 1 ELSE 0 END +
  CASE WHEN online_backup='Yes' THEN 1 ELSE 0 END +
  CASE WHEN device_protection='Yes' THEN 1 ELSE 0 END +
  CASE WHEN tech_support='Yes' THEN 1 ELSE 0 END +
  CASE WHEN streaming_tv='Yes' THEN 1 ELSE 0 END +
  CASE WHEN streaming_movies='Yes' THEN 1 ELSE 0 END) AS addon_count
 FROM telco_customer_churn
)
SELECT addon_count, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER(WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM service_counts GROUP BY addon_count ORDER BY addon_count;

-- 27 Churn by online backup
SELECT online_backup, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY online_backup;

-- 28 Churn by device protection
SELECT device_protection, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY device_protection;

-- 29 Churn by streaming TV
SELECT streaming_tv, COUNT(*) AS customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE churn='Yes')/COUNT(*),2) AS churn_rate_pct
FROM telco_customer_churn GROUP BY streaming_tv;

-- 30 Overall profile by churn status
SELECT churn, COUNT(*) AS customers, ROUND(AVG(tenure),2) AS avg_tenure,
 ROUND(AVG(monthly_charges),2) AS avg_monthly_charges,
 ROUND(SUM(monthly_charges),2) AS monthly_charge_sum
FROM telco_customer_churn GROUP BY churn;
