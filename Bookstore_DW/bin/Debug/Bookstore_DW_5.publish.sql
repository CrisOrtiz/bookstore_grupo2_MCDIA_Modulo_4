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
PRINT N'Quitando Restricción DEFAULT restricción sin nombre en [staging].[customer]...';


GO
ALTER TABLE [staging].[customer] DROP CONSTRAINT [DF__tmp_ms_xx__stagi__03F0984C];


GO
PRINT N'Iniciando recompilación de la tabla [staging].[customer]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [staging].[tmp_ms_xx_customer] (
    [customer_id]       INT           NULL,
    [first_name]        VARCHAR (200) NULL,
    [last_name]         VARCHAR (200) NULL,
    [full_name]         VARCHAR (400) NULL,
    [email]             VARCHAR (350) NULL,
    [street_number]     VARCHAR (10)  NULL,
    [street_name]       VARCHAR (200) NULL,
    [city]              VARCHAR (100) NULL,
    [address_status]    VARCHAR (30)  NULL,
    [country_name]      VARCHAR (200) NULL,
    [CustomerKey]       INT           NULL,
    [staging_load_date] DATETIME      DEFAULT (GETDATE()) NOT NULL
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [staging].[customer])
    BEGIN
        INSERT INTO [staging].[tmp_ms_xx_customer] ([customer_id], [first_name], [last_name], [email], [street_number], [street_name], [city], [address_status], [country_name], [staging_load_date], [CustomerKey], [full_name])
        SELECT [customer_id],
               [first_name],
               [last_name],
               [email],
               [street_number],
               [street_name],
               [city],
               [address_status],
               [country_name],
               [staging_load_date],
               [CustomerKey],
               [full_name]
        FROM   [staging].[customer];
    END

DROP TABLE [staging].[customer];

EXECUTE sp_rename N'[staging].[tmp_ms_xx_customer]', N'customer';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creando Procedimiento [dbo].[DW_MergeDimCustomer]...';


GO
CREATE PROCEDURE [dbo].[DW_MergeDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE target
    SET
        target.[FirstName]     = source.[first_name],
        target.[LastName]      = source.[last_name],
        target.[FullName]      = source.[full_name],
        target.[Email]         = source.[email],
        target.[StreetNumber]  = source.[street_number],
        target.[StreetName]    = source.[street_name],
        target.[City]          = source.[city],
        target.[AddressStatus] = source.[address_status],
        target.[CountryName]   = source.[country_name]
    FROM [dbo].[DimCustomer] AS target
    INNER JOIN [staging].[customer] AS source
        ON target.[CustomerKey] = source.[CustomerKey];
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
PRINT N'Actualización completada.';


GO
