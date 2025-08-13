--Puzzle 1 — Distinct по двум колонкам
--Вариант 1 — DISTINCT

SELECT DISTINCT col1, col2
FROM InputTbl;

--2.Вариант 2 — через сортировку внутри пары

SELECT MIN(col1) AS col1, MAX(col2) AS col2
FROM InputTbl
GROUP BY 
    CASE WHEN col1 < col2 THEN col1 ELSE col2 END,
    CASE WHEN col1 < col2 THEN col2 ELSE col1 END;

    --Puzzle 2 — Удалить строки, где все колонки = 0

    SELECT *
FROM TestMultipleZero
WHERE COALESCE(A,0) <> 0
   OR COALESCE(B,0) <> 0
   OR COALESCE(C,0) <> 0
   OR COALESCE(D,0) <> 0;


   --Puzzle 3 — Найти с нечётными id

   SELECT *
FROM section1
WHERE id % 2 = 1;

--Puzzle 4 — Человек с минимальным id

SELECT TOP 1 *
FROM section1
ORDER BY id ASC;

--Puzzle 5 — Человек с максимальным id

SELECT TOP 1 *
FROM section1
ORDER BY id DESC;

--Puzzle 6 — Имена, начинающиеся с b (без учёта регистра)

SELECT *
FROM section1
WHERE name LIKE 'B%';

--В SQL Server регистр в LIKE зависит от collation, обычно нечувствителен.

--Puzzle 7 — Строки, где есть именно символ _

--В LIKE _ — это спецсимвол, поэтому нужно экранировать:

SELECT *
FROM ProductCodes
WHERE Code LIKE '%\_%' ESCAPE '\';

--Здесь \ объявлен как символ экранирования, чтобы _ искался буквально.

