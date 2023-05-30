/*
Cleaning Data in Sql Queries
*/
Select * 
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate,CONVERT(Date,SaleDate)
from PortfolioProject..NashvilleHousing



Alter table NashvilleHousing
ADD SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
----------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City,State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing


Alter table NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET  PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1)



Alter table NashvilleHousing
ADD PropertySplitCity nvarchar(255);


Update NashvilleHousing
SET  PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

Select * 
from PortfolioProject..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing
where OwnerAddress IS NOT NULL



Alter table NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)



Alter table NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


Update NashvilleHousing
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter table NashvilleHousing
ADD OwnerSplitState nvarchar(255);


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and NO in Sold as vacant field

select distinct(SoldAsVacant),Count(SoldAsVacant)
from NashvilleHousing
Group by SoldAsVacant
order By 2

select SoldAsVacant,

CASE when SoldAsVacant = 'Y' THEN 'YES'
	when SoldAsVacant = 'N' then 'NO'
	ELSE SoldAsVacant
	END
from NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'YES'
	when SoldAsVacant = 'N' then 'NO'
	ELSE SoldAsVacant
	END


	------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Remove Duplicates
	
Select * 
from PortfolioProject..NashvilleHousing

WITH RowNumCTE as(
Select *,
ROW_NUMBER() Over(
PARTITION BY  ParcelID,
			  PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
				UniqueID
				) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID

)

--delete From RowNumCTE
--where row_num >1


Select * 
from  RowNumCTE
where row_num >1
order by PropertyAddress



-----------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select * 
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress,SaleDate