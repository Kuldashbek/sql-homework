--1) Все дистрибьюторы × все регионы, пропуски → 0

-- Исходная #RegionSales у вас уже создана

WITH R AS (SELECT DISTINCT Region FROM #RegionSales),
     D AS (SELECT DISTINCT Distributor FROM #RegionSales)
SELECT
    R.Region,
    D.Distributor,
    ISNULL(S.Sales, 0) AS Sales
FROM R
CROSS JOIN D
LEFT JOIN #RegionSales S
  ON S.Region = R.Region AND S.Distributor = D.Distributor
ORDER BY
    D.Distributor,
    CASE R.Region
        WHEN 'North' THEN 1
        WHEN 'South' THEN 2
        WHEN 'East'  THEN 3
        WHEN 'West'  THEN 4
        ELSE 5
    END;
    --2) Менеджеры с ≥ 5 прямыми подчинёнными

    -- Таблица Employee у вас создана

SELECT e.name
FROM Employee e
WHERE e.id IN (
    SELECT managerId
    FROM Employee
    WHERE managerId IS NOT NULL
    GROUP BY managerId
    HAVING COUNT(*) >= 5
);

--3) Товары с суммой заказов ≥ 100 ед. за февраль-2020

-- Таблицы Products и Orders у вас созданы/заполнены

SELECT
    p.product_name,
    SUM(o.unit) AS unit
FROM Orders o
JOIN Products p ON p.product_id = o.product_id
WHERE o.order_date >= '2020-02-01'
  AND o.order_date <  '2020-03-01'
GROUP BY p.product_name
HAVING SUM(o.unit) >= 100
ORDER BY p.product_name;
--4) Поставщик, у которого каждый клиент сделал больше всего заказов

-- Таблица Orders (OrderID, CustomerID, [Count], Vendor)

WITH C AS (
    SELECT CustomerID, Vendor, COUNT(*) AS cnt
    FROM Orders
    GROUP BY CustomerID, Vendor
),
R AS (
    SELECT
        CustomerID, Vendor, cnt,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY cnt DESC, Vendor) AS rn
    FROM C
)
SELECT CustomerID, Vendor
FROM R
WHERE rn = 1
ORDER BY CustomerID;

--5) Проверка простого числа (@Check_Prime)

DECLARE @Check_Prime INT = 91;   -- поменяйте на своё число
DECLARE @i INT = 2;
DECLARE @isPrime BIT = 1;

IF @Check_Prime < 2
    SET @isPrime = 0;
ELSE
BEGIN
    WHILE (@i * @i) <= @Check_Prime
    BEGIN
        IF (@Check_Prime % @i = 0)
        BEGIN
            SET @isPrime = 0;
            BREAK;
        END
        SET @i += 1;
    END
END

SELECT CASE WHEN @isPrime = 1
            THEN 'This number is prime'
            ELSE 'This number is not prime'
       END AS Result;
       --6) По устройству: кол-во локаций, локация с максимум сигналов, всего сигналов

       -- Таблица Device (Device_id, Locations)

WITH per_loc AS (
    SELECT Device_id, Locations, COUNT(*) AS cnt
    FROM Device
    GROUP BY Device_id, Locations
),
max_loc AS (
    SELECT
        Device_id, Locations, cnt,
        ROW_NUMBER() OVER (PARTITION BY Device_id ORDER BY cnt DESC, Locations) AS rn
    FROM per_loc
),
loc_cnt AS (
    SELECT Device_id, COUNT(*) AS no_of_location
    FROM per_loc
    GROUP BY Device_id
),
sig_tot AS (
    SELECT Device_id, SUM(cnt) AS no_of_signals
    FROM per_loc
    GROUP BY Device_id
)
SELECT
    m.Device_id,
    l.no_of_location,
    m.Locations AS max_signal_location,
    s.no_of_signals
FROM max_loc m
JOIN loc_cnt l ON l.Device_id = m.Device_id
JOIN sig_tot s ON s.Device_id = m.Device_id
WHERE m.rn = 1
ORDER BY m.Device_id;
--7) Сотрудники с зарплатой ≥ среднего по своему отделу

-- Таблица Employee (EmpID, EmpName, Salary, DeptID)

SELECT EmpID, EmpName, Salary
FROM Employee e
WHERE Salary >= (
    SELECT AVG(Salary)
    FROM Employee x
    WHERE x.DeptID = e.DeptID
)
ORDER BY EmpID;

--8) Лотерея: суммарный выигрыш по сегодняшней жеребьёвке

-- Таблицы Numbers(Number) и Tickets(TicketID, Number) у вас созданы/заполнены

WITH all_t AS (
    SELECT DISTINCT TicketID FROM Tickets
),
matches AS (
    SELECT t.TicketID, COUNT(DISTINCT t.Number) AS m
    FROM Tickets t
    JOIN Numbers n ON n.Number = t.Number
    GROUP BY t.TicketID
),
final AS (
    SELECT a.TicketID, ISNULL(m.m, 0) AS m
    FROM all_t a
    LEFT JOIN matches m ON m.TicketID = a.TicketID
),
wn AS (
    SELECT COUNT(*) AS total_needed FROM Numbers
)
SELECT SUM(
           CASE
               WHEN f.m = wn.total_needed THEN 100
               WHEN f.m BETWEEN 1 AND wn.total_needed - 1 THEN 10
               ELSE 0
           END
       ) AS TotalWinnings
FROM final f CROSS JOIN wn;
--9) Траты по платформам: Mobile, Desktop и Both на каждую дату

-- Таблица Spending (User_id, Spend_date, Platform, Amount)

WITH per_platform AS (
    SELECT
        Spend_date,
        Platform,
        SUM(Amount) AS Total_Amount,
        COUNT(DISTINCT User_id) AS Total_users
    FROM Spending
    GROUP BY Spend_date, Platform
),
both_platform AS (
    SELECT
        Spend_date,
        'Both' AS Platform,
        SUM(Amount) AS Total_Amount,
        COUNT(DISTINCT User_id) AS Total_users
    FROM Spending
    GROUP BY Spend_date
),
unioned AS (
    SELECT * FROM per_platform
    UNION ALL
    SELECT * FROM both_platform
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY Spend_date,
                 CASE Platform WHEN 'Mobile' THEN 1 WHEN 'Desktop' THEN 2 ELSE 3 END
    ) AS [Row],
    Spend_date,
    Platform,
    Total_Amount,
    Total_users
FROM unioned
ORDER BY Spend_date,
         CASE Platform WHEN 'Mobile' THEN 1 WHEN 'Desktop' THEN 2 ELSE 3 END;

         --10) «Разгруппировать» строки (раскатать количество в единицы)

         -- Таблица Grouped у вас создана/заполнена

WITH Tally AS (
    SELECT Product, Quantity, 1 AS n
    FROM Grouped
    UNION ALL
    SELECT Product, Quantity, n + 1
    FROM Tally
    WHERE n < Quantity
)
SELECT Product, 1 AS Quantity
FROM Tally
ORDER BY Product
OPTION (MAXRECURSION 0);

