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
    [staging_load_date] DATETIME      NOT NULL DEFAULT (GETDATE())
);
-- Columnas alineadas 1:1 con la salida de [dbo].[GetCustomerChangesByRowVersion]
