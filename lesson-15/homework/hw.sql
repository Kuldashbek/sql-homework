--Level 1 — Basic Subqueries

-- 1) Employees with MIN salary
SELECT *
FROM employees e
WHERE e.salary = (SELECT MIN(salary) FROM employees);

-- 2) Products priced above AVG price
SELECT *
FROM products p
WHERE p.price > (SELECT AVG(price) FROM products);

--Level 2 — Nested Subqueries with Conditions

-- 3) Employees in "Sales" department
SELECT *
FROM employees e
WHERE e.department_id = (
    SELECT d.id FROM departments d WHERE d.department_name = 'Sales'
);
-- (эквивалент через EXISTS)
-- SELECT e.*
-- FROM employees e
-- WHERE EXISTS (
--   SELECT 1 FROM departments d
--   WHERE d.id = e.department_id AND d.department_name = 'Sales'
-- );
-- 4) Customers with NO orders
SELECT c.*
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

--Level 3 — Aggregation & Grouping in Subqueries

-- 5) Products with MAX price per category
SELECT p.*
FROM products p
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
);

-- 6) Employees in the department with the HIGHEST AVG salary
-- (считаем департаменты с максимальным средним; поддерживает «ничьи»)
SELECT e.*
FROM employees e
WHERE e.department_id IN (
    SELECT TOP 1 WITH TIES department_id
    FROM employees
    GROUP BY department_id
    ORDER BY AVG(salary) DESC
);

--Level 4 — Correlated Subqueries

-- 7) Employees earning ABOVE their dept average
SELECT e.*
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- 8) Students with HIGHEST grade per course
SELECT s.student_id, s.name, g.course_id, g.grade
FROM grades g
JOIN students s ON s.student_id = g.student_id
WHERE g.grade = (
    SELECT MAX(g2.grade)
    FROM grades g2
    WHERE g2.course_id = g.course_id
)
ORDER BY g.course_id, s.student_id;
--Level 5 — Ranking & Complex Conditions via Subqueries

-- 9) THIRD-highest price per category
-- (у «третьей по величине» цены ровно две более высоких уникальных цены в той же категории)
SELECT p.*
FROM products p
WHERE 2 = (
    SELECT COUNT(DISTINCT p2.price)
    FROM products p2
    WHERE p2.category_id = p.category_id
      AND p2.price > p.price
);

-- 10) Salary BETWEEN company AVG and dept MAX (exclusive верхняя граница)
SELECT e.*
FROM employees e
WHERE e.salary > (SELECT AVG(salary) FROM employees)                            -- выше средней по компании
  AND e.salary < (SELECT MAX(e2.salary) FROM employees e2                       -- ниже максимума своего департамента
                  WHERE e2.department_id = e.department_id);
