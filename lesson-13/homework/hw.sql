--13-lesson.

--Easy
-- 1) "100-Steven King"
SELECT CONCAT(EMPLOYEE_ID, '-', FIRST_NAME, ' ', LAST_NAME) AS EmpTag
FROM Employees
WHERE EMPLOYEE_ID = 100;

-- 2) В телефонах заменить подстроку '124' на '999'
UPDATE Employees
SET PHONE_NUMBER = REPLACE(PHONE_NUMBER, '124', '999');

-- 3) Имя и длина имени для имён на A/J/M, сортировка по имени
SELECT FIRST_NAME AS FirstName,
       LEN(FIRST_NAME) AS NameLen
FROM Employees
WHERE LEFT(FIRST_NAME, 1) IN ('A','J','M')
ORDER BY FIRST_NAME;
-- 4) Суммарная зарплата по каждому MANAGER_ID
SELECT MANAGER_ID,
       SUM(SALARY) AS TotalSalary
FROM Employees
GROUP BY MANAGER_ID
ORDER BY MANAGER_ID;

-- 5) По каждой строке TestMax вывести год и максимум из Max1/Max2/Max3
SELECT t.Year1,
       MAX(v.Val) AS MaxOfRow
FROM TestMax t
CROSS APPLY (VALUES (t.Max1),(t.Max2),(t.Max3)) v(Val)
GROUP BY t.Year1
ORDER BY t.Year1;

-- 6) Нечётные фильмы и описание НЕ 'boring'
SELECT *
FROM cinema
WHERE id % 2 = 1
  AND description <> 'boring';

  -- 7) Сортировка по Id, но Id = 0 всегда внизу (одна колонка в ORDER BY)
SELECT *
FROM SingleOrder
ORDER BY IIF(Id = 0, 2147483647, Id);  -- 0 «отправили в конец»

-- 8) Первый ненулевой идентификатор из набора колонок
SELECT id,
       COALESCE(ssn, passportid, itin) AS FirstNonNull
FROM person
ORDER BY id;
--Medium

-- 1) Разбить FullName на First/Middle/Last (исходим из формата из 3 слов)
SELECT StudentID,
       FullName,
       LEFT(FullName, CHARINDEX(' ', FullName) - 1)                       AS FirstName,
       SUBSTRING(
           FullName,
           CHARINDEX(' ', FullName) + 1,
           CHARINDEX(' ', FullName, CHARINDEX(' ', FullName) + 1) - CHARINDEX(' ', FullName) - 1
       )                                                                   AS MiddleName,
       RIGHT(FullName, LEN(FullName) - CHARINDEX(' ', REVERSE(FullName)))  AS LastName
FROM Students
ORDER BY StudentID;

-- 2) Для каждого клиента, который ХОТЯ БЫ РАЗ доставлял в CA,
--    показать его заказы, доставленные в TX
SELECT o.*
FROM Orders o
WHERE o.DeliveryState = 'TX'
  AND o.CustomerID IN (SELECT DISTINCT CustomerID FROM Orders WHERE DeliveryState = 'CA')
ORDER BY o.CustomerID, o.OrderID;

-- 3) Group-concat строк из DMLTable по порядку
-- Вариант для современных версий SQL Server:
SELECT STRING_AGG([String], ' ') WITHIN GROUP (ORDER BY SequenceNumber) AS Concatenated
FROM DMLTable;
-- (Если WITHIN GROUP не поддерживается, запасной вариант)
-- SELECT STUFF((
--   SELECT ' ' + [String]
--   FROM DMLTable
--   ORDER BY SequenceNumber
--   FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') AS Concatenated;

-- 4) Сотрудники, у кого в склеенном имени (first+last) не менее 3 букв 'a'
SELECT *
FROM Employees
WHERE (
  LEN(LOWER(FIRST_NAME + LAST_NAME))
  - LEN(REPLACE(LOWER(FIRST_NAME + LAST_NAME), 'a', ''))
) >= 3;

-- 5) По департаментам: всего сотрудников и % со стажем > 3 лет
SELECT DEPARTMENT_ID,
       COUNT(*) AS EmpCount,
       CAST(100.0 * SUM(CASE WHEN DATEDIFF(YEAR, HIRE_DATE, GETDATE()) > 3 THEN 1 ELSE 0 END) 
            / COUNT(*) AS DECIMAL(5,2)) AS Pct_Tenure_GT_3Y
FROM Employees
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID;

--Difficult

-- 1) Кумулятивная сумма по Grade (заменяем значение строки на сумму всех предыдущих+текущей)
SELECT StudentID,
       FullName,
       Grade,
       SUM(Grade) OVER (ORDER BY StudentID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumGrade
FROM Students
ORDER BY StudentID;

-- 2) Студенты с одинаковым днём рождения
-- Вариант А: список самих студентов, где день встречается > 1 раза
SELECT s.*
FROM Student s
WHERE s.Birthday IN (
  SELECT Birthday
  FROM Student
  GROUP BY Birthday
  HAVING COUNT(*) > 1
)
ORDER BY s.Birthday, s.StudentName;

-- Вариант Б: сгруппированный вид
-- SELECT Birthday, STRING_AGG(StudentName, ', ') AS Students
-- FROM Student
-- GROUP BY Birthday
-- HAVING COUNT(*) > 1
-- ORDER BY Birthday;

-- 3) Сумма очков по уникальной паре игроков (порядок игроков не важен)
WITH Pairs AS (
  SELECT
    PlayerA, PlayerB, Score,
    IIF(PlayerA < PlayerB, PlayerA, PlayerB) AS A1,
    IIF(PlayerA < PlayerB, PlayerB, PlayerA) AS B1
  FROM PlayerScores
)
SELECT A1 AS PlayerMin, B1 AS PlayerMax, SUM(Score) AS TotalScore
FROM Pairs
GROUP BY A1, B1
ORDER BY A1, B1;
-- 4) Разделить 'tf56sd#%OqH' на колонки: ВЕРХНИЕ, нижние, цифры, прочие
DECLARE @s nvarchar(100) = N'tf56sd#%OqH';

WITH Tally(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM Tally WHERE n + 1 <= LEN(@s)
),
Chars AS (
  SELECT n,
         SUBSTRING(@s, n, 1) AS ch
  FROM Tally
)
SELECT
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch COLLATE Latin1_General_CS_AS LIKE '[A-Z]') AS Uppercase,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch COLLATE Latin1_General_CS_AS LIKE '[a-z]') AS Lowercase,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch LIKE '[0-9]')                                         AS Numbers,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch NOT LIKE '[A-Za-z0-9]')                               AS Others;


