# Initial Business Findings

Computed from the uploaded dataset (after numeric conversion of TotalCharges).

- Customer records: **7,043**
- Churned customers: **1,869**
- Retained customers: **5,174**
- Overall churn rate: **26.54%**
- Sum of monthly charges in this snapshot: **$456,116.60**
- Churned customers' monthly-charge exposure: **$139,130.85**
- Average tenure among churned customers: **17.98 months**
- Average tenure among retained customers: **37.57 months**
- Missing `total_charges`: **11** (kept as NULL).

## Churn rate by contract
contract
Month-to-month    42.71
One year          11.27
Two year           2.83

## Churn rate by payment method
payment_method
Electronic check             45.29
Mailed check                 19.11
Bank transfer (automatic)    16.71
Credit card (automatic)      15.24

## Churn rate by internet service
internet_service
Fiber optic    41.89
DSL            18.96
No              7.40

## Interpretation limitations
Churned monthly-charge exposure is a snapshot measure, not verified realized revenue loss. Segment differences are associations, not proof of causation. The dataset has no cancellation date or monthly snapshots, so it cannot support calendar-month churn trends or true cohort retention curves.
