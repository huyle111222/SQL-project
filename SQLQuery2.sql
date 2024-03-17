use Northwind
--Cau 1 Sắp xếp sản phẩm tăng dần theo UnitPrice, 
--và tìm 20% dòng có UnitPrice cao nhất 

SELECT *
FROM Product
ORDER BY UnitPrice ASC;
WITH products_ranked AS (
SELECT *,
ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) AS row_num,
COUNT(*) OVER () AS total_rows
FROM Product
)
SELECT *
FROM products_ranked
WHERE row_num >= total_rows * 0.2;


--Câu 2 Với mỗi hóa đơn, xuất danh sách các sản phẩm, số lượng (Quantity) 
--và số phần trăm của sản phẩm đó trong hóa đơn. 


SELECT  ProductName,Quantity,
str(Quantity * 100.0 / SUM(Quantity) OVER (PARTITION BY OrderID),2)+'%' as [Percent]
FROM OrderItem
Inner JOIN Product ON Product.Id= OrderItem.ProductID
ORDER BY OrderId


--Câu 3 
IF exists (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME= N'QuocGia')
begin 
DROP TABLE QuocGia
end
SELECT
Id,CompanyName,City,
(CASE
	WHEN Country = 'USA' THEN 'USA'
	WHEN Country = 'UK' THEN 'UK'
	WHEN Country = 'France' THEN 'France'
	WHEN Country = 'Germany' THEN 'Germany'
	ELSE 'Others'
END) AS country
into QuocGia
FROM Supplier
select Id,CompanyName,City,
 ISNULL([USA], 0) AS [USA], 
 ISNULL([UK], 0) AS [UK], 
 ISNULL([France], 0) AS [France], 
 ISNULL([Germany], 0) AS [Germany], 
 ISNULL([Others], 0) AS [Others]
from Quocgia
PIVOT
(COUNT(country) FOR Country IN ([USA], [UK], [France], [Germany], [Others])) AS PivotTable


--cau 3 cach 2
SELECT Id,CompanyName,City,
 ISNULL([USA], 0) AS [USA], 
 ISNULL([UK], 0) AS [UK], 
 ISNULL([France], 0) AS [France], 
 ISNULL([Germany], 0) AS [Germany], 
 ISNULL([Others], 0) AS [Others]
FROM
(SELECT Id,CompanyName,City, Country FROM Supplier) AS SourceTable
PIVOT
(COUNT(Country) FOR Country IN ([USA], [UK], [France], [Germany], [Others])) AS PivotTable;
---




--Cau 4 Xuất danh sách các hóa đơn gồm OrderNumber, OrderDate (format: dd mm yyyy), 


SELECT OrderNumber,
OrderDate =Convert(varchar(10),OrderDate,103),
CustomerName='Customer' + space(1) +':'+C.FirstName+space(1)+C.LastName,
Phone='Phone'+Space(1)+':'+C.Phone,
[Address]='Address'+space(1)+':'+C.City ,
Nationals='National'+ +space(1)+':'+C.Country,
Amount=LTRIM(STR(CAST(O.TotalAmount as decimal(10,0)),10,0)+'éuro')
from[Order] O
inner join Customer As C on O.CustomerId=C.Id

--Cau 5 Xuất danh sách các sản phẩm dưới dạng đóng gói bags.


select Id,ProductName,SupplierId,UnitPrice,
Package=Stuff(Package,Charindex('bags',Package),len('bags'),N'túi')
from Product
where Package like '%bags'


--Câu 6
--Xuất danh sách các khách hàng theo tổng số hóa đơn mà khách hàng đó có, 
--sắp xếp theo thứ tự giảm dần của tổng số hóa đơn, 
--kèm theo đó là  các thông tin phân hạng DENSE_RANK và nhóm (chia thành 3 nhóm)

select C.Id,C.FirstName,C.LastName,sum(O.CustomerId) as total_sales,
DENSE_RANK() OVER (ORDER BY SUM(O.CustomerId) DESC) AS dense_rank,
NTILE(3) OVER (ORDER BY SUM(O.CustomerId) DESC) AS group_number
FROM [Order] as  O
inner join Customer as C on C.Id=O.CustomerId
GROUP BY O.CustomerId,C.Id,C.FirstName,C.LastName
ORDER BY total_sales DESC;







