CREATE OR ALTER PROCEDURE Sales.LoadDataFromStagingLakehouse (@OrderYear INT)
AS
BEGIN
    ------------------------------------------------------
    -- 1. Load data into the Customer dimension table
    ------------------------------------------------------
    INSERT INTO Sales.Dim_Customer (CustomerID, CustomerName, FirstName, LastName, EmailAddress)
    SELECT DISTINCT 
           EmailAddress AS CustomerID,  -- using Email as a unique identifier
           [First Name] + ' ' + [Last Name] AS CustomerName,
           [First Name],
           [Last Name],
           EmailAddress
    FROM Sales.staging_salesdata
    WHERE YEAR(OrderDate) = @OrderYear
      AND NOT EXISTS (
          SELECT 1
          FROM Sales.Dim_Customer c
          WHERE c.EmailAddress = Sales.staging_salesdata.EmailAddress
      );

    ------------------------------------------------------
    -- 2. Load data into the Item dimension table
    ------------------------------------------------------
    INSERT INTO Sales.Dim_Item (ItemID, ItemName)
    SELECT DISTINCT Item, Item
    FROM Sales.staging_salesdata
    WHERE YEAR(OrderDate) = @OrderYear
      AND NOT EXISTS (
          SELECT 1
          FROM Sales.Dim_Item i
          WHERE i.ItemID = Sales.staging_salesdata.Item
      );

    ------------------------------------------------------
    -- 3. Load data into the Sales fact table
    ------------------------------------------------------
    INSERT INTO Sales.Fact_Sales (CustomerID, ItemID, SalesOrderNumber, SalesOrderLineNumber, OrderDate, Quantity, TaxAmount, UnitPrice, [Year], [Month])
    SELECT 
        EmailAddress AS CustomerID,
        Item AS ItemID,
        SalesOrderNumber,
        CAST(SalesOrderLineNumber AS INT),
        CAST(OrderDate AS DATE),
        CAST(Quantity AS INT),
        CAST(TaxAmount AS FLOAT),
        CAST(UnitPrice AS FLOAT),
        [Year],
        [Month]
    FROM Sales.staging_salesdata
    WHERE YEAR(OrderDate) = @OrderYear;
END
GO

