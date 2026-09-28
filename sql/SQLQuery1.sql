use Ecommerce_Analytics


CREATE TABLE Customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Signup_Date DATE,
    Gender VARCHAR(10),
    Age INT,
    City VARCHAR(50),
    Region VARCHAR(20),
    Acquisition_Channel VARCHAR(50),
    Customer_Segment VARCHAR(20)
);

CREATE TABLE Products (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Cost_Price DECIMAL(10,2),
    Selling_Price DECIMAL(10,2)  
);

CREATE TABLE Orders (
    Order_ID VARCHAR(20) PRIMARY KEY,
    Customer_ID VARCHAR(20),
    Order_Date DATE,
    Product_ID VARCHAR(20),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Discount DECIMAL(5,2),
    Payment_Method VARCHAR(30),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

CREATE TABLE Returns (
    Return_ID VARCHAR(20) PRIMARY KEY,
    Order_ID VARCHAR(20),
    Return_Date DATE,
    Return_Reason VARCHAR(50),
    Refund_Amount DECIMAL(10,2),
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

CREATE TABLE Customer_Activity (
    Customer_ID VARCHAR(20),
    Activity_Date DATE,
    Login_Count INT,
    Session_Minutes DECIMAL(5,2),
    Orders_Count INT,
    Support_Tickets DECIMAL(5,2),
    App_Usage VARCHAR(10),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);


INSERT INTO Customers (Customer_ID, Signup_Date, Gender, Age, City, Region, Acquisition_Channel, Customer_Segment)
SELECT Customer_ID, Signup_Date, Gender, Age, City, Region, Acquisition_Channel, Customer_Segment
FROM Customers$

-- 2.  Products 
INSERT INTO Products (Product_ID, Product_Name, Category, Sub_Category, Cost_Price, Selling_Price)
SELECT Product_ID, Product_Name, Category, Sub_Category, Cost_Price, Selling_Price
FROM Products$

-- 3.  Orders 
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Product_ID, Quantity, Unit_Price, Discount, Payment_Method)
SELECT Order_ID, Customer_ID, Order_Date, Product_ID, Quantity, Unit_Price, Discount, Payment_Method
FROM Orders$

-- 4. Returns 
INSERT INTO Returns (Return_ID, Order_ID, Return_Date, Return_Reason, Refund_Amount)
SELECT Return_ID, Order_ID, Return_Date, Return_Reason, Refund_Amount
FROM Returns$

-- 5. Customer_Activity 
INSERT INTO Customer_Activity (Customer_ID, Activity_Date, Login_Count, Session_Minutes, Orders_Count, Support_Tickets, App_Usage)
SELECT Customer_ID, Activity_Date, Login_Count, Session_Minutes, Orders_Count, Support_Tickets, App_Usage
FROM Customer_Activity$

/* Cleanup — Staging ($) Tables Delete */
DROP TABLE [Customers$];
DROP TABLE [Products$];
DROP TABLE [Orders$];
DROP TABLE [Returns$];
DROP TABLE [Customer_Activity$];

CREATE TABLE RFM_Analysis (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Recency INT,
    Frequency INT,
    Monetary DECIMAL(12,2),
    R_Score INT,
    F_Score INT,
    M_Score INT,
    RFM_Score VARCHAR(10),
    Total_Score INT,
    Segment VARCHAR(30),
    Churn_Flag VARCHAR(10),
    RFM_Risk_Level VARCHAR(20),
    Risk_Category VARCHAR(30),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

INSERT INTO RFM_Analysis (Customer_ID, Recency, Frequency, Monetary, R_Score, F_Score, M_Score, RFM_Score, Total_Score, Segment, Churn_Flag, RFM_Risk_Level, Risk_Category)
SELECT Customer_ID, Recency, Frequency, monetary, R_score, F_score, M_score, RFM_score, Total_score, Segment, churn_flag, rfm_risk_level, risk_category
FROM rfm_analysis#xls$

DROP TABLE  rfm_analysis#xls$



SELECT TOP 10 c.Customer_ID, c.City, c.Customer_Segment, r.Recency, r.Frequency, r.Monetary, r.Segment, r.Risk_Category
FROM Customers c
JOIN RFM_Analysis r ON c.Customer_ID = r.Customer_ID
ORDER BY r.Monetary DESC

/*CTE Query — Valuable But At-Risk Customers*/

WITH Valuable_At_Risk AS (
    SELECT c.Customer_ID, c.City, r.Segment, r.Recency, r.Monetary, r.Risk_Category
    FROM Customers c
    JOIN RFM_Analysis r ON c.Customer_ID = r.Customer_ID
    WHERE r.Segment = 'Champion' AND r.Risk_Category LIKE 'High Risk%'
)
SELECT * FROM Valuable_At_Risk
ORDER BY Monetary DESC




/* RANK*/
SELECT 
    p.Category,
    p.Product_Name,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount)) AS Revenue,
    RANK() OVER (PARTITION BY p.Category ORDER BY SUM(o.Quantity * o.Unit_Price * (1 - o.Discount)) DESC) AS Rank_In_Category
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
GROUP BY p.Category, p.Product_Name
ORDER BY p.Category, Rank_In_Category


