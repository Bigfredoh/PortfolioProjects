/*

Cleaning data in SQL

*/

------------------------------------
SELECT *
FROM [Housing DB].dbo.Sheet1$

-- Standardise Data Report
ALTER TABLE  
	dbo.Sheet1$
ADD SaleDateConverted DATE
UPDATE dbo.Sheet1$
SET SaleDateConverted = CAST(SaleDate AS DATE)
SELECT *
FROM [Housing DB].dbo.Sheet1$

-- Populate Propery Address data

SELECT a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Housing DB].dbo.Sheet1$ as a
JOIN [Housing DB].dbo.Sheet1$ as b
ON a.ParcelID = b.ParcelID 
AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Housing DB].dbo.Sheet1$ as a
JOIN [Housing DB].dbo.Sheet1$ as b
ON a.ParcelID = b.ParcelID 
AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- Breaking out address into Individual columns( address, city, state)

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Housing DB].dbo.Sheet1$

ALTER TABLE  
	dbo.Sheet1$
ADD PropertySplitAddress NVARCHAR(225)
UPDATE dbo.Sheet1$
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE  
	dbo.Sheet1$
ADD PropertySplitCity NVARCHAR(225)
UPDATE dbo.Sheet1$
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM [Housing DB].dbo.Sheet1$


ALTER TABLE  
	dbo.Sheet1$
ADD OwnerSplitAddress NVARCHAR(225)
UPDATE dbo.Sheet1$
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE  
	dbo.Sheet1$
ADD  OwnerSplitCity NVARCHAR(225)
UPDATE dbo.Sheet1$
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE  
	dbo.Sheet1$
ADD  OwnerSplitState NVARCHAR(225)
UPDATE dbo.Sheet1$
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- Change Y and N as Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Housing DB].dbo.Sheet1$
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE    WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM [Housing DB].dbo.Sheet1$

UPDATE dbo.Sheet1$
SET SoldAsVacant = CASE    WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicate

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM [Housing DB].dbo.Sheet1$
)

DELETE
FROM  ROWNUMCTE
WHERE row_num >1

-----------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

SELECT *
FROM [Housing DB].dbo.Sheet1$
ALTER TABLE [Housing DB].dbo.Sheet1$
DROP COLUMN SaleDate

ALTER TABLE [Housing DB].dbo.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress