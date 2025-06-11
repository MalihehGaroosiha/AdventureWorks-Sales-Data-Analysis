
# 🛠️AdventureWorks-Sales-Data-Analysis

This project explores the **AdventureWorks2022** sample database using **T-SQL** to simulate data analysis tasks a  data analyst might face. The project covers customer segmentation, sales performance, product ranking, and trend analysis — all aimed at providing actionable business insights.

---

## 📁 Dataset

**AdventureWorks2022** is a fictional database by Microsoft representing a manufacturing company. It includes tables for customers, orders, products, employees, and financials — ideal for SQL practice and analysis projects.

---

## 🎯 Business Questions Answered

### 1. High-Value Customers  
Identify customers with the highest lifetime value (total purchases).

### 2. Frequent Buyers  
Find customers who place the most orders.

### 3. Sales Summary  
Combine purchase count and total spend per customer.

### 4. Top-Selling Products  
Identify the top 5 products by total revenue generated.

### 5. Revenue Trends  
Analyze monthly sales to predict cash flow or investment needs.

### 6. Inactive Customers  
Flag customers who haven’t ordered in the past year.

### 7. Territory Performance  
Rank territory sales by year to track growth and decline.

### 8. Most Recent Orders  
Retrieve each customer’s latest order using `ROW_NUMBER()`.

### 9. Repeat Purchase Interval  
Measure the gap between purchases using `LAG()`.

### 10. Customer Ranking & Averages  
Calculate customer spending ranks, averages, and compare with overall values.

---

## 🧪 Sample Queries Used

```sql
-- Top 5 Products by Revenue
SELECT TOP 5 
    p.Name, 
    SUM(od.OrderQty * od.UnitPrice) AS TotalRevenue
FROM Sales.SalesOrderDetail od
JOIN Production.Product p ON od.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;
