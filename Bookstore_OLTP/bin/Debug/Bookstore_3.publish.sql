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
PRINT N'Modificando Procedimiento [dbo].[GetCustomerChangesByRowVersion]...';


GO
ALTER PROCEDURE [dbo].[GetCustomerChangesByRowVersion]
(
   @startRow BIGINT 
   ,@endRow  BIGINT 
)
AS
BEGIN
	select c.[customer_id]
      ,c.[first_name]
      ,c.[last_name]
      ,c.[email]
	  ,a.[street_name]
	  ,a.[street_number]
	  ,a.city
	  ,adds.address_status
	  ,co.country_name
  FROM [dbo].[customer] c
  JOIN [dbo].[customer_address] ca ON (c.customer_id = ca.customer_id)
  JOIN [dbo].[address_status] adds ON (ca.status_id = adds.status_id)
  JOIN [dbo].[address] a ON (ca.address_id = a.address_id)
  JOIN [dbo].[country] co on (a.country_id = co.country_id)
  WHERE (c.[rowversion] > CONVERT(ROWVERSION,@startRow) AND c.[rowversion] <= CONVERT(ROWVERSION,@endRow))
  OR (ca.[rowversion] > CONVERT(ROWVERSION,@startRow) AND ca.[rowversion] <= CONVERT(ROWVERSION,@endRow))
  OR (adds.[rowversion] > CONVERT(ROWVERSION,@startRow) AND adds.[rowversion] <= CONVERT(ROWVERSION,@endRow))
  OR (a.[rowversion] > CONVERT(ROWVERSION,@startRow) AND a.[rowversion] <= CONVERT(ROWVERSION,@endRow))
  OR (co.[rowversion] > CONVERT(ROWVERSION,@startRow) AND co.[rowversion] <= CONVERT(ROWVERSION,@endRow))
END



-- BOOK
SET ANSI_NULLS ON
GO
PRINT N'Actualización completada.';


GO
