# Power BI DAX and Dashboard Plan

## DAX measures
```DAX
Total Customers = DISTINCTCOUNT(telco_customer_churn[customer_id])
Churned Customers = CALCULATE([Total Customers], telco_customer_churn[churn] = "Yes")
Retained Customers = CALCULATE([Total Customers], telco_customer_churn[churn] = "No")
Churn Rate = DIVIDE([Churned Customers], [Total Customers], 0)
Retention Rate = DIVIDE([Retained Customers], [Total Customers], 0)
Monthly Charges = SUM(telco_customer_churn[monthly_charges])
Churned Monthly Charge Exposure = CALCULATE([Monthly Charges], telco_customer_churn[churn] = "Yes")
Average Monthly Charges = AVERAGE(telco_customer_churn[monthly_charges])
Average Tenure = AVERAGE(telco_customer_churn[tenure])
Average Tenure - Churned = CALCULATE([Average Tenure], telco_customer_churn[churn] = "Yes")
Average Tenure - Retained = CALCULATE([Average Tenure], telco_customer_churn[churn] = "No")
```

## Page 1 — Executive Overview
KPI cards: total customers, churned customers, churn rate, monthly charges, churned monthly-charge exposure.
Visuals: churn vs retained, churn rate by contract, churn rate by internet service.
Slicers: contract, internet service, payment method, gender.

## Page 2 — Customer Risk Analysis
Visuals: churn by tenure band, charge segment, tech support and online security.
Matrix: contract x payment method with customer count and churn rate.
Table: churned customers with high monthly charges and short tenure.

## Page 3 — Revenue & Retention
Visuals: monthly charges by churn status, monthly-charge exposure by contract,
average charges and tenure by churn status, segment-level churn.

## Modeling caution
This is one row per customer with no event dates or monthly history. Do not create fake monthly trends or call tenure buckets true calendar cohorts.
