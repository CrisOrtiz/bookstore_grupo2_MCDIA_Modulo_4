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
Se está quitando la columna [staging].[book].[BookKey]; puede que se pierdan datos.
*/

IF EXISTS (select top 1 1 from [staging].[book])
    RAISERROR (N'Se detectaron filas. La actualización del esquema va a terminar debido a una posible pérdida de datos.', 16, 127) WITH NOWAIT

GO
/*
Se está quitando la columna [staging].[customer].[CustomerKey]; puede que se pierdan datos.
*/

IF EXISTS (select top 1 1 from [staging].[customer])
    RAISERROR (N'Se detectaron filas. La actualización del esquema va a terminar debido a una posible pérdida de datos.', 16, 127) WITH NOWAIT

GO
/*
Se está quitando la columna [staging].[order].[BookKey]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[CustomerKey]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[FactOrdersKey]; puede que se pierdan datos.

Se está quitando la columna [staging].[order].[ShippingMethodKey]; puede que se pierdan datos.
*/

IF EXISTS (select top 1 1 from [staging].[order])
    RAISERROR (N'Se detectaron filas. La actualización del esquema va a terminar debido a una posible pérdida de datos.', 16, 127) WITH NOWAIT

GO
/*
Se está quitando la columna [staging].[shipping_method].[ShippingMethodKey]; puede que se pierdan datos.
*/

IF EXISTS (select top 1 1 from [staging].[shipping_method])
    RAISERROR (N'Se detectaron filas. La actualización del esquema va a terminar debido a una posible pérdida de datos.', 16, 127) WITH NOWAIT

GO
PRINT N'Modificando Tabla [staging].[book]...';


GO
ALTER TABLE [staging].[book] DROP COLUMN [BookKey];


GO
PRINT N'Modificando Tabla [staging].[customer]...';


GO
ALTER TABLE [staging].[customer] DROP COLUMN [CustomerKey];


GO
PRINT N'Modificando Tabla [staging].[order]...';


GO
ALTER TABLE [staging].[order] DROP COLUMN [BookKey], COLUMN [CustomerKey], COLUMN [FactOrdersKey], COLUMN [ShippingMethodKey];


GO
PRINT N'Modificando Tabla [staging].[shipping_method]...';


GO
ALTER TABLE [staging].[shipping_method] DROP COLUMN [ShippingMethodKey];


GO
PRINT N'Actualizando Procedimiento [dbo].[LoadDimBook]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadDimBook]';


GO
PRINT N'Actualizando Procedimiento [dbo].[LoadDimCustomer]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadDimCustomer]';


GO
PRINT N'Actualizando Procedimiento [dbo].[LoadFactOrders]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadFactOrders]';


GO
PRINT N'Actualizando Procedimiento [dbo].[LoadDimShippingMethod]...';


GO
EXECUTE sp_refreshsqlmodule N'[dbo].[LoadDimShippingMethod]';


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
