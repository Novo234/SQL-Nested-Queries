SELECT *
FROM Sales_table

--1. Which date(s) had the highest total sales and which product(s) contributed to those sales?

SELECT Order_Date, Product_ID, Sales
FROM Sales_table
WHERE Order_date IN (
    -- Finding the dates with the maximum total sales
    SELECT Order_Date
    FROM Sales_table
    GROUP BY [Order_Date]
    HAVING SUM(Sales) = (
        -- Calculating the maximum total sales across all dates
        SELECT MAX(TotalSales)
        FROM (
            SELECT Order_Date, SUM(Sales) AS TotalSales
            FROM Sales_table
            GROUP BY Order_Date
        ) AS DateSales
    )
);

-- Alternatively, the question can also be solved using CTE function
WITH DailySales AS(
SELECT Order_date, SUM(Sales) AS TotalSales
FROM Sales_table
GROUP BY Order_Date
)
SELECT S.Order_Date, S.Product_ID, S.Sales
FROM Sales_table S
JOIN DailySales D
ON S.Order_Date = D.Order_Date
WHERE D.TotalSales = (
SELECT MAX(TotalSales)
FROM DailySales)


-- 2. Which product(s) had the highest average unit price among all products sold
-- Find the products highest average unit price
SELECT [Product_ID], AVG(Sales / Quantity) AS AvgUnitPrice
FROM Sales_Table
GROUP BY [Product_ID]
HAVING AVG(Sales / Quantity) = (
    -- Calculate the maximum average unit price across all products
    SELECT MAX(AvgPrice)
    FROM (
        SELECT AVG(Sales / Quantity) AS AvgPrice
        FROM Sales_Table
        GROUP BY [Product_ID]
    ) AS ProductAverages
);
--Alternatively, 
SELECT TOP 1 Product_ID, AVG(Sales/Quantity) AvgUnitPrice
FROM Sales_table
GROUP BY Product_ID
ORDER BY AvgUnitPrice DESC


--3. What were the total sales for each product on dates where the quantity sold exceeded the average quantity sold for that product
SELECT SUM(Sales) Total_sales, Order_date, product_id
FROM Sales_table
WHERE Quantity > (
SELECT AVG(Quantity) Avg_qty_sold
FROM Sales_table
)
GROUP BY Order_Date, Product_id
ORDER BY Order_Date, Product_id
-- Alternative, solving the same question using CTE
WITH AvgQuantity AS(
SELECT Product_ID, AVG(CAST(Quantity AS FLOAT)) AvgQuantity
FROM Sales_table
GROUP BY Product_ID
)
SELECT S.Order_Date, S.Product_ID, SUM(S.Sales) Total_Sales
FROM Sales_table S
INNER JOIN AvgQuantity A
ON S.Product_ID = A.Product_ID
WHERE S.Quantity > A.AvgQuantity
GROUP BY S.Order_Date, S.Product_ID
ORDER BY S.Order_Date, S.Product_ID


--4. What were the top 3 dates with the highest total sales, and which product(s) contributed to those sales on each date?

SELECT TOP 3 Order_Date, Product_ID, Sales AS TotalSales
FROM Sales_table
ORDER BY Sales DESC

--5. What percentage of the total sales on April 15th, 2024, did each product contribute?
SELECT product_ID, Sales,
    (Sales / (SELECT SUM(Sales) 
	FROM Sales_table
	WHERE Order_Date = '2024-04-15') * 100) AS PercentageContribution
FROM Sales_table
WHERE Order_Date = '2024-04-15'

--On which date(s) did product C's total sales exceed the combined total sales of all other products?



-- 6. What were the cumulative total sales for each product over the entire period covered by the dataset, ordered by date?
--Firstly,we create a CTE for 3 day sales
WITH ThreeDaySales AS (
SELECT Product_ID, Order_Date, SUM(Sales) OVER(
PARTITION BY Product_ID
ORDER BY Order_Date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeDayTotalSales
FROM Sales_table
)
SELECT TOP 1 Product_ID, Order_Date, ThreeDayTotalSales
FROM ThreeDaySales
ORDER BY ThreeDayTotalSales DESC
 
SELECT Order_Date, Sales,
    SUM(Sales) OVER (
        PARTITION BY Product_ID
        ORDER BY Order_Date
    ) AS CumulativeTotalSales
FROM Sales_table
ORDER BY Product_ID, Order_Date;

--7. On which dates did particular products total sales exceeds the combined total sales of all other products.
WITH ProductCSales AS(
SELECT Order_Date, SUM(Sales) AS ProductCsales
FROM Sales_table
WHERE Product_ID = 'FUR-TA-10000577'
GROUP BY Order_Date
),
OtherProductSales AS(
SELECT Order_Date, SUM(Sales) AS OtherSales
FROM Sales_table
WHERE Product_ID <> 'FUR-TA-10000577'
GROUP BY Order_Date
)
SELECT C.Order_Date
FROM ProductCSales C
JOIN OtherProductSales O
ON C.Order_Date = O.Order_Date
WHERE C.ProductCSales > O.OtherSales


--8. What were the cumulative total sales for each product over the entire SELECT period covered by the dataset, ordered by date?
SELECT Product_ID, Order_Date, SUM(Sales) OVER(
PARTITION BY Product_ID
ORDER BY Order_Date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CummulativeTotalSales
FROM Sales_table
ORDER BY Product_ID, Order_Date
