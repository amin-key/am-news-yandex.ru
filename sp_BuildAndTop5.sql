CREATE OR ALTER PROC dbo.BuildAndTop5
AS
BEGIN
  SET NOCOUNT ON;

  -- 1) Чистим, если уже есть
  IF OBJECT_ID('dbo.orders','U') IS NOT NULL DROP TABLE dbo.orders;
  IF OBJECT_ID('dbo.clients','U') IS NOT NULL DROP TABLE dbo.clients;
  IF OBJECT_ID('dbo.goods','U')   IS NOT NULL DROP TABLE dbo.goods;

  -- 2) Справочники
  CREATE TABLE dbo.clients(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL UNIQUE
  );

  INSERT INTO dbo.clients(name)
  VALUES (N'Иван'),(N'Федор'),(N'Степан'),(N'Марья'),(N'Антон'),
         (N'Николай'),(N'Петр'),(N'Анна'),(N'Мария'),(N'Дмитрий');

  CREATE TABLE dbo.goods(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE
  );

  INSERT INTO dbo.goods(name)
  VALUES (N'Масло моторное'),
         (N'Масло трансмиссионное'),
         (N'Антифриз'),
         (N'Жидкость тормозная'),
         (N'Стекло лобовое'),
         (N'Колодки тормозные'),
         (N'Бампер'),
         (N'Свеча зажигания'),
         (N'Аккумулятор'),
         (N'Фильтр масляный'),
         (N'Фильтр воздушный');

  -- 3) Факт
  CREATE TABLE dbo.orders(
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    good_id   INT NOT NULL
  );


  -- 4) Массовая вставка 1 000 000 записей сетевым способом
  ;WITH
  tally AS (
    SELECT TOP (1000000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
  ),
  rng AS (
    -- простые псевдослучайные распределения по справочникам
    SELECT
      n,
      ((ABS(CHECKSUM(NEWID())) % 10) + 1)  AS client_id,  -- 1..10
      ((ABS(CHECKSUM(NEWID())) % 11) + 1)  AS good_id     -- 1..11
    FROM tally
  )
  INSERT INTO dbo.orders(client_id, good_id)
  SELECT r.client_id, r.good_id
  FROM rng r;

  CREATE NONCLUSTERED INDEX IX_orders_good_id ON dbo.orders (good_id);
  CREATE NONCLUSTERED INDEX IX_orders_client_id ON dbo.orders(client_id);

  -- Обновим статистику (опционально для стабильного плана)
  UPDATE STATISTICS dbo.orders WITH FULLSCAN;

  -- Топ-5 клиентов по числу заказов
  SELECT TOP (5)
         c.name AS Клиент,
         COUNT_BIG(*) AS КоличествоЗаказов
  FROM dbo.orders o
  JOIN dbo.clients c ON c.id = o.client_id
  GROUP BY c.name
  ORDER BY КоличествоЗаказов DESC;

  -- 7) Удалить таблицы (если требуется)
  DROP TABLE dbo.orders;
  DROP TABLE dbo.clients;
  DROP TABLE dbo.goods;
END;
GO