/*
Script de implementación para Bookstore_OLTP

Este código lo generó una herramienta.
Los cambios en este archivo pueden provocar un comportamiento incorrecto y se perderán si
el código se vuelve a generar.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "Bookstore_OLTP"
:setvar DefaultFilePrefix "Bookstore_OLTP"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detecte el modo SQLCMD y deshabilite la ejecución de scripts si no se admite el modo SQLCMD.
Para volver a habilitar el script después de habilitar el modo SQLCMD, ejecute lo siguiente:
ESTABLECER NOEXEC DESACTIVADO; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'El modo SQLCMD debe estar habilitado para ejecutar correctamente este script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creando Procedimiento [dbo].[GetOrderChangesByRowVersion]...';


GO
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
GO
PRINT N'Actualización completada.';


GO
