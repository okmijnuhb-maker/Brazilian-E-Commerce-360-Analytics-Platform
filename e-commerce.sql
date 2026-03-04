CREATE DATABASE ecommerce_db;

-- 1.EXECUTIVE KPI OVERVIEW
SELECT
    COUNT(DISTINCT `Order Id`) AS total_orders,
    COUNT(DISTINCT `Customer Unique Id`) AS total_customers,
    ROUND(SUM(`Payment Value`),2) AS total_revenue,
    ROUND(AVG(`Payment Value`),2) AS avg_order_value
FROM master_table
WHERE `Order Status` = 'delivered';
-- ------------------------------------------------------------------------------------------------
-- 2️.MONTHLY REVENUE GROWTH (WINDOW FUNCTION)
WITH monthly_data AS (
    SELECT
        `Order Year`,
        `Order Month`,
        COALESCE(SUM(`Payment Value`),0) AS monthly_revenue
    FROM master_table
    WHERE `Order Status` = 'delivered'
    GROUP BY `Order Year`, `Order Month`
)

SELECT
    `Order Year`,
    `Order Month`,
    monthly_revenue,
    ROUND(
        (monthly_revenue -
         LAG(monthly_revenue) OVER (ORDER BY `Order Year`,`Order Month`)
        )
        /
        NULLIF(LAG(monthly_revenue) OVER (ORDER BY `Order Year`,`Order Month`),0)
        * 100
    ,2) AS growth_percent
FROM monthly_data
ORDER BY `Order Year`, `Order Month`;
-- -------------------------------------------------------------------------------------------------
--  3: TOP 5 REVENUE CONTRIBUTING STATES
WITH state_revenue AS (
    SELECT
        `Customer State`,
        COALESCE(SUM(`Payment Value`),0) AS total_revenue
    FROM master_table
    WHERE `Order Status` = 'delivered'
    GROUP BY `Customer State`
)

SELECT
    `Customer State`,
    ROUND(total_revenue,2) AS total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS state_rank
FROM state_revenue
ORDER BY total_revenue DESC
LIMIT 5;
-- --------------------------------------------------------------------------------------------------
-- STEP 4: SEGMENT REVENUE CONTRIBUTION
WITH segment_data AS (
    SELECT
        Segment,
        COUNT(*) AS total_customers,
        SUM(Monetary) AS total_revenue
    FROM rfm_segments
    GROUP BY Segment
)

SELECT
    Segment,
    total_customers,
    ROUND(total_revenue,2) AS total_revenue,
    ROUND(
        total_revenue /
        (SELECT SUM(Monetary) FROM rfm_segments) * 100
    ,2) AS revenue_share_percent
FROM segment_data
ORDER BY total_revenue DESC;
-- ----------------------------------------------------------------------------------------------------
-- 5: REVENUE AT RISK (CHURN INTEGRATION)
WITH high_risk_customers AS (
    SELECT
        c.`Customer Unique Id`,
        c.`Churn Probability`,
        r.Monetary
    FROM churn_predictions c
    JOIN rfm_segments r
        ON c.`Customer Unique Id` = r.`Customer Unique Id`
    WHERE c.`Churn Probability` > 0.7
)

SELECT
    COUNT(*) AS high_risk_customers,
    ROUND(SUM(Monetary),2) AS revenue_at_risk,
    ROUND(AVG(`Churn Probability`) * 100,2) AS avg_churn_risk_percent
FROM high_risk_customers;
-- ---------------------------------------------------------------------------------------------------
-- 6: SEGMENT vs CHURN RISK
SELECT
    r.Segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(c.`Churn Probability`) * 100,2) AS avg_churn_risk_percent,
    ROUND(SUM(r.Monetary),2) AS total_segment_revenue,
    ROUND(
        SUM(CASE WHEN c.`Churn Probability` > 0.7 THEN r.Monetary ELSE 0 END),
    2) AS revenue_at_risk_in_segment
