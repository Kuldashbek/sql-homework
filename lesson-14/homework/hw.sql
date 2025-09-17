--Easy

-- 1) Split Name -> Name, Surname (TestMultipleColumns)
SELECT Id,
       LTRIM(RTRIM(LEFT(Name, CHARINDEX(',', Name) - 1)))   AS Name,
       LTRIM(RTRIM(SUBSTRING(Name, CHARINDEX(',', Name)+1, 200))) AS Surname
FROM TestMultipleColumns
ORDER BY Id;

-- 2) Строки, где есть символ % (TestPercent)
SELECT *
FROM TestPercent
WHERE Strs LIKE '%!%%' ESCAPE '!';

-- 3) Разбить строку по точке в строки-токены (Splitter)
SELECT s.Id, t.ordinal, t.value AS token
FROM Splitter s
CROSS APPLY STRING_SPLIT(s.Vals, '.', 1) AS t
ORDER BY s.Id, t.ordinal;
-- 4) Строки, где более двух точек (testDots)
SELECT *
FROM testDots
WHERE (LEN(Vals) - LEN(REPLACE(Vals, '.', ''))) > 2
ORDER BY ID;

-- 5) Посчитать количество пробелов (CountSpaces)
SELECT texts,
       (LEN(texts) - LEN(REPLACE(texts, ' ', ''))) AS SpaceCount
FROM CountSpaces;

-- 6) Сотрудники, чья зарплата > зарплаты их менеджеров (Employee)
SELECT e.Id, e.Name, e.Salary, e.ManagerId
FROM Employee e
JOIN Employee m ON m.Id = e.ManagerId
WHERE e.Salary > m.Salary
ORDER BY e.Id;
-- 7) Стаж >10 и <15 лет (Employees) + точные «полные годы»
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, HIRE_DATE,
       DATEDIFF(YEAR, HIRE_DATE, GETDATE())
       - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, HIRE_DATE, GETDATE()), HIRE_DATE) > GETDATE()
              THEN 1 ELSE 0 END AS YearsOfService
FROM Employees
WHERE HIRE_DATE <  DATEADD(YEAR, -10, GETDATE())   -- строго больше 10 лет
  AND HIRE_DATE >= DATEADD(YEAR, -15, GETDATE())   -- строго меньше 15 лет
ORDER BY HIRE_DATE;

--Medium

-- 1) Более тёплый день, чем вчера (weather)
SELECT Id, RecordDate, Temperature
FROM (
  SELECT w.*,
         LAG(Temperature) OVER (ORDER BY RecordDate) AS prev_temp,
         LAG(RecordDate)  OVER (ORDER BY RecordDate) AS prev_date
  FROM weather w
) x
WHERE x.prev_date = DATEADD(DAY, -1, x.RecordDate)
  AND x.Temperature > x.prev_temp
ORDER BY RecordDate;

-- 2) Первая дата логина каждого игрока (Activity)
SELECT player_id, MIN(event_date) AS first_login_date
FROM Activity
GROUP BY player_id
ORDER BY player_id;

-- 3) Вернуть третий элемент из списка (fruits)
SELECT TRIM(value) AS third_item
FROM fruits
CROSS APPLY STRING_SPLIT(fruit_list, ',', 1) s
WHERE s.ordinal = 3;
-- (альтернатива без ordinal)
-- SELECT PARSENAME(REPLACE(fruit_list, ',', '.'), 2) FROM fruits;
-- 4) Employment Stage по дате найма (Employees)
WITH E AS (
  SELECT *,
         DATEDIFF(YEAR, HIRE_DATE, GETDATE())
         - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, HIRE_DATE, GETDATE()), HIRE_DATE) > GETDATE()
                THEN 1 ELSE 0 END AS YearsFull
  FROM Employees
)
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, HIRE_DATE, YearsFull,
       CASE
         WHEN YearsFull < 1  THEN 'New Hire'
         WHEN YearsFull < 5  THEN 'Junior'
         WHEN YearsFull < 10 THEN 'Mid-Level'
         WHEN YearsFull < 20 THEN 'Senior'
         ELSE 'Veteran'
       END AS EmploymentStage
FROM E
ORDER BY EMPLOYEE_ID;

-- 5) Целое число в начале строки (GetIntegers)
SELECT Id, VALS,
       CASE
         WHEN VALS IS NULL OR VALS = '' OR LEFT(VALS,1) NOT LIKE '[0-9]' THEN NULL
         ELSE CAST(LEFT(VALS,
                        CASE WHEN PATINDEX('%[^0-9]%', VALS) = 0
                             THEN LEN(VALS)
                             ELSE PATINDEX('%[^0-9]%', VALS) - 1 END) AS INT)
       END AS LeadingInt
FROM GetIntegers
ORDER BY Id;

--Difficult

-- 1) Поменять местами первые два элемента в CSV-строке (MultipleVals)
WITH t AS (
  SELECT Id, Vals,
         CHARINDEX(',', Vals) AS p1
  FROM MultipleVals
),
t2 AS (
  SELECT Id, Vals, p1,
         CHARINDEX(',', SUBSTRING(Vals, p1+1, 1000)) AS p2rel
  FROM t
),
parts AS (
  SELECT Id, Vals, p1,
         CASE WHEN p1>0 THEN LEFT(Vals, p1-1) ELSE Vals END AS a1,
         CASE WHEN p1>0 AND p2rel>0 THEN LEFT(SUBSTRING(Vals, p1+1, 1000), p2rel-1)
              WHEN p1>0 THEN SUBSTRING(Vals, p1+1, 1000) END AS a2,
         CASE WHEN p1>0 AND p2rel>0 THEN SUBSTRING(Vals, p1+1+p2rel, 1000) ELSE '' END AS rest
  FROM t2
)
SELECT Id,
       CASE
         WHEN p1 = 0 THEN Vals
         WHEN rest = '' THEN CONCAT(a2, ',', a1)           -- было "x,y"
         ELSE CONCAT(a2, ',', a1, ',', rest)               -- было "x,y,...."
       END AS Swapped
FROM parts
ORDER BY Id;

-- 2) Каждый символ строки -> отдельная строка с позицией
DECLARE @s nvarchar(100) = N'sdgfhsdgfhs@121313131';

WITH Tally(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM Tally WHERE n+1 <= LEN(@s)
)
SELECT n AS pos, SUBSTRING(@s, n, 1) AS ch
FROM Tally
ORDER BY n
OPTION (MAXRECURSION 0);

-- 3) Устройство первого логина для каждого игрока (Activity)
WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY event_date, device_id) AS rn
  FROM Activity
)
SELECT player_id, device_id, event_date
FROM ranked
WHERE rn = 1
ORDER BY player_id;

-- 4) Из строки 'rtcfvty34redt' разнести цифры и буквы по разным колонкам
DECLARE @s nvarchar(100) = N'rtcfvty34redt';

WITH Tally(n) AS (
  SELECT 1
  UNION ALL
  SELECT n+1 FROM Tally WHERE n+1 <= LEN(@s)
),
Chars AS (
  SELECT SUBSTRING(@s, n, 1) AS ch, n
  FROM Tally
)
SELECT
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch LIKE '[0-9]')     AS DigitsOnly,
  (SELECT STRING_AGG(ch, '') WITHIN GROUP (ORDER BY n) FROM Chars WHERE ch LIKE '[A-Za-z]')  AS LettersOnly;
