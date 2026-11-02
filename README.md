# Customer Churn & Retention Analytics

End-to-end telecom customer analytics project using Python, PostgreSQL and Power BI.

## Business objective
Identify customer segments associated with higher churn and quantify the monthly-charge exposure represented by customers marked as churned. Turn the analysis into retention recommendations.

## Dataset
IBM Telco Customer Churn: 7,043 customers and 21 source fields.
Source: https://www.kaggle.com/datasets/blastchar/telco-customer-churn

This is a static customer snapshot, not a transaction-level or monthly time-series dataset.

## Project structure
- `data/`: original and cleaned CSV files
- `notebooks/`: exploratory analysis notebook
- `python/`: repeatable data-cleaning script
- `sql/`: PostgreSQL table schema and 30 business queries
- `powerbi/`: DAX measures and dashboard plan
- `reports/`: baseline metrics and initial findings

## Setup
```bash
pip install -r requirements.txt
python python/data_cleaning.py
```
The original CSV must be placed in `data/WA_Fn-UseC_-Telco-Customer-Churn.csv`.

## PostgreSQL
1. Create a database named `customer_churn`.
2. Execute the SQL file to create the table.
3. Import the cleaned CSV into `telco_customer_churn` using pgAdmin Import/Export (header enabled).
4. Run the numbered queries.

## Power BI
Import the cleaned CSV or connect to PostgreSQL. Create the DAX measures and three report pages specified in `powerbi/dax_measures_and_dashboard_spec.md`.

## Data quality decisions
`TotalCharges` is converted to numeric. Blank values are preserved as NULL (11 records in this dataset), rather than being invented or silently replaced. Duplicate customer IDs are removed if found. `SeniorCitizen` is made readable as Yes/No.

## Limitations
No cancellation dates or monthly snapshots are included. Therefore, do not claim monthly churn trends or true cohort retention curves. Churned monthly-charge exposure is not necessarily realized revenue loss. Observational segment differences do not prove causation.

## Next enhancements
Add dated monthly snapshots, cancellation dates, support ticket history and campaign contact history. Test retention interventions through controlled experiments.

## Author
Add your name, LinkedIn and GitHub profile before publishing.
