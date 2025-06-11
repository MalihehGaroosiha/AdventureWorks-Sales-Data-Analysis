-- AdventureWorks2022 SQL Sales Analysis Project
-- Author: Maliheh Garoosiha
-- Description: SQL-based business analysis on sales data to identify customer behavior, sales trends, and top products.
use AdventureWorks2022
-- ============================================
-- 1. Explore Data from Key Tables
-- ============================================
select top 10 *  from Sales.SalesOrderHeader
select top 10 * from Sales.CreditCard
select top 10 * from Sales.Customer
select top 10 * from Person.Person
select top 10 * from Production.Product
-- ============================================
-- 2. 10 High-Value Customers: Total Purchase
-- ============================================
create view customernamepurchase as 
select s.firstname,s.lastname,pp.total_perchast
from Person].[Person] as s
inner join  
(select p.personid, c.total_perchast
from [Sales].[Customer] as p
inner join (
select customerid, sum(totaldue) as total_perchast 
from Sales.SalesOrderHeader
group by CustomerID) as c
on p.CustomerID=c.CustomerID) as pp
on s.BusinessEntityID=pp.personid
select top 10 * from customernamepurchase
order by total_perchast desc
-- ==================================================================
--- identify high-number clients based on transaction history.
-- ==================================================================
select per.firstname,per.lastname,m.numberofpurchase
from person.person as per
inner join
(select c.personid,pp.numberofpurchase
from Sales.Customer as c 
inner join 
(select CustomerID,count(*) as numberofpurchase from Sales.SalesOrderHeader
group by CustomerID) as pp
on pp.CustomerID=c.CustomerID) as m
on m.personid=per.BusinessEntityID
order by numberofpurchase desc
-- ============================================================
--Now I want to tell every one how much pesrchase and how many
-- ============================================================
create view totalsale as
select per.firstname,per.lastname,m.numberofpurchase,m.total
from person.person as per
inner join
(select c.personid,pp.numberofpurchase,pp.total
from [Sales].[Customer] as c 
inner join 
(select CustomerID,count(*) as numberofpurchase, sum(totaldue) as total from [Sales].[SalesOrderHeader]
group by CustomerID) as pp
on pp.CustomerID=c.CustomerID) as m
on m.personid=per.BusinessEntityID
-- ==================================================================
--Identify 5 best product
-- ==================================================================
select top 5 p.name,sum(o.orderQty*o.unitprice) as TotalRevenue from Sales.SalesOrderDetail as o
inner join Production.Product as p
on o.productid=p.productid
group by p.name
order by TotalRevenue desc
-- ==================================================================
--Analyze revenue trends to predict cash flow or investment needs.
-- ==================================================================
select (cast(year(OrderDate) as varchar)+'-'+
right('0'+cast(month(OrderDate) as varchar),2)) as month_year,sum(SubTotal) 
from [Sales].[SalesOrderHeader]
group by (cast(year(OrderDate) as varchar)+'-'+
right('0'+cast(month(OrderDate) as varchar),2))
order by (cast(year(OrderDate) as varchar)+'-'+
right('0'+cast(month(OrderDate) as varchar),2))
-- ==================================================================
---Identify Inactive Customers
-- ==================================================================
select so.CustomerID , max(so.orderdate) as last_order
from Sales.SalesOrderHeader as so
right join Sales.Customer as c
on so.CustomerID=c.CustomerID
group by so.CustomerID 
having max(so.orderdate)<dateadd(year,-1,getdate())
-- ============================================================
--customer last order
-- ============================================================
select CustomerID , max(orderdate) as last_order
from Sales.SalesOrderHeader 
group by CustomerID 

-- ==================================================================
-- Extract top 5 products name by sales amount
-- ==================================================================
select top 5 p.name,sum(s.totaldue) as total
from Production.Product as P
inner join(
select sd.productid,sh.totaldue
from Sales.SalesOrderHeader as SH
inner join Sales.SalesOrderDetail as SD
on sd.salesorderid=sh.SalesOrderID) as S
on s.ProductID=p.ProductID
group by p.name
order by total desc
-- ==================================================================
--add category label based on sales value by case
-- ==================================================================
select sh.* , sd.* ,
  case
    when sh.totaldue>100000 then 'High'
    when sh.totaldue>50000 then 'medium'
    else 'low'
  end as salecategory
from
sales.SalesOrderHeader as sh
inner join Sales.SalesOrderDetail as sd
on sh.salesorderid=sd.salesorderid
-- ==========================================================================================
---Retrieve the list of customers who have made purchases above $10,000 in a single order.
-- ==========================================================================================
select customerid, sum(totaldue) from sales.SalesOrderHeader
group by customerid
having sum(totaldue)>10000
-- ================================================
--Find the average order value for each salesperson in the dataset.
-- ================================================
select salespersonid, avg(totaldue)
from sales.salesorderheader
group by salespersonid
-- ================================================
--Find the Total purchase  for each year in the dataset.
-- ================================================
select year(orderdate) as year_due, sum(totaldue)
from sales.salesorderheader
group by year(orderdate)
order by year_due
-- =================================================================
--Find all customers who have not placed an order in the last 6 months.
-- =================================================================
select CustomerID,OrderDate
from sales.salesorderheader
where OrderDate< DATEADD(month,-6,GETDATE())
-- ===============================================
--Customer Ranking by Total Purchase Value
-- ===============================================
select customerid, rank() over (order by sum(totaldue) Desc) as rank_customer,sum(totaldue) as total 
from sales.salesorderheader
group by customerid

-- =============================================================
--Customer Ranking by Sales Volume Within Each Territory
-- =============================================================
select customerid,
  TerritoryID,
  rank() over (partition by TerritoryID order by sum(totaldue) Desc) as rank_customer,
  sum(totaldue) as total 
from sales.salesorderheader
group by  customerid,TerritoryID

-- =======================================================================================   
--Write a query to assign a row number to each customer based on OrderDate (newest first).
-- =======================================================================================
select CustomerID,
    SalesOrderID,
    OrderDate,ROW_NUMBER() over (partition by customerid order by OrderDate desc)
FROM Sales.SalesOrderHeader

select customerid,SalesOrderID,max(orderdate) over (partition by customerid)
FROM Sales.SalesOrderHeader
-- =======================================================================================
--Using the previous query, return only the most recent order for each customer.
-- =======================================================================================
create view rankorders as 
select 
   CustomerID,
    SalesOrderID,
    OrderDate,
	ROW_NUMBER() over (partition by customerid order by OrderDate desc) as orderrank
FROM Sales.SalesOrderHeader
select * from rankorders
where orderrank=1
WITH rankorders AS (
    SELECT 
        CustomerID,
        SalesOrderID,
        OrderDate,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC) AS orderrank
    FROM Sales.SalesOrderHeader
)
SELECT *
FROM rankorders;

SELECT 
    CustomerID,
    SalesOrderID,
    OrderDate,
    ROW_NUMBER() OVER (ORDER BY OrderDate DESC) AS RowNum,
	Rank() OVER (ORDER BY OrderDate DESC) AS RankNum,
	DENSE_RANK() OVER (ORDER BY OrderDate DESC) AS RankNum2
FROM Sales.SalesOrderHeader;
 create index idx_number
 on person.person(firstname)
 select * from person.person
 where LastName='Duffy'
-- =====================================================================
-- calcalate the whole perchase of each customer and then rank them
-- =====================================================================
with customer_purchase as(
select CustomerID,
   sum(TotalDue) as total_purchase
from Sales.SalesOrderHeader
group by CustomerID)
select CustomerID,
   total_purchase, 
   rank() over(order by total_purchase desc)
from customer_purchase

select CustomerID,year(OrderDate), sum(TotalDue),
   sum(TotalDue) over(partition by CustomerID) as total_purchase_yearly
from Sales.SalesOrderHeader
group by CustomerID,year(OrderDate)

SELECT 
  CustomerID,
  YEAR(OrderDate) AS OrderYear,
  SUM(TotalDue) AS YearlyTotal
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, YEAR(OrderDate);
-- =======================================================================================
--Find the highest-value order (TotalDue) for each customer and show all orders, ranked by value.
-- =======================================================================================
SELECT 
  CustomerID,
  DENSE_RANK() over(partition by CustomerID order by TotalDue)
FROM Sales.SalesOrderHeader;
-- ============================================
-- Track First and Last Order Dates for Each Customer
-- ============================================
SELECT 
  CustomerID,
  max(orderdate) over(partition by CustomerID ) as last_purchase,
  min(orderdate) over(partition by CustomerID ) as first_purchase
FROM Sales.SalesOrderHeader;
-- ============================================
-- Calculate Overall Average Order Value
-- ============================================
select avg(TotalDue)
FROM Sales.SalesOrderHeader

-- =========================================================================================================
--Show each territory’s total sales per year and rank the years within each territory from highest to lowest.
-- =========================================================================================================
with group_ as(
select TerritoryID,
  year( OrderDate) as _year,
  sum(TotalDue) as total
from Sales.SalesOrderHeader
group by TerritoryID ,year( OrderDate))
select TerritoryID,
  _year,total,
  rank() over (partition by TerritoryID ORDER BY Total DESC)
from group_
order by TerritoryID,_year 
    ,rank() over(partition by year( [OrderDate]) order by [TotalDue] )as total_year
-- ===============================================================================
--Identify High-Spending Customers or list customer who spend more than average
-- ===============================================================================
select CustomerID, (
select avg(TotalDue)
from Sales.SalesOrderHeader),
  TotalDue
from Sales.SalesOrderHeader
where TotalDue>(
select avg(TotalDue)
from Sales.SalesOrderHeader) 
order by TotalDue desc
-- =========================
--Repeat Purchase Interval
-- =========================
SELECT top 5
    CustomerID,
	OrderDate,
	lag(OrderDate) over (partition by CustomerID order by OrderDate) as previous_purchase,
	datediff(day,lag(OrderDate) over (partition by CustomerID order by OrderDate),OrderDate)
FROM Sales.SalesOrderHeader
-- =====================================
--Yearly Rank of Customers by Spending
-- =====================================
with yearly_rank as(
SELECT 
    CustomerID,
	year(OrderDate) as year_,
	sum(TotalDue) as Sum_	
FROM Sales.SalesOrderHeader
group by CustomerID, year(OrderDate))
select   CustomerID,year_ ,Sum_ ,rank() over (partition by year_ order by Sum_) as yearly_spend_rank
  from yearly_rank




