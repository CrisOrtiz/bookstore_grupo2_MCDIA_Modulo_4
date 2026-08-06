CREATE PROCEDURE [dbo].[LoadFactOrders]
AS
BEGIN
    SET NOCOUNT ON;

    -- IMPORTANTE: DimDate debe estar poblada de antemano (cubriendo el rango de order_date),
    -- y las 3 dimensiones (Customer/Book/ShippingMethod) deben cargarse ANTES que este proc.

    MERGE [dbo].[FactOrders] AS target
    USING (
        SELECT
            s.[order_id],
            s.[line_id],
            CONVERT(INT, CONVERT(VARCHAR(8), s.[order_date], 112)) AS [OrderDateKey],
            dc.[CustomerKey],
            db.[BookKey],
            dsm.[ShippingMethodKey],
            1 AS [Quantity],
            s.[price] AS [UnitPrice],
            dsm.[Cost] AS [ShippingCost]
        FROM [staging].[order] s
        INNER JOIN [dbo].[DimCustomer]       dc  ON dc.[CustomerID] = s.[customer_id]
        INNER JOIN [dbo].[DimBook]           db  ON db.[BookID]     = s.[book_id]
        INNER JOIN [dbo].[DimShippingMethod] dsm ON dsm.[MethodID]  = s.[shipping_method_id]
        WHERE s.[order_date] IS NOT NULL
    ) AS source
    ON  target.[OrderID] = source.[order_id]
    AND target.[LineID]  = source.[line_id]
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
        VALUES (source.[order_id], source.[line_id], source.[OrderDateKey], source.[CustomerKey], source.[BookKey],
                source.[ShippingMethodKey], source.[Quantity], source.[UnitPrice], source.[ShippingCost]);
END
