/*
Cleaning Data 

Table : NashvilleHousing
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------
-- Standarize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(date, SaleDate)


ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SalesDateConverted = CONVERT(date, SaleDate)

-------------------------------------------------------------------------
-- Populate Property Addresss data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL 
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-------------------------------------------------------------------------
-- Breaking out Address into Individual Columns(Address, City, State)



--1st>> Split into Address, City
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN (PropertyAddress)) AS ADDS
FROM PortfolioProject.dbo.NashvilleHousing

--ADD 2 COLUMNS

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN (PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------
--2nd>>  Split into Address, City and State  USING "PARSENAME"


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------
-- Change Y and N to Yes and No in " Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS ( 
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID
				) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



SELECT *
FROM PortfolioProject.dbo.NashvilleHousing



-------------------------------------------------------------------------
-- Delete Unused Columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

