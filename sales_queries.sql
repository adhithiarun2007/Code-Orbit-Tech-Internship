/*
Task 4: SQL Business Insights
Dataset: fact_sales.csv and dimension CSV files

This script uses standard SQL where practical and is written for PostgreSQL.
No results are invented: execute each query after importing the CSV files to
obtain results from the actual dataset.

==========================================================================
1. CREATE TABLES
==========================================================================
Run this section once. If your CSV contains blank values, import them as NULL.
*/

CREATE TABLE dim_products (
	Product_ID   VARCHAR(50) PRIMARY KEY,
	Product_Name VARCHAR(200) NOT NULL,
	Category     VARCHAR(100),
	Sub_Category VARCHAR(100)
);

CREATE TABLE dim_stores (
	Store_ID   VARCHAR(50) PRIMARY KEY,
	Region     VARCHAR(100),
	Store_Type VARCHAR(100)
);

CREATE TABLE dim_customers (
	Customer_ID   VARCHAR(50) PRIMARY KEY,
	Customer_Name VARCHAR(200),
	Gender        VARCHAR(30),
	City          VARCHAR(100),
	Segment       VARCHAR(100)
);

CREATE TABLE dim_dates (
	Date_ID    DATE PRIMARY KEY,
	Year       INTEGER,
	Month      INTEGER,
	Month_Name VARCHAR(20),
	Quarter    VARCHAR(10)
);

CREATE TABLE fact_sales (
	Order_ID    VARCHAR(50),
	Order_Date  DATE NOT NULL,
	Customer_ID VARCHAR(50),
	Product_ID  VARCHAR(50),
	Store_ID    VARCHAR(50),
	Quantity    INTEGER,
	Unit_Price  DECIMAL(12,2),
	Sales       DECIMAL(14,2),
	Cost        DECIMAL(14,2),
	Profit      DECIMAL(14,2),
	FOREIGN KEY (Customer_ID) REFERENCES dim_customers(Customer_ID),
	FOREIGN KEY (Product_ID) REFERENCES dim_products(Product_ID),
	FOREIGN KEY (Store_ID) REFERENCES dim_stores(Store_ID),
	FOREIGN KEY (Order_Date) REFERENCES dim_dates(Date_ID)
);

/*
2. LOAD CSV FILES (PostgreSQL)

Use absolute paths appropriate to your computer. In pgAdmin, use the table's
Import/Export option instead, selecting CSV, header = Yes, and delimiter = ,.
Load dimensions before fact_sales because of the foreign keys.

COPY dim_products FROM 'C:/path/dim_products.csv' WITH (FORMAT csv, HEADER true);
COPY dim_stores FROM 'C:/path/dim_stores.csv' WITH (FORMAT csv, HEADER true);
COPY dim_customers FROM 'C:/path/dim_customers.csv' WITH (FORMAT csv, HEADER true);
COPY dim_dates FROM 'C:/path/dim_dates.csv' WITH (FORMAT csv, HEADER true);
COPY fact_sales FROM 'C:/path/fact_sales.csv' WITH (FORMAT csv, HEADER true);

If Date_ID is not stored as a DATE, change Date_ID and Order_Date to the same
type, or transform the date during import. For SQLite, create equivalent
tables, import each CSV with .import --csv --skip 1 file.csv table_name, and
omit/adjust FOREIGN KEY constraints if the SQLite version requires it.
*/

/* Optional validation: these counts should match the source CSV row counts. */
SELECT 'products' AS table_name, COUNT(*) AS row_count FROM dim_products
UNION ALL SELECT 'stores', COUNT(*) FROM dim_stores
UNION ALL SELECT 'customers', COUNT(*) FROM dim_customers
UNION ALL SELECT 'dates', COUNT(*) FROM dim_dates
UNION ALL SELECT 'sales', COUNT(*) FROM fact_sales;

/*
==========================================================================
3. BUSINESS QUESTIONS

For every query, run the SQL and inspect the returned value(s). The comments
state what it measures and the business insight to look for.
==========================================================================
*/

-- 1. Total Sales
-- Does: Adds sales for every transaction.
-- Insight: Overall revenue baseline for evaluating business performance.
SELECT SUM(Sales) AS total_sales
FROM fact_sales;

-- 2. Total Profit
-- Does: Adds recorded profit for every transaction.
-- Insight: Shows the total value retained after the recorded costs.
SELECT SUM(Profit) AS total_profit
FROM fact_sales;

-- 3. Total Quantity Sold
-- Does: Counts all units sold.
-- Insight: Indicates sales volume independently of product price.
SELECT SUM(Quantity) AS total_quantity_sold
FROM fact_sales;

-- 4. Average Order Value
-- Does: Sums each order once, then averages order totals (not line rows).
-- Insight: Measures typical customer order value and supports basket-growth plans.
SELECT AVG(order_total) AS average_order_value
FROM (
	SELECT Order_ID, SUM(Sales) AS order_total
	FROM fact_sales
	GROUP BY Order_ID
) AS orders;

-- 5. Sales by Category
-- Does: Joins products and groups revenue by category.
-- Insight: Reveals categories that contribute most to revenue.
SELECT p.Category, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_products p ON p.Product_ID = f.Product_ID
GROUP BY p.Category
ORDER BY total_sales DESC;

-- 6. Sales by Region
-- Does: Joins stores and groups revenue by region.
-- Insight: Identifies strong markets and regions needing attention.
SELECT s.Region, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_stores s ON s.Store_ID = f.Store_ID
GROUP BY s.Region
ORDER BY total_sales DESC;

-- 7. Top 5 Products by Sales
-- Does: Totals sales per product and returns the five highest.
-- Insight: Identifies products to prioritize for stock and marketing.
SELECT p.Product_ID, p.Product_Name, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_products p ON p.Product_ID = f.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY total_sales DESC
FETCH FIRST 5 ROWS ONLY;

-- 8. Monthly Sales Trend (standard SQL using the date dimension)
-- Does: Groups revenue by calendar year and month number.
-- Insight: Shows seasonality and whether sales are increasing or declining.
SELECT d.Year, d.Month, d.Month_Name, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_dates d ON d.Date_ID = f.Order_Date
GROUP BY d.Year, d.Month, d.Month_Name
ORDER BY d.Year, d.Month;

-- 9. Most Profitable Category
-- Does: Ranks categories by total profit and returns the highest one.
-- Insight: Identifies the category contributing the greatest profit.
SELECT p.Category, SUM(f.Profit) AS total_profit
FROM fact_sales f
JOIN dim_products p ON p.Product_ID = f.Product_ID
GROUP BY p.Category
ORDER BY total_profit DESC
FETCH FIRST 1 ROW ONLY;

-- 10. Most Profitable Region
-- Does: Ranks regions by total profit and returns the highest one.
-- Insight: Helps focus expansion and operational investment.
SELECT s.Region, SUM(f.Profit) AS total_profit
FROM fact_sales f
JOIN dim_stores s ON s.Store_ID = f.Store_ID
GROUP BY s.Region
ORDER BY total_profit DESC
FETCH FIRST 1 ROW ONLY;

-- 11. Top Customers by Sales (top 10; change 10 if required)
-- Does: Totals revenue for each customer and ranks customers.
-- Insight: Supports retention, loyalty, and targeted high-value campaigns.
SELECT c.Customer_ID, c.Customer_Name, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_customers c ON c.Customer_ID = f.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
ORDER BY total_sales DESC
FETCH FIRST 10 ROWS ONLY;

-- 12. Sales by Store Type
-- Does: Groups revenue by store format/type.
-- Insight: Compares store formats and informs channel investment decisions.
SELECT s.Store_Type, SUM(f.Sales) AS total_sales
FROM fact_sales f
JOIN dim_stores s ON s.Store_ID = f.Store_ID
GROUP BY s.Store_Type
ORDER BY total_sales DESC;

/*
==========================================================================
4. BUSINESS INSIGHTS & RECOMMENDATIONS
==========================================================================

After running the queries, replace the bracketed notes below with the actual
returned values; do not estimate them.

1. Total sales, profit, and quantity establish the dataset's performance base.
2. Compare category and product rankings: promote strong sellers and review
   weak categories for pricing, assortment, or marketing opportunities.
3. Use the regional and store-type results to direct inventory and investment.
4. Use the monthly trend to plan staffing, stock, and seasonal promotions.
5. Retain top customers with loyalty offers while investigating ways to raise
   average order value through bundles or cross-selling.
6. Compare sales with profit, not sales alone, before making decisions; a
   high-sales group may have low margins.
*/
