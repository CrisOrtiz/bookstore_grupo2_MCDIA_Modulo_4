/*
Script de implementación para Bookstore_DW

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Bookstore_DW"
:setvar DefaultFilePrefix "Bookstore_DW"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detecte el modo SQLCMD y deshabilite la ejecución de scripts si no se admite el modo SQLCMD.
Para volver a habilitar el script después de habilitar el modo SQLCMD, ejecute lo siguiente:
ESTABLECER NOEXEC DESACTIVADO; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
PRINT N'Creando Esquema [staging]...';


GO
CREATE SCHEMA [staging]
    AUTHORIZATION [dbo];


GO
PRINT N'Creando Tabla [staging].[shipping_method]...';


GO
CREATE TABLE [staging].[shipping_method] (
    [method_id]         INT            NULL,
    [method_name]       VARCHAR (100)  NULL,
    [cost]              DECIMAL (6, 2) NULL,
    [staging_load_date] DATETIME       NOT NULL
);


GO
PRINT N'Creando Tabla [staging].[order]...';


GO
CREATE TABLE [staging].[order] (
    [order_id]           INT            NULL,
    [line_id]            INT            NULL,
    [order_date]         DATETIME       NULL,
    [customer_id]        INT            NULL,
    [book_id]            INT            NULL,
    [shipping_method_id] INT            NULL,
    [price]              DECIMAL (5, 2) NULL,
    [staging_load_date]  DATETIME       NOT NULL
);


GO
PRINT N'Creando Tabla [staging].[customer]...';


GO
CREATE TABLE [staging].[customer] (
    [customer_id]       INT           NULL,
    [first_name]        VARCHAR (200) NULL,
    [last_name]         VARCHAR (200) NULL,
    [email]             VARCHAR (350) NULL,
    [street_number]     VARCHAR (10)  NULL,
    [street_name]       VARCHAR (200) NULL,
    [city]              VARCHAR (100) NULL,
    [address_status]    VARCHAR (30)  NULL,
    [country_name]      VARCHAR (200) NULL,
    [staging_load_date] DATETIME      NOT NULL
);


GO
PRINT N'Creando Tabla [staging].[book]...';


GO
CREATE TABLE [staging].[book] (
    [book_id]           INT           NULL,
    [title]             VARCHAR (400) NULL,
    [isbn13]            VARCHAR (13)  NULL,
    [language_code]     VARCHAR (8)   NULL,
    [language_name]     VARCHAR (50)  NULL,
    [num_pages]         INT           NULL,
    [publication_date]  DATE          NULL,
    [publisher_name]    VARCHAR (400) NULL,
    [author_name]       VARCHAR (400) NULL,
    [staging_load_date] DATETIME      NOT NULL
);


GO
PRINT N'Creando Tabla [dbo].[DimBook]...';


GO
CREATE TABLE [dbo].[DimBook] (
    [BookKey]         INT           IDENTITY (1, 1) NOT NULL,
    [BookID]          INT           NOT NULL,
    [Title]           VARCHAR (400) NULL,
    [ISBN13]          VARCHAR (13)  NULL,
    [NumPages]        INT           NULL,
    [PublicationDate] DATE          NULL,
    [LanguageCode]    VARCHAR (8)   NULL,
    [LanguageName]    VARCHAR (50)  NULL,
    [PublisherName]   VARCHAR (400) NULL,
    [AuthorName]      VARCHAR (400) NULL,
    CONSTRAINT [pk_DimBook] PRIMARY KEY CLUSTERED ([BookKey] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimCustomer]...';


GO
CREATE TABLE [dbo].[DimCustomer] (
    [CustomerKey]   INT           IDENTITY (1, 1) NOT NULL,
    [CustomerID]    INT           NOT NULL,
    [FirstName]     VARCHAR (200) NULL,
    [LastName]      VARCHAR (200) NULL,
    [FullName]      VARCHAR (401) NULL,
    [Email]         VARCHAR (350) NULL,
    [StreetNumber]  VARCHAR (10)  NULL,
    [StreetName]    VARCHAR (200) NULL,
    [City]          VARCHAR (100) NULL,
    [AddressStatus] VARCHAR (30)  NULL,
    [CountryName]   VARCHAR (200) NULL,
    CONSTRAINT [pk_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimDate]...';


GO
CREATE TABLE [dbo].[DimDate] (
    [DateKey]     INT          NOT NULL,
    [FullDate]    DATE         NOT NULL,
    [DayOfWeek]   TINYINT      NOT NULL,
    [DayName]     VARCHAR (10) NOT NULL,
    [DayOfMonth]  TINYINT      NOT NULL,
    [DayOfYear]   SMALLINT     NOT NULL,
    [WeekOfYear]  TINYINT      NOT NULL,
    [MonthNumber] TINYINT      NOT NULL,
    [MonthName]   VARCHAR (10) NOT NULL,
    [Quarter]     TINYINT      NOT NULL,
    [Year]        SMALLINT     NOT NULL,
    [IsWeekend]   BIT          NOT NULL,
    CONSTRAINT [pk_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[DimShippingMethod]...';


GO
CREATE TABLE [dbo].[DimShippingMethod] (
    [ShippingMethodKey] INT            IDENTITY (1, 1) NOT NULL,
    [MethodID]          INT            NOT NULL,
    [MethodName]        VARCHAR (100)  NULL,
    [Cost]              DECIMAL (6, 2) NULL,
    CONSTRAINT [pk_DimShippingMethod] PRIMARY KEY CLUSTERED ([ShippingMethodKey] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[FactOrders]...';


GO
CREATE TABLE [dbo].[FactOrders] (
    [FactOrdersKey]     INT            IDENTITY (1, 1) NOT NULL,
    [OrderID]           INT            NOT NULL,
    [LineID]            INT            NOT NULL,
    [OrderDateKey]      INT            NOT NULL,
    [CustomerKey]       INT            NOT NULL,
    [BookKey]           INT            NOT NULL,
    [ShippingMethodKey] INT            NOT NULL,
    [Quantity]          INT            NOT NULL,
    [UnitPrice]         DECIMAL (5, 2) NULL,
    [LineAmount]        AS             ([Quantity] * [UnitPrice]) PERSISTED,
    [ShippingCost]      DECIMAL (6, 2) NULL,
    CONSTRAINT [pk_FactOrders] PRIMARY KEY CLUSTERED ([FactOrdersKey] ASC)
);


GO
PRINT N'Creando Tabla [dbo].[PackageConfig]...';


GO
CREATE TABLE [dbo].[PackageConfig] (
    [ConfigurationFilter] NVARCHAR (255) NOT NULL,
    [ConfiguredValue]     NVARCHAR (255) NULL,
    [PackagePath]         NVARCHAR (255) NOT NULL,
    [ConfiguredValueType] NVARCHAR (20)  NOT NULL
);


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [staging].[shipping_method]...';


GO
ALTER TABLE [staging].[shipping_method]
    ADD DEFAULT (GETDATE()) FOR [staging_load_date];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [staging].[order]...';


GO
ALTER TABLE [staging].[order]
    ADD DEFAULT (GETDATE()) FOR [staging_load_date];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [staging].[customer]...';


GO
ALTER TABLE [staging].[customer]
    ADD DEFAULT (GETDATE()) FOR [staging_load_date];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [staging].[book]...';


GO
ALTER TABLE [staging].[book]
    ADD DEFAULT (GETDATE()) FOR [staging_load_date];


GO
PRINT N'Creando Restricción DEFAULT restricción sin nombre en [dbo].[FactOrders]...';


GO
ALTER TABLE [dbo].[FactOrders]
    ADD DEFAULT 1 FOR [Quantity];


GO
PRINT N'Creando Clave externa [dbo].[fk_fo_date]...';


GO
ALTER TABLE [dbo].[FactOrders] WITH NOCHECK
    ADD CONSTRAINT [fk_fo_date] FOREIGN KEY ([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]);


GO
PRINT N'Creando Clave externa [dbo].[fk_fo_customer]...';


GO
ALTER TABLE [dbo].[FactOrders] WITH NOCHECK
    ADD CONSTRAINT [fk_fo_customer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]);


GO
PRINT N'Creando Clave externa [dbo].[fk_fo_book]...';


GO
ALTER TABLE [dbo].[FactOrders] WITH NOCHECK
    ADD CONSTRAINT [fk_fo_book] FOREIGN KEY ([BookKey]) REFERENCES [dbo].[DimBook] ([BookKey]);


GO
PRINT N'Creando Clave externa [dbo].[fk_fo_shipmethod]...';


GO
ALTER TABLE [dbo].[FactOrders] WITH NOCHECK
    ADD CONSTRAINT [fk_fo_shipmethod] FOREIGN KEY ([ShippingMethodKey]) REFERENCES [dbo].[DimShippingMethod] ([ShippingMethodKey]);


GO
PRINT N'Creando Procedimiento [dbo].[LoadDimBook]...';


GO
CREATE PROCEDURE [dbo].[LoadDimBook]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dbo].[DimBook] AS target
    USING (
        SELECT
            [book_id],
            [title],
            [isbn13],
            [language_code],
            [language_name],
            [num_pages],
            [publication_date],
            [publisher_name],
            [author_name]
        FROM [staging].[book]
    ) AS source
    ON  target.[BookID] = source.[book_id]
    WHEN MATCHED THEN
        UPDATE SET
            [Title]           = source.[title],
            [ISBN13]          = source.[isbn13],
            [LanguageCode]    = source.[language_code],
            [LanguageName]    = source.[language_name],
            [NumPages]        = source.[num_pages],
            [PublicationDate] = source.[publication_date],
            [PublisherName]   = source.[publisher_name],
            [AuthorName]      = source.[author_name]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([BookID], [Title], [ISBN13], [LanguageCode], [LanguageName],
                [NumPages], [PublicationDate], [PublisherName], [AuthorName])
        VALUES (source.[book_id], source.[title], source.[isbn13], source.[language_code], source.[language_name],
                source.[num_pages], source.[publication_date], source.[publisher_name], source.[author_name]);
END
GO
PRINT N'Creando Procedimiento [dbo].[LoadDimCustomer]...';


GO
CREATE PROCEDURE [dbo].[LoadDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dbo].[DimCustomer] AS target
    USING (
        SELECT
            [customer_id],
            [first_name],
            [last_name],
            CONCAT([first_name], N' ', [last_name]) AS [full_name],
            [email],
            [street_number],
            [street_name],
            [city],
            [address_status],
            [country_name]
        FROM [staging].[customer]
    ) AS source
    ON  target.[CustomerID] = source.[customer_id]
    WHEN MATCHED THEN
        UPDATE SET
            [FirstName]     = source.[first_name],
            [LastName]      = source.[last_name],
            [FullName]      = source.[full_name],
            [Email]         = source.[email],
            [StreetNumber]  = source.[street_number],
            [StreetName]    = source.[street_name],
            [City]          = source.[city],
            [AddressStatus] = source.[address_status],
            [CountryName]   = source.[country_name]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([CustomerID], [FirstName], [LastName], [FullName], [Email],
                [StreetNumber], [StreetName], [City], [AddressStatus], [CountryName])
        VALUES (source.[customer_id], source.[first_name], source.[last_name], source.[full_name], source.[email],
                source.[street_number], source.[street_name], source.[city], source.[address_status], source.[country_name]);
END
GO
PRINT N'Creando Procedimiento [dbo].[LoadDimShippingMethod]...';


GO
CREATE PROCEDURE [dbo].[LoadDimShippingMethod]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dbo].[DimShippingMethod] AS target
    USING (
        SELECT [method_id], [method_name], [cost]
        FROM [staging].[shipping_method]
    ) AS source
    ON  target.[MethodID] = source.[method_id]
    WHEN MATCHED THEN
        UPDATE SET
            [MethodName] = source.[method_name],
            [Cost]       = source.[cost]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([MethodID], [MethodName], [Cost])
        VALUES (source.[method_id], source.[method_name], source.[cost]);
END
GO
PRINT N'Creando Procedimiento [dbo].[LoadFactOrders]...';


GO
CREATE PROCEDURE [dbo].[LoadFactOrders]
AS
BEGIN
    SET NOCOUNT ON;

    -- IMPORTANTE: DimDate debe estar poblada de antemano (cubriendo el rango de order_date),
    -- y las 3 dimensiones (Customer/Book/ShippingMethod) deben cargarse ANTES que este proc.

    MERGE [dbo].[FactOrders] AS target
    USING (
        SELECT
            s.[order_id],
            s.[line_id],
            CONVERT(INT, CONVERT(VARCHAR(8), s.[order_date], 112)) AS [OrderDateKey],
            dc.[CustomerKey],
            db.[BookKey],
            dsm.[ShippingMethodKey],
            1 AS [Quantity],
            s.[price] AS [UnitPrice],
            dsm.[Cost] AS [ShippingCost]
        FROM [staging].[order] s
        INNER JOIN [dbo].[DimCustomer]       dc  ON dc.[CustomerID] = s.[customer_id]
        INNER JOIN [dbo].[DimBook]           db  ON db.[BookID]     = s.[book_id]
        INNER JOIN [dbo].[DimShippingMethod] dsm ON dsm.[MethodID]  = s.[shipping_method_id]
        WHERE s.[order_date] IS NOT NULL
    ) AS source
    ON  target.[OrderID] = source.[order_id]
    AND target.[LineID]  = source.[line_id]
    WHEN MATCHED THEN
        UPDATE SET
            [OrderDateKey]      = source.[OrderDateKey],
            [CustomerKey]       = source.[CustomerKey],
            [BookKey]           = source.[BookKey],
            [ShippingMethodKey] = source.[ShippingMethodKey],
            [Quantity]          = source.[Quantity],
            [UnitPrice]         = source.[UnitPrice],
            [ShippingCost]      = source.[ShippingCost]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([OrderID], [LineID], [OrderDateKey], [CustomerKey], [BookKey],
                [ShippingMethodKey], [Quantity], [UnitPrice], [ShippingCost])
        VALUES (source.[order_id], source.[line_id], source.[OrderDateKey], source.[CustomerKey], source.[BookKey],
                source.[ShippingMethodKey], source.[Quantity], source.[UnitPrice], source.[ShippingCost]);
END
GO
PRINT N'Creando Procedimiento [dbo].[LoadBookstoreDW]...';


GO
CREATE PROCEDURE [dbo].[LoadBookstoreDW]
AS
BEGIN
    SET NOCOUNT ON;

    -- Dimensiones primero (FactOrders tiene FK hacia todas)
    EXEC [dbo].[LoadDimCustomer];
    EXEC [dbo].[LoadDimBook];
    EXEC [dbo].[LoadDimShippingMethod];

    -- Fact al final
    EXEC [dbo].[LoadFactOrders];
END
GO
/*
Post-Deployment Script para Bookstore_DW
Puebla [dbo].[DimDate] con un rango de fechas (2015-01-01 a 2035-12-31).
Es idempotente: solo inserta las fechas que todavia no existen,
por lo que se puede correr en cada Publish sin duplicar filas
ni romper el FK que FactOrders tiene hacia DimDate.
*/

SET NOCOUNT ON;
SET DATEFIRST 7;   -- 1=Domingo ... 7=Sabado (evita depender del idioma del server)

DECLARE @StartDate DATE = '2015-01-01';
DECLARE @EndDate   DATE = '2035-12-31';

;WITH DateSeq AS
(
    SELECT @StartDate AS FullDate
    UNION ALL
    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeq
    WHERE FullDate < @EndDate
)
INSERT INTO [dbo].[DimDate]
(
    [DateKey], [FullDate], [DayOfWeek], [DayName], [DayOfMonth],
    [DayOfYear], [WeekOfYear], [MonthNumber], [MonthName], [Quarter],
    [Year], [IsWeekend]
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), d.FullDate, 112))       AS DateKey,
    d.FullDate,
    DATEPART(WEEKDAY, d.FullDate)                            AS DayOfWeek,
    DATENAME(WEEKDAY, d.FullDate)                            AS DayName,
    DAY(d.FullDate)                                          AS DayOfMonth,
    DATEPART(DAYOFYEAR, d.FullDate)                          AS DayOfYear,
    DATEPART(ISO_WEEK, d.FullDate)                           AS WeekOfYear,
    MONTH(d.FullDate)                                        AS MonthNumber,
    DATENAME(MONTH, d.FullDate)                              AS MonthName,
    DATEPART(QUARTER, d.FullDate)                            AS Quarter,
    YEAR(d.FullDate)                                         AS Year,
    CASE WHEN DATEPART(WEEKDAY, d.FullDate) IN (1, 7) THEN 1 ELSE 0 END AS IsWeekend
FROM DateSeq d
WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[DimDate] dd
    WHERE dd.[DateKey] = CONVERT(INT, CONVERT(VARCHAR(8), d.FullDate, 112))
)
OPTION (MAXRECURSION 0);

PRINT N'DimDate: carga completada.';
GO

GO
PRINT N'Comprobando los datos existentes con las restricciones recién creadas';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[FactOrders] WITH CHECK CHECK CONSTRAINT [fk_fo_date];

ALTER TABLE [dbo].[FactOrders] WITH CHECK CHECK CONSTRAINT [fk_fo_customer];

ALTER TABLE [dbo].[FactOrders] WITH CHECK CHECK CONSTRAINT [fk_fo_book];

ALTER TABLE [dbo].[FactOrders] WITH CHECK CHECK CONSTRAINT [fk_fo_shipmethod];


GO
PRINT N'Actualización completada.';


GO
