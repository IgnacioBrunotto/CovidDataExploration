--Data Cleaning project SQL

select * 
from DataCleaningProject.dbo.NashvilleHousing	

--Estandarizar SaleDate

select SaleDate, CONVERT(date,SaleDate) 
from DataCleaningProject.dbo.NashvilleHousing	

ALTER TABLE NashvilleHousing	
add SalesDateConvert date;

Update NashvilleHousing
set SalesDateConvert = CONVERT(date,SaleDate)


--Populate Address data

Select *
From NashvilleHousing	
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress,b.PropertyAddress) 
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress) 
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Adress en distintas columnas

Select PropertyAddress
From NashvilleHousing	
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --Lo que hace esto es buscar desde el 1 caracter hasta la coma. 
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
From NashvilleHousing	

ALTER TABLE NashvilleHousing	
add ActualAddress VARCHAR(50);

ALTER TABLE NashvilleHousing
add City VARCHAR(50);

Update NashvilleHousing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 


Update NashvilleHousing
set ActualAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



--Vamos a hacer lo mismo pero con OwnerAddress

Select *
From NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From NashvilleHousing 

ALTER TABLE NashvilleHousing	
add OwnerAddressFR VARCHAR(50);

ALTER TABLE NashvilleHousing
add OwnerCity VARCHAR(50);

ALTER TABLE NashvilleHousing
add OwnerState VARCHAR(50);


Update NashvilleHousing
set OwnerAddressFR = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Update NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Update NashvilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Algunos campos de SoldAsVacant estan mal

Select * 
From NashvilleHousing

Select distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

Update NashvilleHousing	
Set SoldAsVacant =  CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

--Quitar duplicados

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing


--Quitamos columnas que no vamos a usar

Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate