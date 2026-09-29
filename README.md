# E-Commerce Sales, Customer & Churn Analytics

End-to-end data analytics project covering data cleaning, exploratory
analysis, customer segmentation, SQL data modelling and an interactive
Power BI dashboard for an e-commerce business.

## Business Problem
Analyze sales performance, product profitability and customer behaviour
to identify revenue growth opportunities and quantify revenue at risk
from customer churn.

## Tech Stack
Python (Pandas, NumPy, Matplotlib) | SQL Server (SSMS) | Power BI | DAX

## Dataset
5 related tables — Customers (3,000), Products (300), Orders (9,921
after cleaning), Returns (962), Customer Activity (30,000)

## Project Workflow
1. **Data Cleaning & Validation** — missing values, duplicates, data
   types, invalid values, categorical consistency, referential
   integrity, business-rule validation, outliers ([.ipynb](notebooks))
2. **Exploratory Data Analysis** — sales, customer and product trends
    ([.ipynb](notebooks))
3. **RFM & Churn Analysis** — customer segmentation, churn definition,
   risk scoring  ([.ipynb](notebooks))
4. **SQL Server** — tables, keys, views, CTEs, window functions, stored
   procedures ([.sql](sql))
5. **Power BI Data Model** — star schema, relationships, date table
6. **DAX** — 29 measures across sales, profitability, customer,
   time-intelligence, growth and risk
7. **Power BI Dashboard** — 4-page interactive report
   ([.pbix file](powerbi/))

## Key Findings
- Total Revenue: ₹8.63 Cr | Gross Margin: 27.7%
- Churn Rate: 48.94% | Revenue at Risk: ₹3.80 Cr (44.1% of revenue)
- 441 high-value ("Champion") customers identified for win-back
- 4 products found selling at a loss due to a pricing error (~₹4.1 Lakh)

## Dashboard Screenshots

### Page 1: Executive Overview
![Executive Overview](powerbi/screenshots/page1_executive_overview.png)

### Page 2: Sales Analysis
![Sales Analysis](powerbi/screenshots/page2_sales_analysis.png)

### Page 3: Customer Analytics
![Customer Analytics](powerbi/screenshots/page3_customer_analytics.png)

### Page 4: Product & Profitability
![Product & Profitability](powerbi/screenshots/page4_product_profitability.png)

## Folder Structure
```
├── data/
│   ├── raw/               original dataset
│   └── cleaned/           cleaned data + RFM analysis output
├── notebooks/             Python cleaning, EDA, RFM/churn analysis
├── sql/                   SQL Server scripts
├── powerbi/               .pbix file + dashboard screenshots
```
