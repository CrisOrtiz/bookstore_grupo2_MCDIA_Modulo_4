CREATE PROCEDURE [dbo].[LoadDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    -- staging.customer puede traer mas de una fila por customer_id
    -- un cliente puede tener varias direcciones en customer_address.
    -- Nos quedamos con una sola fila por cliente antes del MERGE.
    ;WITH dedup AS (
        SELECT
            [customer_id],
            [first_name],
            [last_name],
            CONCAT([first_name], N' ', [last_name]) AS [full_name],
            [email],
            [street_number],
            [street_name],
            [city],
            [address_status],
            [country_name],
            ROW_NUMBER() OVER (
                PARTITION BY [customer_id]
                ORDER BY
                    CASE WHEN [address_status] = 'Active' THEN 0 ELSE 1 END,
                    [staging_load_date] DESC
            ) AS rn
        FROM [staging].[customer]
    )
    MERGE [dbo].[DimCustomer] AS target
    USING (
        SELECT [customer_id], [first_name], [last_name], [full_name], [email],
               [street_number], [street_name], [city], [address_status], [country_name]
        FROM dedup
        WHERE rn = 1
    ) AS source
    ON  target.[CustomerID] = source.[customer_id]
    WHEN MATCHED THEN
        UPDATE SET
            [FirstName]     = source.[first_name],
            [LastName]      = source.[last_name],
            [FullName]      = source.[full_name],
            [Email]         = source.[email],
            [StreetNumber]  = source.[street_number],
            [StreetName]    = source.[street_name],
            [City]          = source.[city],
            [AddressStatus] = source.[address_status],
            [CountryName]   = source.[country_name]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([CustomerID], [FirstName], [LastName], [FullName], [Email],
                [StreetNumber], [StreetName], [City], [AddressStatus], [CountryName])
        VALUES (source.[customer_id], source.[first_name], source.[last_name], source.[full_name], source.[email],
                source.[street_number], source.[street_name], source.[city], source.[address_status], source.[country_name]);
END
