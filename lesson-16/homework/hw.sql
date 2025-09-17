--Lesson-16
--Easy

-- 1) Рекурсивная Numbers 1..1000
WITH nums AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM nums WHERE n < 1000
)
SELECT n FROM nums
OPTION (MAXRECURSION 0);

-- 2) Total sales per employee (derived table)  (Sales, Employees)
SELECT e.EmployeeID, e.FirstName, e.LastName, s.SumSales
FROM Employees e
JOIN (
  SELECT EmployeeID, SUM(SalesAmount) AS SumSales
  FROM Sales
  GROUP BY EmployeeID
) s ON s.EmployeeID = e.EmployeeID
ORDER BY s.SumSales DESC;

-- 3) CTE: средняя зарплата сотрудников (Employees)
WITH avg_sal AS (
  SELECT AVG(Salary) AS AvgSalary FROM Employees
)
SELECT AvgSalary FROM avg_sal;
-- 4) Max sales по каждому продукту (derived table) (Sales, Products)
SELECT p.ProductID, p.ProductName, x.MaxSale
FROM Products p
JOIN (
  SELECT ProductID, MAX(SalesAmount) AS MaxSale
  FROM Sales
  GROUP BY ProductID
) x ON x.ProductID = p.ProductID
ORDER BY p.ProductID;

-- 5) Начиная с 1, удваиваем значение пока < 1,000,000 (CTE)
WITH pow2 AS (
  SELECT CAST(1 AS BIGINT) AS val
  UNION ALL
  SELECT val * 2 FROM pow2 WHERE val * 2 < 1000000
)
SELECT val FROM pow2
OPTION (MAXRECURSION 0);

-- 6) CTE: имена сотрудников, совершивших > 5 продаж (Sales, Employees)
WITH sales_cnt AS (
  SELECT EmployeeID, COUNT(*) AS Cnt
  FROM Sales
  GROUP BY EmployeeID
)
SELECT e.EmployeeID, e.FirstName, e.LastName, s.Cnt
FROM sales_cnt s
JOIN Employees e ON e.EmployeeID = s.EmployeeID
WHERE s.Cnt > 5
ORDER BY s.Cnt DESC, e.EmployeeID;
-- 7) CTE: продукты с суммой продаж > $500 (Sales, Products)
WITH prod_sum AS (
  SELECT ProductID, SUM(SalesAmount) AS SumAmt
  FROM Sales
  GROUP BY ProductID
)
SELECT p.ProductID, p.ProductName, ps.SumAmt
FROM prod_sum ps
JOIN Products p ON p.ProductID = ps.ProductID
WHERE ps.SumAmt > 500
ORDER BY p.ProductID;

-- 8) CTE: сотрудники с зарплатой выше среднего (Employees)
WITH avg_sal AS (SELECT AVG(Salary) AS AvgSalary FROM Employees)
SELECT e.*
FROM Employees e
CROSS JOIN avg_sal a
WHERE e.Salary > a.AvgSalary
ORDER BY e.Salary DESC;
--Medium

-- 1) TOP-5 по числу заказов (derived table) (Employees, Sales)
SELECT TOP (5) e.EmployeeID, e.FirstName, e.LastName, s.CntOrders
FROM Employees e
JOIN (
  SELECT EmployeeID, COUNT(*) AS CntOrders
  FROM Sales
  GROUP BY EmployeeID
) s ON s.EmployeeID = e.EmployeeID
ORDER BY s.CntOrders DESC, e.EmployeeID;

-- 2) Продажи по категориям (derived table) (Sales, Products)
SELECT p.CategoryID, SUM(s.SalesAmount) AS SalesByCategory
FROM Sales s
JOIN Products p ON p.ProductID = s.ProductID
GROUP BY p.CategoryID
ORDER BY p.CategoryID;

