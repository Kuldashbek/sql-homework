--Easy
--1. Определения:
--Data (данные): Сырые факты или значения, которые можно хранить и обрабатывать. Например: имена, даты рождения, суммы.
--Database (база данных): Организованный набор данных, хранящихся в структурированной форме.
--Relational database (реляционная база данных): База данных, основанная на таблицах (relations), где данные связаны между собой с помощью ключей.
--Table (таблица): Основная структура хранения данных в базе данных, состоящая из строк и столбцов.

--2. 5 ключевых особенностей SQL Server:
--1.Надежность и масштабируемость.
--2.Поддержка транзакций (ACID).
--3.Интеграция с SSMS и Visual Studio.
--4.Поддержка хранимых процедур, триггеров и функций.
--5.Безопасность — контроль доступа, шифрование, аудит.

--3. Режимы аутентификации SQL Server:
--Windows Authentication: Использует учетную запись Windows.
--SQL Server Authentication: Требует имя пользователя и пароль, определенные в SQL Server.

--Medium
--4. Создание базы данных:

CREATE DATABASE SchoolDB;

--5. Создание таблицы Students:

USE SchoolDB;

CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    Name VARCHAR(50),
    Age INT
);

--6. Разница между SQL Server, SSMS и SQL:
--SQL Server	СУБД, где хранятся и управляются базы данных.
--SSMS SQL Server Management Studio — инструмент (GUI) для работы с SQL Server.
--SQL Язык запросов для управления данными (SELECT, INSERT и т.д.).

--Hard
--7. Типы SQL-команд:
--Категория	Название	Примеры	Назначение
--Категория	Название	Примеры	Назначение
--DQL	Data Query Language	SELECT	Чтение данных
--DML	Data Manipulation Language	INSERT, UPDATE, DELETE	Работа с данными
--DDL	Data Definition Language	CREATE, ALTER, DROP	Работа со структурами
--DCL	Data Control Language	GRANT, REVOKE	Управление доступом
--TCL	Transaction Control Language	COMMIT, ROLLBACK, SAVEPOINT	Управление транзакциями

--8. Вставка 3 записей в Students:

INSERT INTO Students (StudentID, Name, Age)
VALUES 
(1, 'Ali', 20),
(2, 'Diyorah', 19),
(3, 'Mehribon', 21);

select * from Students
