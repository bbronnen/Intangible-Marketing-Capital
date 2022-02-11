clear all
macro drop _all

cap cd temp
cap erase *.* 
cd  
cap rmdir temp
cap mkdir temp 

program main
	preAmbule
	readBrandFinanceData
	readInterBrandData
	makeCrossWalk
	mergeBrandName
	readNationalAccountData
	readEuroStatData
	readBLSData
	readCompuStatData
end

program preAmbule
	cap log close
	set linesize 250
	version 16

	set matsize 11000
	set more off, permanently

	set seed 12345678
	set sortseed 12345678
	set scheme s2mono
	set type double, permanently 
	adopath + ..\external
	adopath + ..\external\ado

	capture confirm file temp
	if !_rc {
		cd temp
		cap erase *.*
		cd ..
		rmdir temp
		}
	mkdir temp
	
	global locationBrandData "../../raw/brand_value_data"
	global locationNatAccData "../../raw/national_accounts_data"
	global locationCompuStatData "../../raw/asset_data"
	
end 
	
program readBrandFinanceData
	import excel using "$locationBrandData/Brands_2007-2021_BrandDirectoryCom", firstrow clear
	rename Position rankBrandFinance
	rename Brand nameBrandFinance
	rename BrandValueM valueBrandFinance
	rename Year year
	destring rank value, force replace
	replace name = strupper(name)
	replace name = strrtrim(name)
	replace name = subinstr(name,".COM", "",.)
	keep year name rank value
	drop if missing(name)
	save ../output/brandFinance.dta, replace	
end

program readInterBrandData
	import excel using "$locationBrandData/Brands_2007-2021_RankingTheBrands", firstrow clear
	rename BrandRank rankInterBrand
	rename BrandNames nameInterBrand
	rename BrandValue valueInterBrand
	replace name = strupper(name)
	replace name = strrtrim(name)
	replace name = subinstr(name,".COM", "",.)
	replace value = subinstr(value,",", "",.)
	destring value, force replace
	drop if missing(name)
	save ../output/interBrand.dta, replace	
end

program makeCrossWalk
	use ../output/brandFinance.dta, clear 
	keep name 
	gen nameBrand = name
	duplicates drop
	save ../output/crossWalk.dta, replace // 
	sleep 500
	use ../output/interBrand.dta, clear // merge to interbrand
	keep name
	duplicates drop
	gen nameBrand = name
	mmerge nameBrand using ../output/crossWalk.dta, type(1:1) 
	sort nameBrand
	duplicates drop
	unify_nameBrand // 
	duplicates drop
	drop _merge
	save ../output/crossWalk.dta, replace // 
end	

program unify_nameBrand
	replace nameBrand = "CITI" if nameBrand == "CITIBANK" |nameBrand == "CITIGROUP"  
	replace nameBrand = "COCA COLA" if nameBrand == "COCA-COLA"
	replace nameBrand = "COLGATE" if nameBrand == "COLGATE-PALMOLIVE COMPANY"
	replace nameBrand = "CVS" if nameBrand == "CVS CAREMARK"|nameBrand == "CVS HEALTH"
	replace nameBrand = "DELL" if nameBrand == "DELL EMS"
	replace nameBrand = "DISCOVERY" if nameBrand == "DISCOVERY CHANNEL"
	replace nameBrand = "GENERAL ELECTRIC" if nameBrand == "GE"
	replace nameBrand = "HEWLETT-PACKARD" if nameBrand == "HEWLETT PACKARD ENTERPRISE"
	replace nameBrand = "JOHNSON & JOHNSON" if nameBrand == "JOHNSON AND JOHNSON"
	replace nameBrand = "JP MORGAN" if nameBrand == "JPMORGAN"
	replace nameBrand = "MITSUBISHI" if nameBrand == "MITSUBISHI CORPORATION"
	replace nameBrand = "MITSUI" if nameBrand == "MITSUI CONGLOMERATE"
	replace nameBrand = "NESCAFé" if nameBrand == "NESCAFE"
	replace nameBrand = "NESTLé" if nameBrand == "NESTLE"
	replace nameBrand = "PEPSI" if nameBrand == "PEPSI-COLA"
	replace nameBrand = "T-MOBILE" if nameBrand == "T MOBILE"
	replace nameBrand = "T-MOBILE" if nameBrand == "T (DEUTSCHE TELEKOM)"
	replace nameBrand = "TENCENT" if nameBrand == "TENCENT (QQ)"
	replace nameBrand = "UNITED HEALTHCARE" if nameBrand == "UNITEDHEALTHCARE"
	replace nameBrand = "UNITED HEALTHCARE" if nameBrand == "UNITEDHEALTH"
	replace nameBrand = "VOLKSWAGEN" if nameBrand == "VW (VOLKSWAGEN)"
end

program mergeBrandName

	use ../output/crossWalk.dta, clear //
	drop if missing(nameInterBrand)
	drop nameBrandFinance
	mmerge nameInterBrand using ../output/interBrand.dta, type(1:n) unm(both)
	save ../output/interBrand.dta, replace	
	
	use ../output/crossWalk.dta, clear //
	drop if missing(nameBrandFinance)
	drop nameInterBrand
	mmerge nameBrandFinance using ../output/brandFinance.dta, type(1:n) unm(both)
	save ../output/brandFinance.dta, replace	
	