-- 3) Факториал для каждого значения (Numbers1) — рекурсивно
;WITH R AS (
  SELECT CAST(Number AS INT) AS n,
         CAST(Number AS INT) AS cur,
         CAST(1 AS BIGINT)   AS fact
  FROM Numbers1
  UNION ALL
  SELECT n, cur - 1, fact * (cur - 1)
  FROM R
  WHERE cur > 1
)
SELECT n AS Number, MAX(fact) AS Factorial
FROM R
GROUP BY n
ORDER BY n
OPTION (MAXRECURSION 32767);
-- 4) Рекурсивно «разрезать» строку на символы (Example)
-- Возвращает по каждой строке Example набор её символов с позициями
;WITH chars AS (
  SELECT Id, 1 AS pos, SUBSTRING([String],1,1) AS ch, LEN([String]) AS L
  FROM Example
  UNION ALL
  SELECT Id, pos+1, SUBSTRING([String], pos+1, 1), L
  FROM chars
  WHERE pos < L
)
SELECT Id, pos, ch
FROM chars
ORDER BY Id, pos
OPTION (MAXRECURSION 0);

-- 5) CTE: разница продаж текущего месяца к предыдущему (Sales)
-- Суммируем по месяцам (вся компания)
;WITH m AS (
  SELECT CAST(EOMONTH(SaleDate) AS DATE) AS MonthEnd,
         SUM(SalesAmount) AS SumAmt
  FROM Sales
  GROUP BY CAST(EOMONTH(SaleDate) AS DATE)
),
d AS (
  SELECT MonthEnd, SumAmt,
         LAG(SumAmt) OVER (ORDER BY MonthEnd) AS PrevAmt
  FROM m
)
SELECT MonthEnd, SumAmt, PrevAmt,
       SumAmt - ISNULL(PrevAmt,0) AS DiffFromPrev
FROM d
ORDER BY MonthEnd;

-- 6) Derived table: сотрудники с продажами > 45,000 в каждом квартале (Sales, Employees)
-- Считаем по кварталам 2025 (в примерах даты 2025)
WITH q AS (
  SELECT EmployeeID,
         CONCAT(YEAR(SaleDate), '-Q', DATEPART(QUARTER, SaleDate)) AS YQ,
         SUM(SalesAmount) AS SumQ
  FROM Sales
  GROUP BY EmployeeID, CONCAT(YEAR(SaleDate), '-Q', DATEPART(QUARTER, SaleDate))
),
q25 AS ( -- только кварталы, присутствующие в данных
  SELECT DISTINCT YQ FROM q
)
SELECT e.EmployeeID, e.FirstName, e.LastName
FROM Employees e
WHERE NOT EXISTS (
  SELECT 1
  FROM q25 qx
  WHERE NOT EXISTS (
    SELECT 1
    FROM q
    WHERE q.EmployeeID = e.EmployeeID
      AND q.YQ = qx.YQ
      AND q.SumQ > 45000
  )
);
-- Пояснение: «в каждом квартале» = нет такого квартала из имеющихся, где сотрудник не превысил 45k.
--Difficult

-- 1) Рекурсивные числа Фибоначчи (первые N, напр. 30)
WITH fib AS (
  SELECT 1 AS n, CAST(0 AS BIGINT) AS f
  UNION ALL
  SELECT 2, 1
  UNION ALL
  SELECT n + 1, CAST((SELECT f FROM fib WHERE n = f1.n) + f AS BIGINT)
  FROM (SELECT n, f FROM fib) f1
  WHERE n < 30
)
SELECT n, f
FROM fib
ORDER BY n
OPTION (MAXRECURSION 0);

-- 2) Найти строки, где все символы одинаковые и длина > 1 (FindSameCharacters)
SELECT *
FROM FindSameCharacters
WHERE Vals IS NOT NULL
  AND LEN(Vals) > 1
  AND LEN(Vals) = LEN(REPLACE(Vals, LEFT(Vals,1), ''));
-- Объяснение: удаляем все вхождения первого символа; если длина стала 0 -> все символы одинаковые.

