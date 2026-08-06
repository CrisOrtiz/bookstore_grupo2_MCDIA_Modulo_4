CREATE PROCEDURE [dbo].[LoadBookstoreDW]
AS
BEGIN
    SET NOCOUNT ON;

    -- Dimensiones primero (FactOrders tiene FK hacia todas)
    EXEC [dbo].[LoadDimCustomer];
    EXEC [dbo].[LoadDimBook];
    EXEC [dbo].[LoadDimShippingMethod];

    -- Fact al final
    EXEC [dbo].[LoadFactOrders];
END
