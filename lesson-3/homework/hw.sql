--Easy-Level Tasks
--1. Что такое BULK INSERT и его назначение?
--BULK INSERT — команда, которая позволяет массово загружать данные из текстового файла (например, CSV или TXT) в таблицу SQL Server.
--Полезно для загрузки больших объёмов данных быстро и без построчного INSERT.

--2. 4 формата файлов, которые можно импортировать в SQL Server:
--.csv — значения, разделённые запятыми

--.txt — текстовые файлы

--.xls / .xlsx — Excel файлы

--.xml — файлы в формате XML
(через SSMS или Integration Services)

--3. Создать таблицу Products:

CREATE TABLE Products_New (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50),
    Price DECIMAL(10,2)
);

--4. Вставить 3 записи:

INSERT INTO Products (ProductID, ProductName, Price)
VALUES (1, 'Ноутбук', 750.00),
       (2, 'Принтер', 150.00),
       (3, 'Мышка', 20.00);

-- 5. Разница между NULL и NOT NULL:
--NULL — означает "значение неизвестно или отсутствует"

--NOT NULL — колонка обязательно должна иметь значение (нельзя оставить пустой)

--6. Добавить уникальность на ProductName:

ALTER TABLE Products
ADD CONSTRAINT UQ_ProductName UNIQUE (ProductName);

--7. Комментарий в SQL-запросе:

-- Этот запрос добавляет новый столбец CategoryID
ALTER TABLE Products
ADD CategoryID INT;

--8. Добавить колонку CategoryID:

ALTER TABLE Products
ADD CategoryID INT;

--9. Создать таблицу Categories:

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) UNIQUE
);

--10. Что такое IDENTITY и его цель:
--IDENTITY — это автоинкремент для числовых колонок (обычно для ключей).
--Пример: IDENTITY(1,1) означает начинать с 1 и увеличивать на 1 при каждой вставке.

--Medium-Level Tasks
--1. Пример BULK INSERT (загрузка из файла):

BULK INSERT Products
FROM 'C:\Data\products.txt'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',
    FIRSTROW = 2  -- если есть заголовок
);

--2. Создать FOREIGN KEY в Products:

ALTER TABLE Products
ADD CONSTRAINT FK_Category
FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID);

--3. Разница PRIMARY KEY и UNIQUE KEY:
--Характеристика	              PRIMARY KEY	         UNIQUE KEY
--Может быть только один	     ✅ Один на таблицу	    ❌ Может быть несколько
--NULL допустим?	             ❌ Нет	                ✅ Один NULL допустим
--Автоиндексация               	✅ Автоматически    	✅ Автоматически
--Основное назначение	        Уникальный идентификатор	Гарантия у

--4. Добавить CHECK (цена > 0):

ALTER TABLE Products
ADD CONSTRAINT CK_PricePositive CHECK (Price > 0);

--5. Добавить колонку Stock (NOT NULL):

ALTER TABLE Products
ADD Stock INT NOT NULL DEFAULT 0;

--6. Замена NULL в Price на 0 с ISNULL:

SELECT ProductID, ProductName, ISNULL(Price, 0) AS Price
FROM Products;

--7. Назначение FOREIGN KEY:
--FOREIGN KEY устанавливает связь между таблицами, обеспечивая:

--ссылочную целостность (например, нельзя вставить товар с несуществующим CategoryID)

--структуру данных (иерархия, зависимость)

--Hard-Level Tasks
--1. Customers с CHECK Age >= 18:

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Age INT CHECK (Age >= 18)
);

--2. IDENTITY с шагом 10:

CREATE TABLE SequenceTest (
    ID INT IDENTITY(100,10) PRIMARY KEY,
    Name VARCHAR(50)
);

--3. Композитный PRIMARY KEY:

CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);

--4. COALESCE vs ISNULL:
--Функция	                                Особенности
--Функция	Особенности
--ISNULL	                                Только 2 аргумента
--COALESCE                                Можно указать несколько значений: COALESCE(a, b, c) — берёт первое не NULL

--Пример:
SELECT COALESCE(NULL, NULL, 'Товар') AS Result;  -- вернёт 'Товар'

--5. Employees с PRIMARY и UNIQUE:

CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    FullName VARCHAR(100),
    Email VARCHAR(100) UNIQUE
);

--6. FOREIGN KEY с ON DELETE/UPDATE CASCADE:

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);



