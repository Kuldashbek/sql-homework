--Part 1 — Stored Procedures
-- Task 1 — расчёт бонусов в temp-таблицу и вывод

IF OBJECT_ID('dbo.usp_FillEmployeeBonus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_FillEmployeeBonus;
GO
CREATE PROCEDURE dbo.usp_FillEmployeeBonus
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#EmployeeBonus') IS NOT NULL DROP TABLE #EmployeeBonus;

    SELECT 
        e.EmployeeID,
        FullName   = CONCAT(e.FirstName, ' ', e.LastName),
        e.Department,
        e.Salary,
        BonusAmount = e.Salary * (ISNULL(db.BonusPercentage, 0) / 100.0)
    INTO #EmployeeBonus
    FROM Employees e
    LEFT JOIN DepartmentBonus db
      ON db.Department = e.Department;

    SELECT * FROM #EmployeeBonus ORDER BY EmployeeID;
END
GO

-- Пример:
EXEC dbo.usp_FillEmployeeBonus;
--Task 2 — поднять оклады по отделу на X%

IF OBJECT_ID('dbo.usp_IncreaseDeptSalary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_IncreaseDeptSalary;
GO
CREATE PROCEDURE dbo.usp_IncreaseDeptSalary
    @Department NVARCHAR(50),
    @IncreasePercent DECIMAL(9,4)  -- например: 5 = +5%
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
       SET e.Salary = e.Salary * (1 + (@IncreasePercent / 100.0))
    FROM Employees e
    WHERE e.Department = @Department;

    SELECT *
    FROM Employees
    WHERE Department = @Department
    ORDER BY EmployeeID;
END
GO

-- Пример:
-- EXEC dbo.usp_IncreaseDeptSalary @Department = N'Sales', @IncreasePercent = 7.5;

--Part 2 — MERGE
--Task 3 — синхронизация текущих и новых продуктов

MERGE INTO Products_Current AS tgt
USING Products_New     AS src
   ON tgt.ProductID = src.ProductID
WHEN MATCHED THEN
    UPDATE SET tgt.ProductName = src.ProductName,
               tgt.Price       = src.Price
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, Price)
    VALUES (src.ProductID, src.ProductName, src.Price)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- Итог:
SELECT * FROM Products_Current ORDER BY ProductID;

--Task 4 — классификация узлов дерева (Root/Inner/Leaf)
-- Таблица Tree уже заполнена
SELECT
    t.id,
    [type] =
        CASE
            WHEN t.p_id IS NULL THEN 'Root'
            WHEN EXISTS (SELECT 1 FROM Tree c WHERE c.p_id = t.id) THEN 'Inner'
            ELSE 'Leaf'
        END
FROM Tree t
ORDER BY t.id;
--Task 5 — Confirmation Rate по каждому пользователю

-- Универсальный запрос под SQL Server
WITH C AS (
    SELECT
        s.user_id,
        total_cnt     = COUNT(c.time_stamp), -- все события по пользователю (0, если нет строк)
        confirmed_cnt = SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END)
    FROM Signups s
    LEFT JOIN Confirmations c
      ON c.user_id = s.user_id
    GROUP BY s.user_id
)
SELECT
    user_id,
    confirmation_rate = CAST(
        CASE WHEN total_cnt = 0 THEN 0.0
             ELSE 1.0 * confirmed_cnt / total_cnt
        END AS DECIMAL(3,2)
    )
FROM C
ORDER BY user_id;  -- или как в примере: 6,3,7,2
--Task 6 — сотрудники с минимальной зарплатой (через подзапрос)

SELECT id, name, salary
FROM employees
WHERE salary = (SELECT MIN(salary) FROM employees)
ORDER BY id;

--Task 7 — proc «GetProductSalesSummary»

IF OBJECT_ID('dbo.GetProductSalesSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetProductSalesSummary;
GO
CREATE PROCEDURE dbo.GetProductSalesSummary
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductName,
        TotalQuantity   = SUM(CAST(s.Quantity AS INT)),             -- будет NULL, если нет продаж
        TotalSalesAmount= SUM(CAST(s.Quantity AS DECIMAL(18,2)) * p.Price),
        FirstSaleDate   = MIN(s.SaleDate),
        LastSaleDate    = MAX(s.SaleDate)
    FROM Products p
    LEFT JOIN Sales s
      ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID
    GROUP BY p.ProductName;
END
GO

-- Примеры:
-- EXEC dbo.GetProductSalesSummary @ProductID = 1;  -- есть продажи
-- EXEC dbo.GetProductSalesSummary @ProductID = 12; -- нет продаж => NULL по агрегатам
