CREATE TABLE [dbo].[FactOrders] (
    [FactOrdersKey]     INT            IDENTITY (1, 1) NOT NULL,
    [OrderID]           INT            NOT NULL,   -- dimension degenerada (dbo.cust_order.order_id)
    [LineID]            INT            NOT NULL,   -- dimension degenerada (dbo.order_line.line_id)
    [OrderDateKey]      INT            NOT NULL,
    [CustomerKey]       INT            NOT NULL,
    [BookKey]           INT            NOT NULL,
    [ShippingMethodKey] INT            NOT NULL,
    [Quantity]          INT            NOT NULL DEFAULT 1,
    [UnitPrice]         DECIMAL (5, 2) NULL,
    [LineAmount]        AS ([Quantity] * [UnitPrice]) PERSISTED,
    [ShippingCost]      DECIMAL (6, 2) NULL,
    CONSTRAINT [pk_FactOrders] PRIMARY KEY CLUSTERED ([FactOrdersKey] ASC),
    CONSTRAINT [fk_fo_date] FOREIGN KEY ([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]),
    CONSTRAINT [fk_fo_customer] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]),
    CONSTRAINT [fk_fo_book] FOREIGN KEY ([BookKey]) REFERENCES [dbo].[DimBook] ([BookKey]),
    CONSTRAINT [fk_fo_shipmethod] FOREIGN KEY ([ShippingMethodKey]) REFERENCES [dbo].[DimShippingMethod] ([ShippingMethodKey])
);