-- 3) «Лестница» 1, 12, 123, ... до n (пример n=5)
DECLARE @n INT = 5;
WITH nums AS (
  SELECT 1 AS k
  UNION ALL
  SELECT k + 1 FROM nums WHERE k < @n
),
build AS (
  SELECT k,
         CAST('1' AS VARCHAR(100)) AS s
  FROM nums WHERE k = 1
  UNION ALL
  SELECT n.k,
         CAST(b.s + CAST(n.k AS VARCHAR(10)) AS VARCHAR(100))
  FROM build b
  JOIN nums n ON n.k = b.k + 1
)
SELECT k, s
FROM build
ORDER BY k
OPTION (MAXRECURSION 0);
-- 4) Derived table: сотрудники с наибольшими продажами за последние 6 месяцев (Employees, Sales)
-- Берём окно от (MAX(SaleDate) - 6 мес) включительно
DECLARE @cut DATE = DATEADD(MONTH, -6, (SELECT MAX(SaleDate) FROM Sales));

WITH recent AS (
  SELECT EmployeeID, SUM(SalesAmount) AS SumRecent
  FROM Sales
  WHERE SaleDate >= @cut
  GROUP BY EmployeeID
),
mx AS (
  SELECT MAX(SumRecent) AS MaxRecent FROM recent
)
SELECT e.EmployeeID, e.FirstName, e.LastName, r.SumRecent
FROM recent r
JOIN mx ON r.SumRecent = mx.MaxRecent
JOIN Employees e ON e.EmployeeID = r.EmployeeID
ORDER BY e.EmployeeID;

-- 5) RemoveDuplicateIntsFromNames:
-- «Убрать дубль-цифры в числовой части и удалить одиночную цифру».
-- Принцип:
--   - берём хвост после '-'
--   - сжимаем подряд идущие одинаковые цифры (111 -> 1, 4444 -> 4)
--   - если в итоге длина = 1, полностью удаляем числовую часть (и сам '-')
;WITH src AS (
  SELECT PawanName, Pawan_slug_name,
         CHARINDEX('-', Pawan_slug_name) AS dashpos
  FROM RemoveDuplicateIntsFromNames
),
split AS (
  SELECT PawanName,
         LEFT(Pawan_slug_name, CASE WHEN dashpos>0 THEN dashpos-1 ELSE LEN(Pawan_slug_name) END) AS prefix,
         CASE WHEN dashpos>0 THEN SUBSTRING(Pawan_slug_name, dashpos+1, 1000) ELSE '' END AS numpart
  FROM src
),
-- распиливаем только цифроблок; игнорируем любые нецифровые символы по условию задачи
tally AS (
  SELECT PawanName, 1 AS n FROM split
  UNION ALL
  SELECT PawanName, n+1 FROM tally t
  JOIN split s ON s.PawanName = t.PawanName
  WHERE n+1 <= LEN(s.numpart)
),
chars AS (
  SELECT s.PawanName, s.prefix, s.numpart,
         n, SUBSTRING(s.numpart, n, 1) AS ch
  FROM split s
  JOIN tally t ON t.PawanName = s.PawanName
),
only_digits AS (
  SELECT *, CASE WHEN ch LIKE '[0-9]' THEN 1 ELSE 0 END AS isDigit
  FROM chars
),
compressed AS (
  SELECT c.PawanName, c.prefix,
         STRING_AGG(c.ch, '') WITHIN GROUP (ORDER BY c.n)
           FILTER (WHERE c.isDigit = 1 AND
                        (c.n = 1 OR c.ch <> LAG(c.ch) OVER (PARTITION BY c.PawanName ORDER BY c.n)))
           AS digits_comp
  FROM only_digits c
  GROUP BY c.PawanName, c.prefix
),
final AS (
  SELECT PawanName,
         CASE 
           WHEN digits_comp IS NULL OR LEN(digits_comp) = 0 OR LEN(digits_comp) = 1
                THEN prefix                                   -- удаляем хвост
           ELSE prefix + '-' + digits_comp
         END AS Cleaned
  FROM compressed
)
SELECT * FROM final
ORDER BY PawanName
OPTION (MAXRECURSION 0);
-- Примеры ожидаемого эффекта:
-- 'PawanA-111'  -> 'PawanA'         (111 -> 1 -> удаляем)
-- 'PawanC-4444' -> 'PawanC'         (4444 -> 4 -> удаляем)
-- 'PawanD-3'    -> 'PawanD'         (одиночная цифра -> удаляем)
-- 'PawanB-123'  -> 'PawanB-123'     (нет подряд дублей, длина >1 -> оставляем)
-- 'PawanB-32'   -> 'PawanB-32'
