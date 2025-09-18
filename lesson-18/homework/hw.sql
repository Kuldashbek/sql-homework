--1) Temp-таблица #MonthlySales: итоги за текущий месяц

-- Текущий месяц по серверной дате
DECLARE @month_start DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @month_next  DATE = DATEADD(MONTH, 1, @month_start);

IF OBJECT_ID('tempdb..#MonthlySales') IS NOT NULL DROP TABLE #MonthlySales;

SELECT 
    p.ProductID,
    SUM(s.Quantity) AS TotalQuantity,
    SUM(s.Quantity * p.Price) AS TotalRevenue
INTO #MonthlySales
FROM Sales s
JOIN Products p ON p.ProductID = s.ProductID
WHERE s.SaleDate >= @month_start
  AND s.SaleDate <  @month_next
GROUP BY p.ProductID;

-- Посмотреть результат:
SELECT * FROM #MonthlySales ORDER BY ProductID;

--2) View vw_ProductSalesSummary: инфо о товаре + общий объём продаж

IF OBJECT_ID('dbo.vw_ProductSalesSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductSalesSummary;
GO
CREATE VIEW dbo.vw_ProductSalesSummary AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    ISNULL(SUM(s.Quantity), 0) AS TotalQuantitySold
FROM Products p
LEFT JOIN Sales s ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category;
GO

-- Проверка
SELECT * FROM dbo.vw_ProductSalesSummary ORDER BY ProductID;

--3) Функция fn_GetTotalRevenueForProduct(@ProductID)

IF OBJECT_ID('dbo.fn_GetTotalRevenueForProduct') IS NOT NULL
    DROP FUNCTION dbo.fn_GetTotalRevenueForProduct;
GO
CREATE FUNCTION dbo.fn_GetTotalRevenueForProduct (@ProductID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @rev DECIMAL(18,2);

    SELECT @rev = SUM(s.Quantity * p.Price)
    FROM Sales s
    JOIN Products p ON p.ProductID = s.ProductID
    WHERE s.ProductID = @ProductID;

    RETURN ISNULL(@rev, 0);
END;
GO

-- Пример:
SELECT dbo.fn_GetTotalRevenueForProduct(1) AS Revenue_For_Product_1;

--4) TVF fn_GetSalesByCategory(@Category)

IF OBJECT_ID('dbo.fn_GetSalesByCategory') IS NOT NULL
    DROP FUNCTION dbo.fn_GetSalesByCategory;
GO
CREATE FUNCTION dbo.fn_GetSalesByCategory (@Category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductName,
        ISNULL(SUM(s.Quantity), 0)                            AS TotalQuantity,
        ISNULL(SUM(s.Quantity * p.Price), CAST(0 AS DECIMAL(18,2))) AS TotalRevenue
    FROM Products p
    LEFT JOIN Sales s ON s.ProductID = p.ProductID
    WHERE p.Category = @Category
    GROUP BY p.ProductName
);
GO

-- Пример:
SELECT * FROM dbo.fn_GetSalesByCategory('Electronics') ORDER BY ProductName;
--5) Функция fn_IsPrime(@Number) → 'Yes' / 'No'

IF OBJECT_ID('dbo.fn_IsPrime') IS NOT NULL
    DROP FUNCTION dbo.fn_IsPrime;
GO
CREATE FUNCTION dbo.fn_IsPrime (@Number INT)
RETURNS VARCHAR(3)
AS
BEGIN
    IF @Number < 2 RETURN 'No';
    IF @Number IN (2,3) RETURN 'Yes';
    IF @Number % 2 = 0 RETURN 'No';

    DECLARE @i INT = 3;
    WHILE (@i * @i) <= @Number
    BEGIN
        IF (@Number % @i = 0) RETURN 'No';
        SET @i += 2; -- проверяем только нечётные
    END
    RETURN 'Yes';
END;
GO

-- Примеры:
SELECT dbo.fn_IsPrime(91) AS N91, dbo.fn_IsPrime(97) AS N97;
--6) TVF fn_GetNumbersBetween(@Start, @End) (включительно)

IF OBJECT_ID('dbo.fn_GetNumbersBetween') IS NOT NULL
    DROP FUNCTION dbo.fn_GetNumbersBetween;
GO
CREATE FUNCTION dbo.fn_GetNumbersBetween (@Start INT, @End INT)
RETURNS TABLE
AS
RETURN
(
    WITH nums AS (
        SELECT CASE WHEN @Start <= @End THEN @Start ELSE @End END AS n,
               CASE WHEN @Start <= @End THEN @End   ELSE @Start END AS m
        UNION ALL
        SELECT n + 1, m
        FROM nums
        WHERE n < m
    )
    SELECT n AS [Number] FROM nums
);
GO
-- Важно для рекурсивных CTE: при больших диапазонах добавьте в запрос OPTION (MAXRECURSION 0).
-- Пример:
SELECT * FROM dbo.fn_GetNumbersBetween(5, 10) OPTION (MAXRECURSION 0);
--7) N-я по величине различная зарплата (NULL, если distinct < N)

IF OBJECT_ID('dbo.getNthHighestSalary') IS NOT NULL
    DROP FUNCTION dbo.getNthHighestSalary;
GO
CREATE FUNCTION dbo.getNthHighestSalary (@N INT)
RETURNS INT
AS
BEGIN
    -- Берём TOP (@N) DISTINCT, затем если их ровно N — минимум из них и есть N-я величина
    DECLARE @res INT;

    ;WITH topN AS (
        SELECT DISTINCT TOP (@N) salary
        FROM Employee
        ORDER BY salary DESC
    )
    SELECT @res = CASE WHEN COUNT(*) < @N THEN NULL ELSE MIN(salary) END
    FROM topN;

    RETURN @res;
END;
GO

-- Примеры:
SELECT dbo.getNthHighestSalary(2) AS HighestNSalary;
--8) Кто имеет больше всего друзей (взаимная дружба)

-- Таблица RequestAccepted предполагается созданной как в условии

WITH F AS (
    SELECT requester_id AS id, accepter_id AS friend FROM RequestAccepted
    UNION ALL
    SELECT accepter_id, requester_id FROM RequestAccepted
)
SELECT TOP (1)
    id,
    COUNT(DISTINCT friend) AS num
FROM F
GROUP BY id
ORDER BY num DESC, id;  -- при равенстве — меньший id первым
--9) View vw_CustomerOrderSummary

IF OBJECT_ID('dbo.vw_CustomerOrderSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_CustomerOrderSummary;
GO
CREATE VIEW dbo.vw_CustomerOrderSummary AS
SELECT
    c.customer_id,
    c.name,
    COUNT(o.order_id)                    AS total_orders,
    ISNULL(SUM(o.amount), 0)             AS total_amount,
    MAX(o.order_date)                    AS last_order_date
FROM Customers c
LEFT JOIN Orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name;
GO

-- Проверка:
SELECT * FROM dbo.vw_CustomerOrderSummary ORDER BY customer_id;

--10) Заполнить «дыры» последним ненулевым значением

-- Таблица Gaps у вас уже создана/заполнена

SELECT 
    g.RowNumber,
    (
        SELECT TOP 1 g2.TestCase
        FROM Gaps g2
        WHERE g2.RowNumber <= g.RowNumber
          AND g2.TestCase IS NOT NULL
        ORDER BY g2.RowNumber DESC
    ) AS Workflow
FROM Gaps g
ORDER BY g.RowNumber;

