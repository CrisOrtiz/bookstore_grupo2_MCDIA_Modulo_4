CREATE PROCEDURE [dbo].[LoadDimShippingMethod]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dbo].[DimShippingMethod] AS target
    USING (
        SELECT [method_id], [method_name], [cost]
        FROM [staging].[shipping_method]
    ) AS source
    ON  target.[MethodID] = source.[method_id]
    WHEN MATCHED THEN
        UPDATE SET
            [MethodName] = source.[method_name],
            [Cost]       = source.[cost]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([MethodID], [MethodName], [Cost])
        VALUES (source.[method_id], source.[method_name], source.[cost]);
END
