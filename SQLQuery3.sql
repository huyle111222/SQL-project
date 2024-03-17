use Northwind
--Câu 1
SELECT OrderID, ProductID, Quantity, UnitPrice,
SUM(Quantity) OVER (PARTITION BY ProductID) AS TotalProduct,
CAST((Quantity * 100.0 / SUM(Quantity) OVER (PARTITION BY ProductID))
AS DECIMAL(6,2)) AS PercentByProduct
FROM [OrderItem]
ORDER BY OrderID


--câu 2
select DATENAME (dw,OrderDate) as [Day Name],
	DATENAME(MONTH , OrderDate) as [Month Name],*
from [Order]
WHERE DATENAME(dw, OrderDate) IN ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')


--câu 4
SELECT DB_ID('Northwind') AS [Database ID]
SELECT OBJECT_ID('Supplier') AS [Table ID]
SELECT USER_ID() AS [User ID], USER_NAME() AS [User Name]

--cau 6
--mức 1 là các Thành Phố (City) thuộc Country đó, 
--và mức 2 là các Hóa Đơn (Order) thuộc khách hàng từ Country-City đó
--SELECT *FROM Customer;

WITH CustomerCategory(Country,City,Countrycity,alevel)
AS(
SELECT DISTINCT Country,
City=CAST('' as nvarchar(255)),
Countrycity=CAST('' as nvarchar(255)),
alevel=0
from Customer

UNION ALL
select C.Country,
City=CAST(C.City as nvarchar(255)),
Countrycity=CAST('' as nvarchar(255)),
alevel=CC.alevel+1
from CustomerCategory as CC
inner join Customer as C on CC.Country =C.Country
where CC.alevel=0

UNION ALL
select C.Country,
City=CAST(C.City as nvarchar(255)),
Countrycity=CAST(CC.Countrycity as nvarchar(255)),
alevel=CC.alevel+1
from CustomerCategory CC
inner join Customer as C on CC.Country =C.Country and CC.City=C.City
where CC.alevel=1
)
select [Quoc Gia]=Case when alevel =0 then Country else '---'end,
[Thanh Pho]=Case when alevel =1 then City else '---' end,
[Khach Hang]=CountryCity,
Cap=alevel
from CustomerCategory
Order By Country , City,Countrycity,alevel;

--Câu 7
--Xuất những hóa đơn từ khách hàng France mà có tổng số lượng 
--Quantity lớn hơn 50 của các sản phẩm thuộc hóa đơn ấy 
With CustomerOrder as 
(select OrderId,avgquantity=sum(Quantity)
from OrderItem
group by OrderId
having Quantity=50
),
CustomerbyCountry as
(
select O.*
from [Order] O
inner join  Customer C on O.CustomerId=C.Id
where C.City='France'
)
select *
from CustomerbyCountry 
where Quantity>all(select avgquantity from CustomerOrder)

--Câu 7
WITH CustomerOrder AS (
    SELECT OrderId, SUM(Quantity) AS TotalQuantity
    FROM OrderItem
    GROUP BY OrderId
    HAVING SUM(Quantity) > 50
), CustomerByCountry AS (
    SELECT O.*
    FROM [Order] O
    INNER JOIN Customer C ON O.CustomerId = C.Id
    WHERE C.Country = 'France'
)
SELECT *
FROM CustomerByCountry Cbc
INNER JOIN CustomerOrder Co ON Cbc.Id = Co.OrderId;


-- Câu 3
--Với mỗi ProductID trong OrderItem xuất các thông tin gồm OrderID, ProductID, ProductName, UnitPrice, 
--Quantity, ContactInfo, ContactType. Trong đó ContactInfo ưu tiên Fax,
 --nếu không thì dùng Phone của Supplier sản phẩm đó. Còn ContactType là ghi chú đó là loại ContactInfo nào
SELECT
OrderID,OrderItem.ProductID,ProductName,OrderItem.UnitPrice,Quantity,
COALESCE(Supplier.Fax, Supplier.Phone) AS ContactInfo,
CASE
WHEN Supplier.Fax IS NOT NULL THEN 'Fax'
WHEN Supplier.Phone IS NOT NULL THEN 'Phone'
ELSE ''
END AS ContactType
FROM
OrderItem
INNER JOIN Product ON OrderItem.ProductID = Product.Id
INNER JOIN Supplier ON Product.SupplierID = Supplier.Id

--Câu 5
--Cho biết các thông tin user_update, user_seek, user_scan và user_lookup trên bảng Order trong database Northwind
SELECT last_user_update AS user_update, 
last_user_seek AS user_seek, 
last_user_scan AS user_scan, 
last_user_lookup AS user_lookup FROM sys.dm_db_index_usage_stats 
WHERE database_id = DB_ID('Northwind') AND object_id = OBJECT_ID('[Order]')


