--data cleaning using SQL on the project name nashvillehousing

drop table nashvillehousing

--created table and name given nashvillehousing 

CREATE TABLE nashvillehousing(
uniqueid integer,
parcelid text,
landuse varchar,
propertyaddress varchar,
saledate date,
saleprice varchar,
legalreference varchar,
soldasvacant varchar,
ownername varchar,
owneraddress varchar,
acreage decimal,
taxdistrict varchar,
landvalue integer,
buildingvalue integer,
totalvalue integer,
yearbuilt integer,
bedrooms integer,
fullbath integer,
halfbath integer
)

--

select * from nashvillehousing

--Standardize Date format

select saledate, CONVERT(date,saledate)
from nashvillehousing

UPDATE nashvillehousing
SET Saledate = converted(Date, saledate)

ALTER TABLE Nashvillehousing
ADD saledateconverted Date;

UPDATE nashvillehousing
SET saledateconverted = CONVERT(date, saledate)

-- populate property address data

select propertyaddress
from nashvillehousing
WHERE propertyaddress IS NULL
ORDER BY parcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a."["UniqueID " <> b."UniqueID "
Where a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) -1 ) as Address_part1,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address_part2
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
Add PropertySplitCity varchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress) + 2, LENGTH(PropertyAddress));


Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing
		
SELECT 
    (split_part(OwnerAddress, ',', 1)) AS street,
    (split_part(OwnerAddress, ',', 2)) AS city,
    (split_part(OwnerAddress, ',', 3)) AS state
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress varchar(255); 		
		
UPDATE NashvilleHousing
SET OwnerSplitAddress = split_part(OwnerAddress, ',', 1)
		
ALTER TABLE NashvilleHousing
Add OwnerSplitCity varchar(255);		
		
UPDATE NashvilleHousing
SET OwnerSplitCity = split_part(OwnerAddress, ',', 2)
		
ALTER TABLE NashvilleHousing
Add OwnerSplitState varchar(255);		
		
UPDATE NashvilleHousing
SET OwnerSplitState = split_part(OwnerAddress, ',', 3)
		
Select *
From NashvilleHousing		
		
-- Change Y and N to Yes and No in "Sold as Vacant" field		
		
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2		
		
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing		
		
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
		
-- Remove Duplicates		
		
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
Order by PropertyAddress;

		
Select *
From NashvilleHousing;		
		
-- Delete Unused Columns		
		
Select *
From NashvilleHousing;		
		
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;

----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------		
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		