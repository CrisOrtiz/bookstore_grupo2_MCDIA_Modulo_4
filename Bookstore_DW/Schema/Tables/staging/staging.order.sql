CREATE TABLE [staging].[order] (
    [OrderID]             INT            NULL,
    [LineID]              INT            NULL,
    [OrderDateKey]        INT            NULL,
    [CustomerKey]         INT            NULL,
    [BookKey]             INT            NULL,
    [ShippingMethodKey]   INT            NULL,
    [Quantity]            INT            NULL,
    [UnitPrice]           DECIMAL (5, 2) NULL,
    [ShippingCost]        DECIMAL (5, 2) NULL,
    [staging_load_date]   DATETIME       NOT NULL DEFAULT (GETDATE())
);
-- Columnas alineadas 1:1 con la salida de [dbo].[GetOrderChangesByRowVersion] (ver Stored Procedures)
