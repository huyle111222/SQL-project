use Northwind
-- Câu 1 Xuất danh sách các nhà cung cấp (gồm Id, CompanyName, ContactName, City, Country, Phone)
--kèm theo giá min và max của các sản phẩm mà nhà cung cấp đó cung cấp. Có sắp xếp theo thứ tự Id của nhà cung cấp 
--(Gợi ý : Join hai bản Supplier và Product, dùng GROUP BY tính Min, Max)

select S.Id,S.CompanyName,S.City,S.Country,S.Phone,P.SupplierId,
Max(P.UnitPrice) as 'Max Price',Min(P.UnitPrice) as 'Min Price'
from  Product as P
inner join Supplier as S
on S.Id=P.SupplierId
group by S.Id,S.CompanyName,S.City,S.Country,S.Phone,P.SupplierId
order by P.SupplierId 

-- Câu 2 Cũng câu trên nhưng chỉ xuất danh sách nhà cung cấp có sự khác biệt giá (max – min) 
--không quá lớn (<=30).(Gợi ý: Dùng HAVING)

select S.Id,S.CompanyName,S.City,S.Country,S.Phone,P.SupplierId,
Max(P.UnitPrice) - Min(P.UnitPrice) as 'Divided'
from  Product as P
inner join Supplier as S
on S.Id=P.SupplierId
group by S.Id,S.CompanyName,S.City,S.Country,S.Phone,P.SupplierId
having (Max(P.UnitPrice) - Min(P.UnitPrice)) <=30
order by P.SupplierId 

--Câu 3 Xuất danh sách các hóa đơn (Id, OrderNumber, OrderDate) 
--kèm theo tổng giá chi trả (UnitPrice*Quantity) cho hóa đơn đó, bên cạnh đó có cột Description là “VIP” 
--nếu tổng giá lớn hơn 1500 và “Normal” nếu tổng giá nhỏ hơn 1500(Gợi ý: Dùng UNION)

select  O.Id,O.OrderDate,O.OrderNumber,
I.Quantity*I.UnitPrice as 'Total', 'Vip' as [Description]
From [Order] as O
inner join OrderItem as I 
on O.Id=I.OrderId 
where I.Quantity*I.UnitPrice > 1500
union
select  O.Id,O.OrderDate,O.OrderNumber,
I.Quantity*I.UnitPrice, 'Normal' as [Description]
from OrderItem as I , [Order] as O
where I.Quantity*I.UnitPrice < 1500
group by O.Id,O.OrderDate,O.OrderNumber,I.Quantity,I.UnitPrice

--câu 4 Xuất danh sách những hóa đơn (Id, OrderNumber, OrderDate) trong tháng 7 
--nhưng phải ngoại trừ ra những hóa đơn từ khách hàng France. (Gợi ý: dùng EXCEPT)

select  O.Id,O.OrderDate,O.OrderNumber,O.CustomerId,C.Country,month(O.OrderDate) as 'month'
from [Order] as O
inner join Customer as C
on C.id=O.CustomerId
where month(O.OrderDate)= 7
except 
select  O.Id,O.OrderDate,O.OrderNumber,O.CustomerId,C.Country,month(O.OrderDate) as 'month'
from [Order] as O,Customer as C
WHERE Country = 'France'

-- Câu 5 Xuất danh sách những hóa đơn (Id, OrderNumber, OrderDate, TotalAmount)  nào có TotalAmount 
--nằm trong top 5 các hóa đơn. (Gợi ý : Dùng IN)

select Id, OrderNumber, OrderDate, TotalAmount
from [Order] 
WHERE TotalAmount IN (SELECT TOP 5 TotalAmount
FROM [Order]
ORDER BY TotalAmount DESC)