FROM churn_predictions c
JOIN rfm_segments r
    ON c.`Customer Unique Id` = r.`Customer Unique Id`
GROUP BY r.Segment
ORDER BY avg_churn_risk_percent DESC;
-- -----------------------------------------------------------------------------------------------------
-- 7: CLUSTER-LEVEL REVENUE & BEHAVIOR ANALYSIS
SELECT
    `Cluster Label`,
    COUNT(*) AS total_customers,
    ROUND(AVG(Recency),1) AS avmaster_tableg_recency,
    ROUND(AVG(Frequency),2) AS avg_frequency,
    ROUND(AVG(Monetary),2) AS avg_monetary_value,
    ROUND(SUM(Monetary),2) AS total_cluster_revenue
FROM rfm_segments
GROUP BY `Cluster Label`
ORDER BY total_cluster_revenue DESC;
-- -------------------------------------------------------------------------------------------------
-- 8: PAYMENT METHOD & REVENUE ANALYSIS
SELECT
    `Payment Type`,
    COUNT(*) AS total_transactions,
    ROUND(SUM(`Payment Value`),2) AS total_revenue,
    ROUND(AVG(`Payment Value`),2) AS avg_transaction_value,
    ROUND(AVG(`Payment Installments`),1) AS avg_installments
FROM master_table
WHERE `Order Status` = 'delivered'
AND `Payment Type` IS NOT NULL
GROUP BY `Payment Type`
ORDER BY total_revenue DESC;
-- ---------------------------------------------------------------------------------------------------
-- 9: DELIVERY PERFORMANCE vs REVENUE
SELECT
    CASE
        WHEN `Delivery Days` <= 3 THEN 'Fast Delivery (0-3 Days)'
        WHEN `Delivery Days` BETWEEN 4 AND 7 THEN 'Moderate Delivery (4-7 Days)'
        WHEN `Delivery Days` BETWEEN 8 AND 14 THEN 'Slow Delivery (8-14 Days)'
        ELSE 'Very Slow Delivery (15+ Days)'
    END AS delivery_category,
    
    COUNT(DISTINCT `Order Id`) AS total_orders,
    ROUND(SUM(`Payment Value`),2) AS total_revenue,
    ROUND(AVG(`Payment Value`),2) AS avg_order_value,
    ROUND(AVG(`Review Score`),2) AS avg_review_score

FROM master_table
WHERE `Order Status` = 'delivered'
AND `Delivery Days` IS NOT NULL

GROUP BY delivery_category
ORDER BY total_revenue DESC;
-- ------------------------------------------------------------------------------------------------
--  10: PRODUCT CATEGORY PERFORMANCE
SELECT
    `Product Category Name English` AS product_category,
    COUNT(DISTINCT `Order Id`) AS total_orders,
    ROUND(SUM(`Payment Value`),2) AS total_revenue,
    ROUND(AVG(`Payment Value`),2) AS avg_order_value,
    ROUND(AVG(`Review Score`),2) AS avg_review_score
FROM master_table
WHERE `Order Status` = 'delivered'
AND `Product Category Name English` != 'Uncategorized'
GROUP BY `Product Category Name English`
ORDER BY total_revenue DESC
LIMIT 10;
-- ---------------------------------------------------------------------------------------------
--  11: CURRENT vs FORECAST REVENUE
SELECT
    (SELECT ROUND(SUM(`Payment Value`),2)
     FROM master_table
     WHERE `Order Status` = 'delivered') 
     AS current_total_revenue,

    (SELECT ROUND(SUM(`Forecasted Revenue`),2)
     FROM revenue_forecast) 
     AS projected_future_revenue;
-- ----------------------------------------------------------------------------------------------
-- 12 : -- CUSTOMER LOYALTY ANALYSIS
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-Time Buyer'
        WHEN order_count BETWEEN 2 AND 4 THEN 'Repeat Buyer'
        ELSE 'Loyal Customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS percentage
