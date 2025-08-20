CREATE OR ALTER VIEW Sales.staging_salesdata
AS 
SELECT * 
FROM [DataStagingLakehouse].[dbo].[newsales];
GO

