-- CLEAN Data using SQL - Data from Nashville Housing Data

/*============================================================================================*/
-- Test Run
SELECT *
FROM Data_for_Nashville_Housing_Data dfnhd 

/*============================================================================================*/
-- Standardlize Date Format

SELECT SaleDate, DATE(SaleDate) AS FormattedDate
FROM Data_for_Nashville_Housing_Data

Update Data_for_Nashville_Housing_Data 
set SaleDate = DATE(SaleDate) AS FormattedDate 

/*============================================================================================*/
-- Organize Property Address Data
SELECT PropertyAddress 
FROM Data_for_Nashville_Housing_Data dfnhd 
WHERE PropertyAddress is null
--(Problem with Property Address is NULL. It should not be Null. The data is missing bc fail to enter addresses multiple times for the same unique person.)

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress as Correct_Address --(This returns what the blank Property Address should be)
FROM Data_for_Nashville_Housing_Data A
INNER JOIN Data_for_Nashville_Housing_Data B --(Joinning the table by itself so we can see what the missing address supposed to be)
ON A.ParcelID = B.ParcelID AND A."UniqueID " <> B."UniqueID "
--WHERE A.PropertyAddress IS NULL 

UPDATE Data_for_Nashville_Housing_Data --(This will update the NULL data for Property Address)
SET PropertyAddress = (
    SELECT B.PropertyAddress
    FROM Data_for_Nashville_Housing_Data B
    WHERE Data_for_Nashville_Housing_Data.ParcelID = B.ParcelID
    AND Data_for_Nashville_Housing_Data."UniqueID " <> B."UniqueID "
    AND B.PropertyAddress IS NOT NULL)
WHERE PropertyAddress IS NULL 

/*============================================================================================*/
-- Expand Prperty Address into Address, City

SELECT PropertyAddress --(Test Run)
FROM Data_for_Nashville_Housing_Data dfnhd 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address, --(Returns everything before , Address)
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LENGTH(PropertyAddress)) as City --(Returns everything after , City)
From Data_for_Nashville_Housing_Data dfnhd 

ALTER TABLE Data_for_Nashville_Housing_Data  --Add a new column for Address
Add PropertyAddress_Split Nvarchar(255)

Update Data_for_Nashville_Housing_Data 
SET PropertyAddress_Split = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )


ALTER TABLE Data_for_Nashville_Housing_Data --Add a new column for City
Add PropertyCity_Split Nvarchar(255)

Update Data_for_Nashville_Housing_Data 
SET PropertyCity_Split = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LENGTH(PropertyAddress))

SELECT * -- TEST
FROM Data_for_Nashville_Housing_Data dfnhd 

/*============================================================================================*/
-- Expand Owner Address into Address, City, State

SELECT OwnerAddress 
FROM Data_for_Nashville_Housing_Data dfnhd 

Select -- This split the Address, City, and State
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Data_for_Nashville_Housing_Data dfnhd 

ALTER TABLE Data_for_Nashville_Housing_Data  --Add a new column for Owner Address
Add OwnerAddress_Split Nvarchar(255)

Update Data_for_Nashville_Housing_Data 
SET OwnderAddress_Split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Data_for_Nashville_Housing_Data --Add a new column for Owner City
Add OwnerCity_Split Nvarchar(255)

Update Data_for_Nashville_Housing_Data 
SET OwnerCity_Split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Data_for_Nashville_Housing_Data --Add a new column for Owner State
Add OwnerState_Split Nvarchar(255)

Update Data_for_Nashville_Housing_Data 
SET OwnerState_Split = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * -- TEST
FROM Data_for_Nashville_Housing_Data dfnhd 

/*============================================================================================*/
-- Replace all Y and N to Yes and No (Sold as Vacant)

SELECT DISTINCT(SoldAsVacant) -- TEST
FROM Data_for_Nashville_Housing_Data dfnhd 

SELECT --This will replace N and Y with No and Yes
CASE 
	when SoldAsVacant = 'N' Then SoldAsVacant = 'No'
	when SoldAsVacant = 'Y' Then SoldAsVacant = 'Yes'
	else SoldAsVacant
END AS UpdatedSoldAsVacant
FROM Data_for_Nashville_Housing_Data dfnhd 

UPDATE Data_for_Nashville_Housing_Data -- UPDATE the data
SET 
SoldAsVacant =
CASE 
	when SoldAsVacant = 'N' Then SoldAsVacant = 'No'
	when SoldAsVacant = 'Y' Then SoldAsVacant = 'Yes'
	else SoldAsVacant
END 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) --Test
FROM Data_for_Nashville_Housing_Data dfnhd 
Group by SoldAsVacant 
Order by SoldAsVacant 

/*============================================================================================*/
-- Remove Duplicate Rows

WITH RowNumCTE AS
(
Select *, 
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY "UniqueID "
					) row_num
From Data_for_Nashville_Housing_Data dfnhd 
)

DELETE 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

SELECT *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From Data_for_Nashville_Housing_Data dfnhd 

/*============================================================================================*/
--Remove empty columns

Select *
From Data_for_Nashville_Housing_Data dfnhd 


ALTER TABLE Data_for_Nashville_Housing_Data 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
