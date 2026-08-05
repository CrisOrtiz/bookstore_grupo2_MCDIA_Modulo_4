CREATE TABLE [dbo].[DimShippingMethod] (
    [ShippingMethodKey] INT            IDENTITY (1, 1) NOT NULL,
    [MethodID]          INT            NOT NULL,   -- llave de negocio (dbo.shipping_method.method_id)
    [MethodName]        VARCHAR (100)  NULL,
    [Cost]              DECIMAL (6, 2) NULL,
    CONSTRAINT [pk_DimShippingMethod] PRIMARY KEY CLUSTERED ([ShippingMethodKey] ASC)
);
