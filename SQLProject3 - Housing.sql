/*

Cleaning Data in SQL Queries

*/


Select *
From PortfoloProject.dbo.Housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saledate, CONVERT(Date,SaleDate)
From PortfoloProject.dbo.Housing


Update Housing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfoloProject.dbo.Housing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfoloProject.dbo.Housing
--Where PropertyAddress is null
order by ParcelID

--Condition if parcel ID is same/ duplicate then Property Adress must also be same - Using Join

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfoloProject.dbo.Housing a
JOIN PortfoloProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfoloProject.dbo.Housing a
JOIN PortfoloProject.dbo.Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfoloProject.dbo.Housing

-- Seperating Address with comma (,)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfoloProject.dbo.Housing


ALTER TABLE Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


-- View everything updated

Select *
From PortfoloProject.dbo.Housing

-- Updating Owner's Adress

Select OwnerAddress
From PortfoloProject.dbo.Housing

-- Easy way to seperate String

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfoloProject.dbo.Housing


ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);


Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);


Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfoloProject.dbo.Housing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfoloProject.dbo.Housing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfoloProject.dbo.Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Now it's updated

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfoloProject.dbo.Housing
Group by SoldAsVacant
order by 2


-----------------------------------------------------------------------------------------------------------------------------------------------------------

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

				From PortfoloProject.dbo.Housing
				)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfoloProject.dbo.Housing



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfoloProject.dbo.Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From PortfoloProject.dbo.Housing

----------------------------------------------------------------------------------------------------------