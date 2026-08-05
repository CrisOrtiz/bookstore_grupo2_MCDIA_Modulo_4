CREATE TABLE [staging].[order] (
    [order_id]           INT            NULL,
    [line_id]             INT            NULL,
    [order_date]          DATETIME       NULL,
    [customer_id]         INT            NULL,
    [book_id]             INT            NULL,
    [shipping_method_id]  INT            NULL,
    [price]               DECIMAL (5, 2) NULL,
    [staging_load_date]   DATETIME       NOT NULL DEFAULT (GETDATE())
);
-- Columnas alineadas 1:1 con la salida de [dbo].[GetOrderChangesByRowVersion] (ver Stored Procedures)
