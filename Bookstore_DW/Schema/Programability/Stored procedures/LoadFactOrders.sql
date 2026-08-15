CREATE PROCEDURE [dbo].[LoadFactOrders]
AS
BEGIN
    SET NOCOUNT ON;

    -- Ya no necesitamos los INNER JOIN a las dimensiones porque 
    -- SSIS ya se encargó de popular las llaves (Keys) en la tabla staging.

    MERGE [dbo].[FactOrders] AS target
    USING (
        SELECT
            [OrderID],
            [LineID],
            [OrderDateKey],
            [CustomerKey],
            [BookKey],
            [ShippingMethodKey],
            [Quantity],
            [UnitPrice],
            [ShippingCost]
        FROM [staging].[order]
        WHERE [OrderDateKey] IS NOT NULL
    ) AS source
    ON  target.[OrderID] = source.[OrderID]
    AND target.[LineID]  = source.[LineID]
    
    WHEN MATCHED THEN
        UPDATE SET
            [OrderDateKey]      = source.[OrderDateKey],
            [CustomerKey]       = source.[CustomerKey],
            [BookKey]           = source.[BookKey],
            [ShippingMethodKey] = source.[ShippingMethodKey],
            [Quantity]          = source.[Quantity],
            [UnitPrice]         = source.[UnitPrice],
            [ShippingCost]      = source.[ShippingCost]
            
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([OrderID], [LineID], [OrderDateKey], [CustomerKey], [BookKey],
                [ShippingMethodKey], [Quantity], [UnitPrice], [ShippingCost])
        VALUES (source.[OrderID], source.[LineID], source.[OrderDateKey], source.[CustomerKey], source.[BookKey],
                source.[ShippingMethodKey], source.[Quantity], source.[UnitPrice], source.[ShippingCost]);
END