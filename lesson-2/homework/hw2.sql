--1. Создание таблицы Employees

CREATE TABLE Employees_New (
    EmpID INT,
    Name VARCHAR(50),
    Salary DECIMAL(10,2)
);
drop table Employees_New
--2. Вставка 3 записей разными способами

-- Одинарная вставка
INSERT INTO Employees_New (EmpID, Name, Salary)
VALUES (1, 'Ali Karimov', 6500.00);

-- Множественная вставка (одним запросом)
INSERT INTO Employees_New  (EmpID, Name, Salary)
VALUES 
(2, 'Dilnoza Tursunova', 5800.00),
(3, 'Farruh Umarov', 7200.00);

--3. Обновление зарплаты

UPDATE Employees_New 
SET Salary = 7000
WHERE EmpID = 1;

--4. Удаление записи по ID

DELETE FROM Employees_New 
WHERE EmpID = 2;

--5. Разница между DELETE, TRUNCATE и DROP

--Команда	Что делает	                       Можно откатить (ROLLBACK)?	Сохраняет структуру?
--DELETE	Удаляет строки с условиями (WHERE)                	✅ Да	         ✅ Да
--TRUNCATE	Удаляет все строки без условий	                    ❌ Нет         	✅ Да
--DROP	Полностью удаляет таблицу	                            ❌ Нет	        ❌ Нет

--6. Изменить длину столбца Name

ALTER TABLE Employees_New 
ALTER COLUMN Name VARCHAR(100);

--7. Добавить колонку Department

ALTER TABLE Employees_New 
ADD Department VARCHAR(50);

--8. Изменить тип Salary на FLOAT

ALTER TABLE Employees_New 
ALTER COLUMN Salary FLOAT;

--9. Создать таблицу Departments

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);

--10. Удалить все записи, но оставить структуру таблицы

TRUNCATE TABLE Employees_New;

--Intermediate-Level Tasks (6)1. Вставка 5 записей с использованием INSERT INTO SELECT

-- Вставка из временной таблицы
INSERT INTO Departments (DepartmentID, DepartmentName)
SELECT 1, 'Accounting'
UNION ALL
SELECT 2, 'Finance'
UNION ALL
SELECT 3, 'HR'
UNION ALL
SELECT 4, 'Marketing'
UNION ALL
SELECT 5, 'IT';

--2. Обновить департамент у сотрудников с зарплатой > 5000

UPDATE Employees_New 
SET Department = 'Management'
WHERE Salary > 5000;

--3. Удалить всех сотрудников, но сохранить структуру

TRUNCATE TABLE Employees_New;

--4. Удалить колонку Department

ALTER TABLE Employees_New 
DROP COLUMN Department;

--5. Переименовать Employees в StaffMembers

EXEC sp_rename 'Employees_New ', 'StaffMembers';

--6. Удалить таблицу Departments

DROP TABLE Departments;

--Advanced-Level Tasks (9)

--1. Создать таблицу Products

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Description VARCHAR(255)
);

--2. Добавить ограничение CHECK на цену

ALTER TABLE Products
ADD CONSTRAINT chk_price_positive CHECK (Price > 0);

--3. Добавить колонку StockQuantity с DEFAULT

ALTER TABLE Products
ADD StockQuantity INT DEFAULT 50;

--4. Переименовать колонку Category → ProductCategory

EXEC sp_rename 'Products.Category', 'ProductCategory', 'COLUMN';

--5. Вставить 5 записей

INSERT INTO Products (ProductID, ProductName, ProductCategory, Price, Description)
VALUES
(1, 'Laptop', 'Electronics', 1500.00, 'Gaming laptop'),
(2, 'Mouse', 'Electronics', 25.50, 'Wireless mouse'),
(3, 'Notebook', 'Stationery', 2.00, 'College ruled'),
(4, 'Chair', 'Furniture', 85.99, 'Ergonomic'),
(5, 'Pen', 'Stationery', 1.50, 'Gel pen');

--6. Создать backup-таблицу через SELECT INTO

SELECT * INTO Products_Backup
FROM Products;

--7. Переименовать таблицу Products в Inventory

EXEC sp_rename 'Products', 'Inventory';

--8. Изменить тип Price на FLOAT

ALTER TABLE Inventory
ALTER COLUMN Price FLOAT;

--9. Добавить колонку ProductCode с IDENTITY

ALTER TABLE Inventory
ADD ProductCode INT IDENTITY(1000,5);
