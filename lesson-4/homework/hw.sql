--Easy-Level Задания:
--1.Top 5 сотрудников:

SELECT TOP 5 * FROM Employees;

--2.Уникальные категории из Products:

SELECT DISTINCT Category FROM Products;

--3.Продукты с ценой больше 100:

SELECT * FROM Products WHERE Price > 100;

--4.Клиенты, имя которых начинается с "A":

SELECT * FROM Customers WHERE FirstName LIKE 'A%';

--5.Сортировка по цене по возрастанию:

SELECT * FROM Products ORDER BY Price ASC;

--6.Сотрудники с зарплатой >= 60000 и из HR:

SELECT * FROM Employees 
WHERE Salary >= 60000 AND DepartmentName = 'HR';

--7.Замена NULL в Email на 'noemail@example.com':

SELECT ISNULL(Email, 'noemail@example.com') AS Email, * 
FROM Employees;

--8.Продукты с ценой между 50 и 100:

SELECT * FROM Products WHERE Price BETWEEN 50 AND 100;

--9.DISTINCT по двум колонкам:

SELECT DISTINCT Category, ProductName FROM Products;

--10.DISTINCT + сортировка по имени убыванию:

SELECT DISTINCT Category, ProductName 
FROM Products 
ORDER BY ProductName DESC;

--Medium-Level Задания:
--1.Top 10 продуктов по цене (убыв.):

SELECT TOP 10 * FROM Products ORDER BY Price DESC;

--2.COALESCE для имени сотрудника:

SELECT COALESCE(FirstName, LastName) AS Name, * 
FROM Employees;

--3.DISTINCT Category и Price:

SELECT DISTINCT Category, Price FROM Products;

--4.Сотрудники возраст 30–40 или из Marketing:

SELECT * FROM Employees 
WHERE (Age BETWEEN 30 AND 40) OR DepartmentName = 'Marketing';

--5.OFFSET-FETCH: строки с 11 по 20:

SELECT * FROM Employees 
ORDER BY Salary DESC 
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

--6.Товары: Цена <= 1000 и Stock > 50:

SELECT * FROM Products 
WHERE Price <= 1000 AND StockQuantity > 50 
ORDER BY StockQuantity ASC;

--7.Имя продукта содержит букву 'e':

SELECT * FROM Products 
WHERE ProductName LIKE '%e%';

--8.Сотрудники из HR, IT или Finance:

SELECT * FROM Employees 
WHERE DepartmentName IN ('HR', 'IT', 'Finance');

--9.Клиенты по City (ASC) и PostalCode (DESC):

SELECT * FROM Customers 
ORDER BY City ASC, PostalCode DESC;

--Hard-Level Tasks:
--1.Выбрать 5 продуктов с наибольшими продажами (SalesAmount):

SELECT TOP 5 p.ProductName, SUM(s.SaleAmount) AS TotalSales
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSales DESC;

--2. Объединить FirstName и LastName в FullName:

SELECT 
    CONCAT(ISNULL(FirstName, ''), ' ', ISNULL(LastName, '')) AS FullName, *
FROM Employees;


--3. DISTINCT по Category, ProductName и Price > 50:

SELECT DISTINCT Category, ProductName, Price
FROM Products
WHERE Price > 50;

--4. Продукты, цена которых < 10% от средней цены:

SELECT * FROM Products
WHERE Price < (SELECT AVG(Price) * 0.10 FROM Products);

--5. Сотрудники моложе 30 из HR или IT:

SELECT * FROM Employees
WHERE Age < 30 AND DepartmentName IN ('HR', 'IT');

--6. Email содержит '@gmail.com':

SELECT * FROM Customers
WHERE Email LIKE '%@gmail.com%';

--7. Сотрудники, чья зарплата больше всех в отделе Sales:

SELECT * FROM Employees
WHERE Salary > ALL (
    SELECT Salary FROM Employees WHERE DepartmentName = 'Marketing'
);

--8. Заказы за последние 180 дней (относительно текущей даты):

SELECT * FROM Orders
WHERE OrderDate BETWEEN DATEADD(DAY, -180, GETDATE()) AND GETDATE();

