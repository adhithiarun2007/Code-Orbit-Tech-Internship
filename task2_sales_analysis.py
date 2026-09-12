import pandas as pd
import os

# -----------------------------
# 1. Load the datasets
# -----------------------------

data_path = "data"

fact_sales = pd.read_csv(os.path.join(data_path, "fact_sales.csv"))
products = pd.read_csv(os.path.join(data_path, "dim_products.csv"))
stores = pd.read_csv(os.path.join(data_path, "dim_stores.csv"))
customers = pd.read_csv(os.path.join(data_path, "dim_customers.csv"))
dates = pd.read_csv(os.path.join(data_path, "dim_dates.csv"))

print("All datasets loaded successfully!")

# -----------------------------
# 2. Clean the sales data
# -----------------------------

fact_sales = fact_sales.drop_duplicates()

fact_sales["Order_Date"] = pd.to_datetime(
    fact_sales["Order_Date"],
    errors="coerce"
)

fact_sales = fact_sales.dropna(subset=["Sales"])

# -----------------------------
# 3. Merge the datasets
# -----------------------------

sales_data = fact_sales.merge(
    products,
    on="Product_ID",
    how="left"
)

sales_data = sales_data.merge(
    stores,
    on="Store_ID",
    how="left"
)

# -----------------------------
# 4. Overall Sales Analysis
# -----------------------------

total_sales = sales_data["Sales"].sum()

total_profit = sales_data["Profit"].sum()

total_quantity = sales_data["Quantity"].sum()

average_order_value = sales_data.groupby(
    "Order_ID"
)["Sales"].sum().mean()

print("\n========== SALES SUMMARY ==========")
print(f"Total Sales: {total_sales:,.2f}")
print(f"Total Profit: {total_profit:,.2f}")
print(f"Total Quantity Sold: {total_quantity:,.0f}")
print(f"Average Order Value: {average_order_value:,.2f}")

# -----------------------------
# 5. Sales by Category
# -----------------------------

sales_by_category = (
    sales_data.groupby("Category")["Sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== SALES BY CATEGORY ==========")
print(sales_by_category)

# -----------------------------
# 6. Sales by Region
# -----------------------------

sales_by_region = (
    sales_data.groupby("Region")["Sales"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== SALES BY REGION ==========")
print(sales_by_region)

# -----------------------------
# 7. Top 5 Products
# -----------------------------

top_products = (
    sales_data.groupby("Product_Name")["Sales"]
    .sum()
    .sort_values(ascending=False)
    .head(5)
)

print("\n========== TOP 5 PRODUCTS ==========")
print(top_products)

# -----------------------------
# 8. Monthly Sales
# -----------------------------

sales_data["Month"] = sales_data["Order_Date"].dt.to_period("M")

monthly_sales = (
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
    .sum()
)

print("\n========== MONTHLY SALES ==========")
data_path = BASE_DIR / "data"

# -----------------------------
# 9. Save the results
# -----------------------------

output_path = "output"

os.makedirs(output_path, exist_ok=True)

sales_by_category.to_csv(
    os.path.join(output_path, "sales_by_category.csv")
)
output_path = BASE_DIR / "output"
sales_by_region.to_csv(
    os.path.join(output_path, "sales_by_region.csv")
)

    output_path / "sales_by_category.csv"
    os.path.join(output_path, "top_products.csv")
)

    output_path / "sales_by_region.csv"
    os.path.join(output_path, "monthly_sales.csv")
)

    output_path / "top_products.csv"
print("Task 2 analysis completed!")
print("Results have been saved in the output folder.")
print("===================================")
    output_path / "monthly_sales.csv"