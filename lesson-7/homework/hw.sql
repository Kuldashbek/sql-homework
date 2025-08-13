--Easy
--1.MIN цена товара

SELECT MIN(Price) AS MinPrice
FROM dbo.Products;

--2.MAX зарплата

SELECT MAX(Salary) AS MaxSalary
FROM dbo.Employees;

--3.Кол-во строк в Customers

SELECT COUNT(*) AS CustomerCount
FROM dbo.Customers;

--4.Кол-во уникальных категорий

SELECT COUNT(DISTINCT Category) AS CategoryCount
FROM dbo.Products;

--5.Общая сумма продаж по продукту id = 7

SELECT SUM(SaleAmount) AS TotalByProduct7
FROM dbo.Sales
WHERE ProductID = 7;

--6.Средний возраст сотрудников

SELECT AVG(CAST(Age AS DECIMAL(10,2))) AS AvgAge
FROM dbo.Employees;

--7.Число сотрудников по отделам

SELECT DepartmentName, COUNT(*) AS EmployeeCount
FROM dbo.Employees
GROUP BY DepartmentName;

--8.MIN и MAX цена по категории

SELECT Category,
       MIN(Price) AS MinPrice,
       MAX(Price) AS MaxPrice
FROM dbo.Products
GROUP BY Category;

--9.Итог продаж по каждому клиенту (Sales)

SELECT CustomerID, SUM(SaleAmount) AS TotalSales
FROM dbo.Sales
GROUP BY CustomerID;

--10.Отделы, где сотрудников > 5

SELECT DepartmentName, COUNT(*) AS EmployeeCount
FROM dbo.Employees
GROUP BY DepartmentName
HAVING COUNT(*) > 5;

--Medium
--11.Итог и средняя продажа по категории (нужен JOIN к Products)

SELECT p.Category,
       SUM(s.SaleAmount) AS TotalSales,
       AVG(s.SaleAmount) AS AvgSale
FROM dbo.Sales s
JOIN dbo.Products p ON p.ProductID = s.ProductID
GROUP BY p.Category;

--12.Число сотрудников HR

SELECT COUNT(*) AS HrCount
FROM dbo.Employees
WHERE DepartmentName = 'HR';

--13.MAX и MIN зарплата по отделам

SELECT DepartmentName,
       MAX(Salary) AS MaxSalary,
       MIN(Salary) AS MinSalary
FROM dbo.Employees
GROUP BY DepartmentName;

--14.Средняя зарплата по отделам

SELECT DepartmentName, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY DepartmentName;

--15.AVG зарплаты и COUNT(*) по отделам

SELECT DepartmentName,
       AVG(Salary) AS AvgSalary,
       COUNT(*)    AS EmpCount
FROM dbo.Employees
GROUP BY DepartmentName;

--16.Категории с средней ценой > 400

SELECT Category, AVG(Price) AS AvgPrice
FROM dbo.Products
GROUP BY Category
HAVING AVG(Price) > 400;

--17.Итог продаж по годам (Sales)

SELECT YEAR(SaleDate) AS SaleYear,
       SUM(SaleAmount) AS TotalSales
FROM dbo.Sales
GROUP BY YEAR(SaleDate)
ORDER BY SaleYear;

--18.Клиенты, сделавшие ≥ 3 заказа (Orders)

SELECT CustomerID, COUNT(*) AS OrderCount
FROM dbo.Orders
GROUP BY CustomerID
HAVING COUNT(*) >= 3;

--19.Отделы со средней зарплатой > 60000

SELECT DepartmentName, AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY DepartmentName
HAVING AVG(Salary) > 60000;

--Hard
--20.Средняя цена по категории и фильтр > 150

SELECT Category, AVG(Price) AS AvgPrice
FROM dbo.Products
GROUP BY Category
HAVING AVG(Price) > 150;

--21.Итог продаж по клиенту и фильтр > 1500 (Sales)

SELECT CustomerID, SUM(SaleAmount) AS TotalSales
FROM dbo.Sales
GROUP BY CustomerID
HAVING SUM(SaleAmount) > 1500;

--22.Сумма и средняя зарплата по отделу; фильтр AVG > 65000

SELECT DepartmentName,
       SUM(Salary) AS TotalSalary,
       AVG(Salary) AS AvgSalary
FROM dbo.Employees
GROUP BY DepartmentName
HAVING AVG(Salary) > 65000;

--23.(TSQL2012) Итог по заказам с Freight > 50 для каждого клиента + их минимальная покупка
--В базе TSQL2012 обычно используется Sales.SalesOrderHeader с колонками
--CustomerID, Freight, TotalDue. Если у вас именно Sales.Orders, адаптируйте имена колонок.

--Вариант для AdventureWorks-подобной схемы (Sales.SalesOrderHeader):

WITH Totals AS (
    SELECT CustomerID,
           SUM(TotalDue) AS TotalWhereFreightGt50
    FROM Sales.SalesOrderHeader
    WHERE Freight > 50
    GROUP BY CustomerID
),
Least AS (
    SELECT CustomerID,
           MIN(TotalDue) AS LeastPurchase
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT COALESCE(t.CustomerID, l.CustomerID) AS CustomerID,
       ISNULL(t.TotalWhereFreightGt50, 0)   AS TotalWhereFreightGt50,
       l.LeastPurchase
FROM Totals t
FULL JOIN Least l
  ON l.CustomerID = t.CustomerID
ORDER BY CustomerID;

--Если у вас именно TSQL2012.Sales.Orders с колонками (custid, freight,totaldue):

WITH Totals AS (
    SELECT custid AS CustomerID,
           SUM(totaldue) AS TotalWhereFreightGt50
    FROM TSQL2012.Sales.Orders
    WHERE freight > 50
    GROUP BY custid
),
Least AS (
    SELECT custid AS CustomerID,
           MIN(totaldue) AS LeastPurchase
    FROM TSQL2012.Sales.Orders
    GROUP BY custid
)
SELECT COALESCE(t.CustomerID, l.CustomerID) AS CustomerID,
       ISNULL(t.TotalWhereFreightGt50, 0)   AS TotalWhereFreightGt50,
       l.LeastPurchase
FROM Totals t
FULL JOIN Least l
  ON l.CustomerID = t.CustomerID
ORDER BY CustomerID;


--25.Итог продаж и число уникальных товаров по месяцам/годам, оставить месяцы с≥ 2 товарами (Orders)

SELECT
    YEAR(OrderDate)  AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    SUM(TotalAmount) AS TotalSales,
    COUNT(DISTINCT ProductID) AS UniqueProducts
FROM dbo.Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
HAVING COUNT(DISTINCT ProductID) >= 2
ORDER BY OrderYear, OrderMonth;

--26.MIN и MAX количество по годам (Orders)

SELECT
    YEAR(OrderDate) AS OrderYear,
    MIN(Quantity)   AS MinQty,
    MAX(Quantity)   AS MaxQty
FROM dbo.Orders
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;
