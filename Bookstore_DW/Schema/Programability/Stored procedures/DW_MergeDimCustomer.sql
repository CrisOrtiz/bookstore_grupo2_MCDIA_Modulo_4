CREATE PROCEDURE [dbo].[DW_MergeDimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE target
    SET
        target.[FirstName]     = source.[first_name],
        target.[LastName]      = source.[last_name],
        target.[FullName]      = source.[full_name],
        target.[Email]         = source.[email],
        target.[StreetNumber]  = source.[street_number],
        target.[StreetName]    = source.[street_name],
        target.[City]          = source.[city],
        target.[AddressStatus] = source.[address_status],
        target.[CountryName]   = source.[country_name]
    FROM [dbo].[DimCustomer] AS target
    INNER JOIN [staging].[customer] AS source
        ON target.[CustomerKey] = source.[CustomerKey];
END