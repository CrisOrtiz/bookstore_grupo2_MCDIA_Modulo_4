CREATE TABLE [dbo].[DimDate] (
    [DateKey]       INT          NOT NULL,   -- yyyymmdd
    [FullDate]      DATE         NOT NULL,
    [DayOfWeek]     TINYINT      NOT NULL,
    [DayName]       VARCHAR (10) NOT NULL,
    [DayOfMonth]    TINYINT      NOT NULL,
    [DayOfYear]     SMALLINT     NOT NULL,
    [WeekOfYear]    TINYINT      NOT NULL,
    [MonthNumber]   TINYINT      NOT NULL,
    [MonthName]     VARCHAR (10) NOT NULL,
    [Quarter]       TINYINT      NOT NULL,
    [Year]          SMALLINT     NOT NULL,
    [IsWeekend]     BIT          NOT NULL,
    CONSTRAINT [pk_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);
