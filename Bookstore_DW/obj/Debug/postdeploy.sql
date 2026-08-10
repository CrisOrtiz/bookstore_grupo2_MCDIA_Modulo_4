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
