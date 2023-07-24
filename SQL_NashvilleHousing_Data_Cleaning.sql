-- Cleaning Data in SQL Queries

SELECT * FROM NashVilleHousing;

-- 1. Let's Standardizethe SaleDate Field

SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM NashVilleHousing;


ALTER TABLE NashVilleHousing  
ADD SaleDateConverted DATE ; -- Add a new column/field of DATE datatype

UPDATE NashVilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate) ; -- Insert converted values to created fields

-- 2. Let's cleanup the property address

SELECT *
FROM NashVilleHousing
WHERE PropertyAddress IS NULL     --29 rows with NULL values

--Let's view the property adreesess with  NULL values.
--I am going to update the houses with the same Parcel ID to have the same address
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashVilleHousing a
JOIN NashVilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Now we Set the null values an address with thesame parcel ID
UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashVilleHousing a
JOIN NashVilleHousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- 3. Let's  breakout the address into address, city and state
SELECT SUBSTRING([PropertyAddress],1, CHARINDEX(',',[PropertyAddress])-1) AS Address,
	SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress])) AS City
FROM NashVilleHousing

-- Now let's createtwo columns for the address and the state
ALTER TABLE NashVilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER  TABLE NashVilleHousing
ADD City NVARCHAR(255);

-- Now we insert extracted values into each column
UPDATE NashVilleHousing
SET PropertySplitAddress = SUBSTRING([PropertyAddress],1, CHARINDEX(',',[PropertyAddress])-1);

UPDATE NashVilleHousing
SET City = SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress]));


-- 4. Let's break down the Owner's Address using PARSENAME instead of SUBSTRING& CHARINDEX
SELECT PARSENAME(REPLACE([OwnerAddress],',','.'),3),
	PARSENAME(REPLACE([OwnerAddress],',','.'),2),
	PARSENAME(REPLACE([OwnerAddress],',','.'),1)
FROM NashVilleHousing

--  Create Columns For Owner's adress, Owner's  City ands Owner's State
--  and insert accordingly
ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
OwnerSplitCity NVARCHAR(255),
OwnerSplitState NVARCHAR(255)

UPDATE NashVilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE([OwnerAddress],',','.'),3),
	OwnerSplitCity =  PARSENAME(REPLACE([OwnerAddress],',','.'),2),
	OwnerSplitState = PARSENAME(REPLACE([OwnerAddress],',','.'),1)

--5.LEt's change Y and N to Yesand No in the 'SoldAsVacant'field
	
SELECT [SoldAsVacant], COUNT(*) -- Check how many counts
FROM NashVilleHousing
GROUP BY [SoldAsVacant]
ORDER BY 2
/* Result:
Y	52
N	399
Yes	4623
No	51403
*/

-- Let's use a simple CASE statmenents

SELECT [SoldAsVacant], 
	CASE [SoldAsVacant]
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
		ELSE [SoldAsVacant]
	END
FROM NashVilleHousing

-- Now let's update the SoldAsVacant field :)
UPDATE NashVilleHousing
SET SoldAsVacant = CASE [SoldAsVacant]
		WHEN 'Y' THEN 'Yes'
		WHEN 'N' THEN 'No'
		ELSE [SoldAsVacant]
	END


-- 6. REMOVE Duplicates
WITH cte_rownum AS(
SELECT *,
	ROW_NUMBER()
		OVER(PARTITION BY ParcelID,
						  PropertyAddress,
						  SalePrice,
						  SaleDate,
						  LegalReference
						  ORDER  BY UniqueID) row_num
FROM NashVilleHousing	
)

SELECT *FROM NashVilleHousing
WHERE row_num >1


-- Delete  Unused Columns
ALTER TABLE NashVilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

ALTER TABLE NashVilleHousing
DROP COLUMN  SaleDate