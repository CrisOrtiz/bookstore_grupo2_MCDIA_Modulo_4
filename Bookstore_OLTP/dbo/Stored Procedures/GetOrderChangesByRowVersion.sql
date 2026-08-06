-- Este archivo va en tu proyecto Bookstore_OLTP (dbo/Stored Procedures/), NO en Bookstore_DW.
-- Sigue el mismo patron que GetBookChangesByRowVersion / GetCustomerChangesByRowVersion.

CREATE PROCEDURE [dbo].[GetOrderChangesByRowVersion]
(
   @startRow BIGINT
   ,@endRow  BIGINT
)
AS
BEGIN
	SELECT co.[order_id]
      ,ol.[line_id]
      ,co.[order_date]
      ,co.[customer_id]
      ,ol.[book_id]
      ,co.[shipping_method_id]
      ,ol.[price]
  FROM [dbo].[cust_order] co
  INNER JOIN [dbo].[order_line] ol ON co.order_id = ol.order_id
  WHERE (co.[rowversion] > CONVERT(ROWVERSION,@startRow) AND co.[rowversion] <= CONVERT(ROWVERSION,@endRow))
  OR (ol.[rowversion] > CONVERT(ROWVERSION,@startRow) AND ol.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END
