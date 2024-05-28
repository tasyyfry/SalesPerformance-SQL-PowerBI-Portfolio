--Melihat Isi Tabel 
Select * 
From SalesData..salesdata

--Pengecekan Isi Data 
UPDATE salesdata
SET Profit = ISNULL(Profit, 0);

--Melakukan Penambahan Tabel Baru
Alter Table SalesData..salesdata
ADD Order_Year int,
	Order_Month int;

--Mendapatkan Kolom Tabel Tahun dan Bulan dari Kolom Order Date
Update salesdata
SET Order_Year = DATEPART(Year, Order_Date),
	Order_Month = DATEPART(MONTH, Order_Date);

Select 
State, 
SUM(Sales) as Total_Sales, 
SUM(Profit) as Total_Profit
From SalesData..salesdata
Group by State
Order by Total_Sales Desc

--Membuat Kolom Baru untuk Penamaan Bulan dan Kategori Quarter
Alter Table SalesData..salesdata
ADD Month_Name varchar(20),
	Quarter int;

UPDATE salesdata
SET Month_Name = 
    CASE 
        WHEN Order_Month = 1 THEN 'Jan'
        WHEN Order_Month = 2 THEN 'Feb'
        WHEN Order_Month = 3 THEN 'Mar'
        WHEN Order_Month = 4 THEN 'Apr'
        WHEN Order_Month = 5 THEN 'May'
        WHEN Order_Month = 6 THEN 'Jun'
        WHEN Order_Month = 7 THEN 'Jul'
        WHEN Order_Month = 8 THEN 'Aug'
        WHEN Order_Month = 9 THEN 'Sep'
        WHEN Order_Month = 10 THEN 'Oct'
        WHEN Order_Month = 11 THEN 'Nov'
        WHEN Order_Month = 12 THEN 'Dec'
    END,
    Quarter = 
    CASE 
        WHEN Order_Month BETWEEN 1 AND 3 THEN 1
        WHEN Order_Month BETWEEN 4 AND 6 THEN 2
        WHEN Order_Month BETWEEN 7 AND 9 THEN 3
        WHEN Order_Month BETWEEN 10 AND 12 THEN 4
    END;

--MELIHAT CATEGORY YANG MENGHASILKAN KERUGIAN TERBESAR
SELECT Category, MIN(Profit) AS Total_Profit
FROM salesdata
WHERE Order_Year = 2017
GROUP BY Category
ORDER BY Total_Profit ASC;

--Melihat Top 5 Sub Category Paling Banyak Terjual 
Select TOP 5 Sub_Category, SUM(Quantity) AS Total_Quantity
From salesdata
WHERE State = 'New York'
Group by Sub_Category
ORDER BY Total_Quantity DESC;

--Siapa 5 pelanggan dengan jumlah order terbanyak di negara bagian dengan jumlah order terbanyak? 
WITH TopState AS (
	Select TOP 1 State
	From salesdata
	Group by State
	Order by COUNT(*) DESC)
Select TOP 5 Customer_Name, State, COUNT(*) AS Order_Count, SUM(Quantity) AS Total_Qty
From salesdata
WHERE State = (Select State from TopState)
GROUP BY Customer_Name, State
Order by Order_Count DESC;

--Siapa pelanggan dengan jumlah order terbanyak di masing-masing dari 5 negara bagian dengan penjualan tertinggi?
WITH Top5States AS (
    SELECT TOP 5 State, SUM(Sales) AS Total_Sales
    FROM salesdata
    GROUP BY State
    ORDER BY Total_Sales DESC
),
CustomerOrders AS (
    SELECT State, Customer_Name, COUNT(Order_Date) AS Order_Count
    FROM salesdata
    WHERE State IN (SELECT State FROM Top5States)
    GROUP BY State, Customer_Name
)
SELECT State, Customer_Name, Order_Count
FROM (
    SELECT State, Customer_Name, Order_Count,
           ROW_NUMBER() OVER (PARTITION BY State ORDER BY Order_Count DESC) AS RowNum
    FROM CustomerOrders
) AS RankedCustomers
WHERE RowNum = 1
ORDER BY State;

--Melihat Perbandingan Profit di tiap Quarter Masing Masing Tahun
/*WITH ProfitPerQuarter AS (
    SELECT Order_Year, Quarter, SUM(Profit) AS Total_Profit
    FROM salesdata
    GROUP BY Order_Year, Quarter
)
SELECT 
    Order_Year,
    Quarter,
    Total_Profit,
    LAG(Total_Profit) OVER (PARTITION BY Order_Year ORDER BY Quarter) AS Previous_Quarter_Profit,
    (Total_Profit - LAG(Total_Profit) OVER (PARTITION BY Order_Year ORDER BY Quarter)) AS Profit_Change,
    CASE
        WHEN LAG(Total_Profit) OVER (PARTITION BY Order_Year ORDER BY Quarter) IS NOT NULL THEN
            ((Total_Profit - LAG(Total_Profit) OVER (PARTITION BY Order_Year ORDER BY Quarter)) * 100.0) /
            LAG(Total_Profit) OVER (PARTITION BY Order_Year ORDER BY Quarter)
        ELSE NULL
    END AS Percentage_Change
FROM ProfitPerQuarter
ORDER BY Order_Year, Quarter;*/