FROM (
    SELECT `Customer Unique Id`, COUNT(DISTINCT `Order Id`) AS order_count
    FROM master_table
    GROUP BY `Customer Unique Id`
) sub
GROUP BY customer_type;
-- ------------------------------------------------------------------------------------------------
-- 13 :TOP 10 SELLER PERFORMANCE
SELECT
    `Seller Id`,
    `Seller City`,
    `Seller State`,
    COUNT(DISTINCT `Order Id`)    AS total_orders,
    ROUND(SUM(`Payment Value`),2) AS total_revenue,
    ROUND(AVG(`Review Score`),2)  AS avg_review_score
FROM master_table
WHERE `Order Status` = 'delivered'
GROUP BY `Seller Id`, `Seller City`, `Seller State`
ORDER BY total_revenue DESC
LIMIT 10;
-- -------------------------------------------------------------------------------------------------
-- 14: NEW CUSTOMERS ACQUIRED PER MONTH
SELECT
    `Order Year`,
    `Order Month`,
    COUNT(DISTINCT `Customer Unique Id`) AS new_customers,
    ROUND(SUM(`Payment Value`),2)         AS monthly_revenue
FROM master_table
WHERE `Order Status` = 'delivered'
GROUP BY `Order Year`, `Order Month`
ORDER BY `Order Year`, `Order Month`;
-- -------------------------------------------------------------------------------------------------
-- 15: FINAL EXECUTIVE BUSINESS SUMMARY
SELECT
    -- Total Revenue
    (SELECT ROUND(SUM(`Payment Value`),2)
     FROM master_table
     WHERE `Order Status` = 'delivered')
     AS total_revenue,

    -- Total Customers
    (SELECT COUNT(DISTINCT `Customer Unique Id`)
     FROM master_table
     WHERE `Order Status` = 'delivered')
     AS total_customers,

    -- Revenue at Risk
    (SELECT ROUND(SUM(r.Monetary),2)
     FROM churn_predictions c
     JOIN rfm_segments r
       ON c.`Customer Unique Id` = r.`Customer Unique Id`
     WHERE c.`Churn Probability` > 0.7)
     AS revenue_at_risk,

    -- Top Revenue State
    (SELECT `Customer State`
     FROM master_table
     WHERE `Order Status` = 'delivered'
     GROUP BY `Customer State`
     ORDER BY SUM(`Payment Value`) DESC
     LIMIT 1)
     AS top_revenue_state,

    -- Top Revenue Segment
    (SELECT Segment
     FROM rfm_segments
     GROUP BY Segment
     ORDER BY SUM(Monetary) DESC
     LIMIT 1)
     AS top_revenue_segment,

    -- Projected Revenue
    (SELECT ROUND(SUM(`Forecasted Revenue`),2)
     FROM revenue_forecast)
     AS projected_revenue,

    -- ── NEW: One-Time vs Repeat Buyer Ratio ──
    (SELECT ROUND(
        SUM(CASE WHEN order_count = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*), 2)
     FROM (
        SELECT `Customer Unique Id`,
               COUNT(DISTINCT `Order Id`) AS order_count
        FROM master_table
        GROUP BY `Customer Unique Id`
     ) sub)
     AS one_time_buyer_percent,

    -- ── NEW: Top Performing Seller City ──
    (SELECT `Seller City`
     FROM master_table
     WHERE `Order Status` = 'delivered'
     GROUP BY `Seller City`
     ORDER BY SUM(`Payment Value`) DESC
     LIMIT 1)
     AS top_seller_city,

    -- ── NEW: Best Customer Growth Month ──
    (SELECT CONCAT(`Order Year`, '-', LPAD(`Order Month`,2,'0'))
     FROM master_table
     WHERE `Order Status` = 'delivered'
     GROUP BY `Order Year`, `Order Month`
     ORDER BY COUNT(DISTINCT `Customer Unique Id`) DESC
     LIMIT 1)
     AS best_growth_month;
