--Task 6 — сотрудники с минимальной зарплатой

SELECT id, name, salary
FROM employees
WHERE salary = (SELECT MIN(salary) FROM employees)
ORDER BY id;

--Task 7 — GetProductSalesSummary

--Ваш код — корректен и соответствует требованию «NULL, если продаж нет». Пара полировок, чтобы было совсем «как в аптеке».

--Что можно улучшить

Чуть точнее тип для суммы денег, чтобы «не шевелился» от больших объёмов: DECIMAL(19,4).

Явно приводим агрегаты, чтобы исключить неявные типизации.

(Опционально) Если продукт с таким @ProductID не существует — сейчас вернётся 0 строк. Это ок по ТЗ. Если хотите всегда 1 строку (даже при неверном ID) — добавлю защиту.

--Вариант «оставить как по ТЗ», только типы полирнуть
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
        TotalQuantity    = CAST(SUM(CAST(s.Quantity AS BIGINT)) AS BIGINT),                -- NULL, если продаж нет
        TotalSalesAmount = CAST(SUM(CAST(s.Quantity AS DECIMAL(19,4)) * p.Price) AS DECIMAL(19,4)),
        FirstSaleDate    = MIN(s.SaleDate),
        LastSaleDate     = MAX(s.SaleDate)
    FROM Products p
    LEFT JOIN Sales s
      ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID
    GROUP BY p.ProductName;
END
GO

--Вариант «всегда одна строка», даже если продукта не существует

IF OBJECT_ID('dbo.GetProductSalesSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetProductSalesSummary;
GO
CREATE PROCEDURE dbo.GetProductSalesSummary
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH P AS (
        SELECT p.ProductName
        FROM Products p
        WHERE p.ProductID = @ProductID
    )
    SELECT
        P.ProductName,
        TotalQuantity    = CAST(SUM(CAST(s.Quantity AS BIGINT)) AS BIGINT),
        TotalSalesAmount = CAST(SUM(CAST(s.Quantity AS DECIMAL(19,4)) * pr.Price) AS DECIMAL(19,4)),
        FirstSaleDate    = MIN(s.SaleDate),
        LastSaleDate     = MAX(s.SaleDate)
    FROM P
    LEFT JOIN Products pr ON pr.ProductID = @ProductID
    LEFT JOIN Sales s     ON s.ProductID = @ProductID
    GROUP BY P.ProductName;   -- если P пусто (неверный ID) — вернёт 0 строк; чтобы была 1 строка c NULL ProductName, замените P на SELECT CAST(NULL AS NVARCHAR(100)) ProductName
END
GO

--Тесты (из вашего датасета):

EXEC dbo.GetProductSalesSummary @ProductID = 1;   -- есть продажи → суммы и даты
EXEC dbo.GetProductSalesSummary @ProductID = 12;  -- продаж нет → NULL в агрегатах (имя остаётся)
EXEC dbo.GetProductSalesSummary @ProductID = 999; -- продукта нет → 0 строк (или 1 строка с NULL — во 2-м варианте, если так захотите)

--Индексы (рекомендую для реальных данных):

CREATE INDEX IX_Sales_ProductID_SaleDate ON Sales(ProductID, SaleDate) INCLUDE (Quantity);
CREATE UNIQUE INDEX UX_Products_ProductID ON Products(ProductID); -- уже покрыто PK, если он есть


