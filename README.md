# Brazilian E-Commerce 360° Analytics Platform

An end-to-end data analytics platform built on the Olist Brazilian E-Commerce dataset,
covering the complete pipeline from raw data ingestion to machine learning models,
SQL business intelligence, and an interactive Power BI dashboard.

---

## Project Overview

| Detail | Info |
|--------|------|
| Dataset | Olist Brazilian E-Commerce (Kaggle) |
| Records | 119,143 transactions · 9 source tables · 39 features |
| Tools | Python · MySQL · Scikit-learn · Power BI |
| Models | RFM Segmentation · K-Means · Random Forest · Linear Regression |
| Dashboard | 5-page interactive Power BI with live MySQL connection |

## Power BI Dashboard

Due to GitHub file size limitations, the PBIX file is hosted externally.
🔗 [Download the Power BI Dashboard](https://drive.google.com/file/d/1mupg0Moe8_S1QSrbr-4AEgAXrbgB_hXc/view?usp=sharing)

## Tech Stack

- **Python** — Pandas, Scikit-learn, Matplotlib, Seaborn, SQLAlchemy, PyMySQL
- **MySQL** — ecommerce_db with 13 tables including ML output tables
- **Power BI** — 5-page dashboard with 10 DAX measures and live MySQL integration
- **Jupyter Notebook** — Full reproducible pipeline

---

## Pipeline Phases

| Phase | Description |
|-------|-------------|
| Phase 1 | Environment setup · MySQL connection · 9 CSV tables loaded |
| Phase 2 | Data cleaning · missing value treatment · master table (119,143 x 39) |
| Phase 3 | Exploratory Data Analysis — revenue, orders, customers, correlations |
| Phase 4 | RFM segmentation — 7 segments across 96,096 customers |
| Phase 5 | K-Means clustering — Elbow Method — optimal K=4 |
| Phase 6 | Random Forest churn prediction — ROC-AUC: 0.73 |
| Phase 7 | Linear Regression revenue forecasting — 6-month projection |
| Phase 8 | 15 SQL business intelligence queries |
| Phase 9 | 5-page Power BI interactive dashboard |

---

## Machine Learning Models

### RFM Customer Segmentation
- Scored 96,096 customers on Recency, Frequency, Monetary
- Classified into 7 segments: Champion · Loyal · Recent · High Spender · Potential · At Risk · Lost
- High Spender segment (15.7% of base) drives 33% of total revenue

### K-Means Clustering
- Applied on standardized RFM matrix
- Elbow Method identified optimal K=4
- VIP cluster isolated with R$26,932 average spend — 133x above customer average

### Random Forest Churn Prediction
- Churn defined as 180-day inactivity
- ROC-AUC: 0.73 · Accuracy: 73% · Churned Recall: 87%
- Top features: Monetary Value · Avg Price · Avg Delivery Days

### Linear Regression Revenue Forecasting
- Trained on monthly aggregated revenue with Time Index feature
- 6-month projection: R$8.66M (+43.58% growth)
- Consistent R$40,051 monthly increment

---

## Key Business Findings

- 96.88% of customers are one-time buyers — critical retention crisis
- R$13.8M revenue at risk from 67,642 high-churn customers
- Only 54.19% on-time delivery rate — direct driver of customer dissatisfaction
- Top revenue seller carries only 3.4/5 review score — volume masking quality failure
- Sao Paulo generates R$7.73M — 39% of total revenue concentration risk
- Credit card dominates at 73.67% with average 3.6 installments per transaction

---

## Recommendations

- Deploy automated churn intervention campaigns targeting the 71% inactive customer base
- Assign dedicated retention management for High Spender segment to protect R$6.57M revenue
- Reduce average delivery from 12 to 7 days — directly improves reviews and reduces churn
- Enforce minimum 4.0 review score threshold for top-tier seller qualification
- Expand seller network in RJ, RS, PR states to reduce São Paulo revenue dependency
- Integrate November Black Friday seasonality into annual inventory and marketing planning

---

## SQL Highlights

15 queries covering:
- Executive KPI dashboard
- Window functions (LAG, RANK, OVER PARTITION)
- Cross-table JOINs between transactional and ML output tables
- Churn-integrated revenue at risk calculation
- Customer loyalty classification (one-time · repeat · loyal)

---

## Power BI Dashboard

| Page | Title | Key Visuals |
|------|-------|-------------|
| 1 | Executive Summary | KPI Cards · Monthly Trend · Top States |
| 2 | Sales & Revenue Analysis | Category Bar · Payment Donut · Order Status |
| 3 | Customer Segmentation & Churn | Segment Donut · Churn Risk Bar · Revenue Bar |
| 4 | Product & Operational Performance | Delivery Donut · Seller Cities · Payment Bar |
| 5 | Revenue Forecast & Growth | Area Chart · Historical Line · Projection Table |

---

## Dataset Source

[Olist Brazilian E-Commerce Dataset — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## Author

**J. Charan Reddy**  
Data Analytics Portfolio Project · March 2026
