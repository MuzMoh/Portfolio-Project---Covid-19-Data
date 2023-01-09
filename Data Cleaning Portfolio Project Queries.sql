select *
from PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

update NashvilleHousing
set SaleDate = convert(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress data

--This shows that two properties with the same ParceID also have the same PropertyAddress
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


--Populating the PropertyAddress using the connection between the two columns using self join
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out PropertyAddress and OwnerAddress into individual columns (Address, City, State)


select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1 ) as Address, -- (-1) to get rid of comma in result
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as Address -- (+1) to get rid of comma in result
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1 )


alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) + 1 , len(PropertyAddress))




select *
from PortfolioProject.dbo.NashvilleHousing





select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'), 3) as Address,
parsename(replace(OwnerAddress, ',', '.'), 2) as City,
parsename(replace(OwnerAddress, ',', '.'), 1) as State
from PortfolioProject.dbo.NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)



alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)



select *
from PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "SoldAsVacant" column


-- Checking to see how many "Y", "N", "Yes", and "No" there are
select Distinct(SoldAsVacant), Count(SoldAsVacant) as Counter
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
						) as row_num from PortfolioProject.dbo.NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1



with RowNumCTE as(
select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by UniqueID
						) row_num

from PortfolioProject.dbo.NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


--select *
--from PortfolioProject.dbo.NashvilleHousing


--alter table PortfolioProject.dbo.NashvilleHousing
--drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
