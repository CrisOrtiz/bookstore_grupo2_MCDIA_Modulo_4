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
/*
Se está quitando la columna [staging].[order].[book_id]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[customer_id]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[line_id]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[order_date]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[order_id]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[price]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[shipping_method_id]; puede que se pierdan datos.
*/

IF EXISTS (select top 1 1 from [staging].[order])
    RAISERROR (N'Se detectaron filas. La actualización del esquema va a terminar debido a una posible pérdida de datos.', 16, 127) WITH NOWAIT

GO
PRINT N'Quitando Restricción DEFAULT restricción sin nombre en [staging].[book]...';


GO
ALTER TABLE [staging].[book] DROP CONSTRAINT [DF__tmp_ms_xx__stagi__02084FDA];


GO
PRINT N'Quitando Restricción DEFAULT restricción sin nombre en [staging].[order]...';


GO
ALTER TABLE [staging].[order] DROP CONSTRAINT [DF__tmp_ms_xx__stagi__05D8E0BE];


GO
PRINT N'Iniciando recompilación de la tabla [staging].[book]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [staging].[tmp_ms_xx_book] (
    [book_id]           INT           NULL,
    [title]             VARCHAR (400) NULL,
    [isbn13]            VARCHAR (13)  NULL,
    [language_code]     VARCHAR (8)   NULL,
    [language_name]     VARCHAR (50)  NULL,
    [num_pages]         INT           NULL,
    [publication_date]  DATE          NULL,
    [publisher_name]    VARCHAR (400) NULL,
    [author_name]       VARCHAR (400) NULL,
    [BookKey]           INT           NULL,
    [staging_load_date] DATETIME      DEFAULT (GETDATE()) NOT NULL
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [staging].[book])
    BEGIN
        INSERT INTO [staging].[tmp_ms_xx_book] ([book_id], [title], [isbn13], [language_code], [language_name], [num_pages], [publication_date], [publisher_name], [author_name], [staging_load_date], [BookKey])
        SELECT [book_id],
               [title],
               [isbn13],
               [language_code],
               [language_name],
               [num_pages],
               [publication_date],
               [publisher_name],
               [author_name],
               [staging_load_date],
               [BookKey]
        FROM   [staging].[book];
    END

DROP TABLE [staging].[book];

EXECUTE sp_rename N'[staging].[tmp_ms_xx_book]', N'book';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Iniciando recompilación de la tabla [staging].[order]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [staging].[tmp_ms_xx_order] (
    [OrderID]           INT            NULL,
    [LineID]            INT            NULL,
    [OrderDateKey]      INT            NULL,
    [CustomerKey]       INT            NULL,
    [BookKey]           INT            NULL,
    [ShippingMethodKey] INT            NULL,
    [Quantity]          INT            NULL,
    [UnitPrice]         DECIMAL (5, 2) NULL,
    [ShippingCost]      DECIMAL (5, 2) NULL,
    [staging_load_date] DATETIME       DEFAULT (GETDATE()) NOT NULL
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [staging].[order])
    BEGIN
        INSERT INTO [staging].[tmp_ms_xx_order] ([staging_load_date])
        SELECT [staging_load_date]
        FROM   [staging].[order];
    END

DROP TABLE [staging].[order];

EXECUTE sp_rename N'[staging].[tmp_ms_xx_order]', N'order';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Modificando Procedimiento [dbo].[LoadFactOrders]...';


GO
ALTER PROCEDURE [dbo].[LoadFactOrders]
AS
BEGIN
    SET NOCOUNT ON;

    -- Ya no necesitamos los INNER JOIN a las dimensiones porque 
    -- SSIS ya se encargó de popular las llaves (Keys) en la tabla staging.

    MERGE [dbo].[FactOrders] AS target
    USING (
        SELECT
            [OrderID],
            [LineID],
            [OrderDateKey],
            [CustomerKey],
            [BookKey],
            [ShippingMethodKey],
            [Quantity],
            [UnitPrice],
            [ShippingCost]
        FROM [staging].[order]
        WHERE [OrderDateKey] IS NOT NULL
    ) AS source
    ON  target.[OrderID] = source.[OrderID]
    AND target.[LineID]  = source.[LineID]
    
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
        VALUES (source.[OrderID], source.[LineID], source.[OrderDateKey], source.[CustomerKey], source.[BookKey],
                source.[ShippingMethodKey], source.[Quantity], source.[UnitPrice], source.[ShippingCost]);
END
GO
PRINT N'Actualizando Procedimiento [dbo].[LoadDimBook]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadDimBook]';


GO
PRINT N'Actualizando Procedimiento [dbo].[LoadBookstoreDW]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadBookstoreDW]';


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
PRINT N'Actualización completada.';


GO
