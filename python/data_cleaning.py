from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "WA_Fn-UseC_-Telco-Customer-Churn.csv"
OUTPUT = ROOT / "data" / "telco_customer_churn_clean.csv"

df = pd.read_csv(INPUT)
df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce")
df["SeniorCitizen"] = df["SeniorCitizen"].map({0: "No", 1: "Yes"})
df = df.drop_duplicates(subset=["customerID"], keep="first")
df = df.rename(columns={
    "customerID":"customer_id", "SeniorCitizen":"senior_citizen",
    "PhoneService":"phone_service", "MultipleLines":"multiple_lines",
    "InternetService":"internet_service", "OnlineSecurity":"online_security",
    "OnlineBackup":"online_backup", "DeviceProtection":"device_protection",
    "TechSupport":"tech_support", "StreamingTV":"streaming_tv",
    "StreamingMovies":"streaming_movies", "PaperlessBilling":"paperless_billing",
    "PaymentMethod":"payment_method", "MonthlyCharges":"monthly_charges",
    "TotalCharges":"total_charges"
})
df.columns = [c.strip().lower() for c in df.columns]
df.to_csv(OUTPUT, index=False)
print(f"Saved {len(df):,} rows to {OUTPUT}")
print("Missing values:\n", df.isna().sum()[df.isna().sum() > 0])
