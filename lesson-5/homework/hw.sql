--Easy
--1.Псевдоним для столбца ProductName как Name

SELECT ProductID,
       ProductName AS Name,
       Price, Category, StockQuantity
FROM dbo.Products;

--2.Псевдоним для таблицы Customers как Client

SELECT Client.*
FROM dbo.Customers AS Client;
-- или пример с явными полями:
-- SELECT Client.CustomerID, Client.FirstName, Client.LastName
-- FROM dbo.Customers AS Client;

--3.UNION имён товаров из двух таблиц (уникальные наименования)

SELECT ProductName FROM dbo.Products
UNION
SELECT ProductName FROM dbo.Products_Discounted;

--4.Пересечение товаров по названию (INTERSECT)

SELECT ProductName FROM dbo.Products
INTERSECT
SELECT ProductName FROM dbo.Products_Discounted;

--5.Уникальные имена клиентов и их страна

SELECT DISTINCT FirstName, LastName, Country
FROM dbo.Customers;

--6.Условный столбец High/Low по цене

SELECT ProductID, ProductName, Price,
       CASE WHEN Price > 1000 THEN 'High' ELSE 'Low' END AS PriceBand
FROM dbo.Products;

--7.IIF для запаса > 100 — ‘Yes’, иначе ‘No’

SELECT ProductID, ProductName, StockQuantity,
       IIF(StockQuantity > 100, 'Yes', 'No') AS Over100
FROM dbo.Products_Discounted;

Medium

--8.(Повтор задания 3) UNION имён товаров

SELECT ProductName FROM dbo.Products
UNION
SELECT ProductName FROM dbo.Products_Discounted;

--9.Разность множеств Products \ Products_Discounted по названию

SELECT ProductName FROM dbo.Products
EXCEPT
SELECT ProductName FROM dbo.Products_Discounted;

--10.IIF — ‘Expensive’ / ‘Affordable’

SELECT ProductID, ProductName, Price,
       IIF(Price > 1000, 'Expensive', 'Affordable') AS PriceFlag
FROM dbo.Products;

--11.Сотрудники: возраст < 25 или зарплата > 60000

SELECT *
FROM dbo.Employees
WHERE Age < 25 OR Salary > 60000;

--12.Повысить зарплату на 10% если DepartmentName = 'HR' или EmployeeID = 5

-- BEGIN TRAN;

UPDATE dbo.Employees
SET Salary = Salary * 1.10
WHERE DepartmentName = 'HR'
   OR EmployeeID = 5;

-- -- Проверка:
-- SELECT EmployeeID, DepartmentName, Salary FROM dbo.Employees
-- WHERE DepartmentName = 'HR' OR EmployeeID = 5;

-- ROLLBACK; -- отменить (или COMMIT, если нужно зафиксировать)

--Hard
--13.CASE по сумме продажи — Tier

SELECT SaleID, CustomerID, ProductID, SaleAmount,
       CASE
         WHEN SaleAmount > 500 THEN 'Top Tier'
         WHEN SaleAmount BETWEEN 200 AND 500 THEN 'Mid Tier'
         ELSE 'Low Tier'
       END AS Tier
FROM dbo.Sales;

--14.Клиенты, которые делали заказы, но не имеют записей в Sales

SELECT DISTINCT CustomerID
FROM dbo.Orders
EXCEPT
SELECT DISTINCT CustomerID
FROM dbo.Sales;

--15.Скидка по количеству (из Orders):

--ровно 1 — 3%
--от 2 до 3 — 5%
--иначе — 7

SELECT
    CustomerID,
    Quantity,
    CASE
        WHEN Quantity = 1 THEN '3%'
        WHEN Quantity BETWEEN 2 AND 3 THEN '5%'
        ELSE '7%'
    END AS DiscountPercent
FROM dbo.Orders;

--Если нужна именно числовая ставка для расчётов:

SELECT
    CustomerID,
    Quantity,
    CASE
        WHEN Quantity = 1 THEN 0.03
        WHEN Quantity BETWEEN 2 AND 3 THEN 0.05
        ELSE 0.07
    END AS DiscountRate
FROM dbo.Orders;

