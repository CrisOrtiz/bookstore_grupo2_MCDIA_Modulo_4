CREATE TABLE [staging].[shipping_method] (
    [method_id]         INT            NULL,
    [method_name]       VARCHAR (100)  NULL,
    [cost]              DECIMAL (6, 2) NULL,
    [staging_load_date] DATETIME       NOT NULL DEFAULT (GETDATE())
);
-- Columnas alineadas 1:1 con la salida de [dbo].[GetShippingMethodChangesByRowVersion]
