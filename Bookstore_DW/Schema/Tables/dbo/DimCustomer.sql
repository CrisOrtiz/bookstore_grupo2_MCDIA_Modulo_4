CREATE TABLE [dbo].[DimCustomer] (
    [CustomerKey]  INT           IDENTITY (1, 1) NOT NULL,
    [CustomerID]   INT           NOT NULL,   -- llave de negocio (dbo.customer.customer_id)
    [FirstName]    VARCHAR (200) NULL,
    [LastName]     VARCHAR (200) NULL,
    [FullName]     VARCHAR (401) NULL,
    [Email]        VARCHAR (350) NULL,
    [StreetNumber] VARCHAR (10)  NULL,
    [StreetName]   VARCHAR (200) NULL,
    [City]         VARCHAR (100) NULL,
    [AddressStatus] VARCHAR (30) NULL,
    [CountryName]  VARCHAR (200) NULL,
    CONSTRAINT [pk_DimCustomer] PRIMARY KEY CLUSTERED ([CustomerKey] ASC)
);