end

program readBrandFinanceData
	import excel using "$locationCompuStatData/assetsCompuStat", firstrow sheet("all") clear
	keep nameBrand Ticker
	rename Ticker ticker
	sort nameBrand ticker 
	duplicates drop
	drop if missing(ticker) // no asset data from compustat
	egen check = group(ticker)
	summ check
	assert(r(max)==r(N)) //ticker is a key
	
end

program readNationalAccountData
	import excel using "$locationNatAccData/ValueAddedConstantPricesUSD.xlsx", firstrow clear
	destring Wholesaleretail Manufacturing TotalValueAdded Year, force replace
	g ratioRtlMfr = Wholesaleretail/Manufacturing
	g distribution = Wholesaleretail/TotalValueAdded 
	rename Year year
	
	drop if Country == "" | year==.
	gen type = "country"
	replace type = "region" if inlist(Country, "Australia and New Zealand",  /// 
		"Central America", "Eastern Africa", "Eastern Asia", "Eastern Africa", ///
		"Latin America and the Caribbean")
	replace type = "region" if inlist(Country, "Northern Africa", /// 
		"Northern America", "Northern Europe", "Southern Europe", /// 
		"Southern Asia", "Southern Africa", "South-Eastern Asia")
	replace type = "region" if inlist(Country, "South America", "Western Africa", ///
		"Western Asia", "Western Europe")
	replace type = "continent" if inlist(Country, "Africa", "Americas", "Asia", ///
		"Europe", "Oceania")
	replace type = "world" if Country == "World"
	save ../output/nationalAccount.dta , replace
end

program labelsToNames
	foreach v of var * {
		local lbl : var label `v'
		local lbl = strtoname("`lbl'")
		rename `v' `lbl'
	}
end

program readEuroStatData
foreach ic of numlist 10 13 16  {
		import excel using "$locationNatAccData/EuroStatEmployment.xlsx", ///
			sheet("Data`ic'") cellrange(A11:V12) firstrow clear
		labelsToNames
		reshape long _, i(GEO) j(year) 
		drop GEO
		if `ic'==10 rename _ TotalEmployment 
		if `ic'==13 rename _ Manufacturing 
		if `ic'==16 rename _ WholesaleRetail 
		if `ic' >10 mmerge year using ../output/EmploymentBySector.dta, type(1:1) unm(none)
		sleep 500
		save ../output/EmploymentBySector.dta, replace
	}
	drop _m 
	gen region = "Europe"	
	save ../output/EmploymentBySector.dta, replace
end

program readBLSData
	local sector "Wholesale Retail Manufacturing Total"
	foreach sec of local sector  {
		import excel using "$locationNatAccData/BureauLaborStats.xlsx", ///
			sheet("`sec'") cellrange(A13:M64) firstrow clear
		keep Year Dec
		rename Year year
		rename Dec `sec'
		if "`sec'" != "Wholesale" mmerge year using ../output/EmploymentBySectorBLS.dta, type(1:1) unm(none)
		sleep 1000
		save ../output/EmploymentBySectorBLS.dta, replace
	}
	gen region = "US"	
	rename Total TotalEmployment
	gen WholesaleRetail = Wholesale + Retail
	drop Wholesale Retail _m 
	append using ../output/EmploymentBySector.dta
	save ../output/EmploymentBySector.dta, replace
end

program readCompuStatData
	import excel using "$locationCompuStatData/assetsCompustat.xlsx", ///
			sheet("US") firstrow clear
	rename DataYearFiscal year
	gen region = "US"
	drop if IndustryFormat == "FS"
	save temp/US.dta, replace
	
	import excel using "$locationCompuStatData/assetsCompustat.xlsx", ///
			sheet("non-US") firstrow clear
	rename DataYearFiscal year
	gen region = "non-US"
	append using temp/US.dta
	replace Ticker = GlobalCompanyKey if region == "non-US" 
	rename Ticker idCode
	keep year idCode CompanyName AssetsTotal Goodwill IntangibleAssetsTotal ///
		PropertyPlantandEquipment region OtherIntangibles
	
	drop if CompanyName == "AXA ASIA PACIFIC HLDGS LTD" //non-US version. AXA SA included (US registered) 
	drop if CompanyName == "SUN ART RETAIL GROUP LTD" & missing(PropertyPlantandEquipment) // incomplete
	drop if CompanyName == "CA INC" //keep larger non-US version of Carrefour 
	drop if CompanyName == "CHINA EVERGRANDE NEW ENERGY" & missing(PropertyPlantandEquipment) // incomplete
	drop if CompanyName == "NISSAN MOTOR CO LTD" & region == "US" //keep larger non-US version. 
	drop if CompanyName == "VOLVO AB" & region == "US" //keep larger non-US version.
	drop if CompanyName == "ENGIE BRASIL ENERGIA SA" //keep larger US version of Engie 
	drop if year == 2021 //incomplete data
	sort idCode year
 	save temp/all.dta, replace
	
	import excel using "$locationCompuStatData/idCode2nameBrand.xlsx", firstrow clear
	mmerge idCode using temp/all.dta, type(1:n) unm(none)
	sort nameBrand year
	save ../output/assetData.dta, replace
end


main


	
	