-- -------------------------------------------------------------------------------------------------------
-- NULL COUNT CHECK (master_table)
SELECT
COUNT(*) - COUNT(`Order Id`) AS null_Order_Id,
COUNT(*) - COUNT(`Customer Id`) AS null_Customer_Id,
COUNT(*) - COUNT(`Order Status`) AS null_Order_Status,
COUNT(*) - COUNT(`Order Purchase Timestamp`) AS null_Order_Purchase_Timestamp,
COUNT(*) - COUNT(`Order Approved At`) AS null_Order_Approved_At,
COUNT(*) - COUNT(`Order Delivered Carrier Date`) AS null_Order_Delivered_Carrier_Date,
COUNT(*) - COUNT(`Order Delivered Customer Date`) AS null_Order_Delivered_Customer_Date,
COUNT(*) - COUNT(`Order Estimated Delivery Date`) AS null_Order_Estimated_Delivery_Date,
COUNT(*) - COUNT(`Order Year`) AS null_Order_Year,
COUNT(*) - COUNT(`Order Month`) AS null_Order_Month,
COUNT(*) - COUNT(`Order Day`) AS null_Order_Day,
COUNT(*) - COUNT(`Delivery Days`) AS null_Delivery_Days,
COUNT(*) - COUNT(`Customer Unique Id`) AS null_Customer_Unique_Id,
COUNT(*) - COUNT(`Customer Zip Code Prefix`) AS null_Customer_Zip_Code,
COUNT(*) - COUNT(`Customer City`) AS null_Customer_City,
COUNT(*) - COUNT(`Customer State`) AS null_Customer_State,
COUNT(*) - COUNT(`Order Item Id`) AS null_Order_Item_Id,
COUNT(*) - COUNT(`Product Id`) AS null_Product_Id,
COUNT(*) - COUNT(`Seller Id`) AS null_Seller_Id,
COUNT(*) - COUNT(`Shipping Limit Date`) AS null_Shipping_Limit_Date,
COUNT(*) - COUNT(`Price`) AS null_Price,
COUNT(*) - COUNT(`Freight Value`) AS null_Freight_Value,
COUNT(*) - COUNT(`Product Category Name`) AS null_Product_Category_Name,
COUNT(*) - COUNT(`Product Name Lenght`) AS null_Product_Name_Lenght,
COUNT(*) - COUNT(`Product Description Lenght`) AS null_Product_Description_Lenght,
COUNT(*) - COUNT(`Product Photos Qty`) AS null_Product_Photos_Qty,
COUNT(*) - COUNT(`Product Weight G`) AS null_Product_Weight_G,
COUNT(*) - COUNT(`Product Length Cm`) AS null_Product_Length_Cm,
COUNT(*) - COUNT(`Product Height Cm`) AS null_Product_Height_Cm,
COUNT(*) - COUNT(`Product Width Cm`) AS null_Product_Width_Cm,
COUNT(*) - COUNT(`Payment Sequential`) AS null_Payment_Sequential,
COUNT(*) - COUNT(`Payment Type`) AS null_Payment_Type,
COUNT(*) - COUNT(`Payment Installments`) AS null_Payment_Installments,
COUNT(*) - COUNT(`Payment Value`) AS null_Payment_Value,
COUNT(*) - COUNT(`Product Category Name English`) AS null_Product_Category_Name_English,
COUNT(*) - COUNT(`Review Score`) AS null_Review_Score,
COUNT(*) - COUNT(`Seller Zip Code Prefix`) AS null_Seller_Zip_Code,
COUNT(*) - COUNT(`Seller City`) AS null_Seller_City,
COUNT(*) - COUNT(`Seller State`) AS null_Seller_State
FROM master_table;