/*Running Total*/
WITH Monthly_Revenue AS (
    SELECT 
        CONVERT(VARCHAR(7), Order_Date, 120) AS Order_Month,
        SUM(Quantity * Unit_Price * (1 - Discount)) AS Monthly_Total
    FROM Orders
    GROUP BY CONVERT(VARCHAR(7), Order_Date, 120)
)
SELECT 
    Order_Month,
    Monthly_Total,
    SUM(Monthly_Total) OVER (ORDER BY Order_Month) AS Running_Total
FROM Monthly_Revenue
ORDER BY Order_Month




CREATE VIEW vw_Customer_360 AS
SELECT 
    c.Customer_ID,
    c.City,
    c.Region,
    c.Customer_Segment,
    r.Recency,
    r.Frequency,
    r.Monetary,
    r.Segment AS RFM_Segment,
    r.Churn_Flag,
    r.Risk_Category
FROM Customers c
LEFT JOIN RFM_Analysis r ON c.Customer_ID = r.Customer_ID




SELECT * FROM vw_Customer_360 WHERE Risk_Category LIKE 'High Risk%'



SELECT * FROM vw_Customer_360 WHERE RFM_Segment = 'Champion' ORDER BY Monetary DESC




CREATE PROCEDURE sp_GetHighRiskCustomersByCity
    @CityName VARCHAR(50)
AS
BEGIN
    SELECT c.Customer_ID, c.City, r.Recency, r.Monetary, r.Risk_Category
    FROM Customers c
    JOIN RFM_Analysis r ON c.Customer_ID = r.Customer_ID
    WHERE c.City = @CityName AND r.Risk_Category LIKE 'High Risk%'
    ORDER BY r.Monetary DESC;
END

exec sp_GetHighRiskCustomersByCity @CityName = 'Delhi'



-- Revenue at Risk 
SELECT 
    COUNT(*) AS Churned_Customers,
    SUM(Monetary) AS Revenue_At_Risk,
    (SELECT SUM(Monetary) FROM RFM_Analysis) AS Total_Revenue,
    ROUND(SUM(Monetary) * 100.0 / (SELECT SUM(Monetary) FROM RFM_Analysis), 2) AS Risk_Percentage
FROM RFM_Analysis
WHERE Churn_Flag = 'Churned'


/* — Category-wise Performance*/

SELECT 
    p.Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount)) AS Total_Revenue,
    ROUND(AVG(o.Quantity * o.Unit_Price * (1 - o.Discount)), 2) AS Avg_Order_Value
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Total_Revenue DESC

/* — Customer Retention Rate (Active vs Churned %) */

SELECT 
    Churn_Flag,
    COUNT(*) AS Customer_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM RFM_Analysis), 2) AS Percentage
FROM RFM_Analysis
GROUP BY Churn_Flag

/* — Return Rate by Category */

SELECT 
    p.Category,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    COUNT(DISTINCT r.Return_ID) AS Total_Returns,
    ROUND(COUNT(DISTINCT r.Return_ID) * 100.0 / COUNT(DISTINCT o.Order_ID), 2) AS Return_Rate_Percent
FROM Orders o
JOIN Products p ON o.Product_ID = p.Product_ID
LEFT JOIN Returns r ON o.Order_ID = r.Order_ID
GROUP BY p.Category
ORDER BY Return_Rate_Percent DESC

/* — Top 5 Cities by Revenue*/

SELECT TOP 5
    c.City,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    SUM(o.Quantity * o.Unit_Price * (1 - o.Discount)) AS Total_Revenue
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.City
ORDER BY Total_Revenue DESC




