USE [Bookstore_DW]
GO

/****** Objeto: StoredProcedure [dbo].[sp_Reports_GetSalesPerYear] Fecha de script: 16/08/2026 12:07:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[sp_Reports_GetSalesPerYear]
(
@MethodName VARCHAR(100)=NULL
,@Year INT 
)
AS
BEGIN
	SELECT 
	ddate.year,
	dshmet.MethodName,
	totalQuantity=SUM(forder.Quantity) --metric
	FROM [dbo].[FactOrders] forder
	INNER JOIN [dbo].[DimShippingMethod] dshmet ON (forder.ShippingMethodKey=dshmet.ShippingMethodKey)
	INNER JOIN [dbo].[DimDate] ddate ON (forder.OrderDateKey=ddate.DateKey)
	WHERE ddate.year=@Year 
	AND (dshmet.MethodName=@MethodName OR @MethodName IS NULL)
	group by ddate.year, 
	dshmet.MethodName
END
GO


