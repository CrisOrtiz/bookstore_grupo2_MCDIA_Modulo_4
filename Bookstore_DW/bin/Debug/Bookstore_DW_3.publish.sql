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
PRINT N'Modificando Procedimiento [dbo].[LoadDimCustomer]...';


GO
ALTER PROCEDURE [dbo].[LoadDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    -- staging.customer puede traer mas de una fila por customer_id
    -- un cliente puede tener varias direcciones en customer_address.
    -- Nos quedamos con una sola fila por cliente antes del MERGE.
    ;WITH dedup AS (
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
            [country_name],
            ROW_NUMBER() OVER (
                PARTITION BY [customer_id]
                ORDER BY
                    CASE WHEN [address_status] = 'Active' THEN 0 ELSE 1 END,
                    [staging_load_date] DESC
            ) AS rn
        FROM [staging].[customer]
    )
    MERGE [dbo].[DimCustomer] AS target
    USING (
        SELECT [customer_id], [first_name], [last_name], [full_name], [email],
               [street_number], [street_name], [city], [address_status], [country_name]
        FROM dedup
        WHERE rn = 1
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
