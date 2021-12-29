clear all
macro drop _all

program main
	preAmbule
	readBrandFinanceData
	readInterBrandData
	makeCrossWalk
	mergeBrandName
	readNationalAccountData
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
	global locationBrandData "../../raw/brand_value_data"
	global locationNatAccData "../../raw/national_accounts_data"
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

program readNationalAccountData
	import excel using "$locationNatAccData/ValueAddedConstantPricesUSD.xlsx", firstrow clear
	destring Wholesaleretail Manufacturing TotalValueAdded Year, force replace
	g ratioRtlMfr = Wholesaleretail/Manufacturing
	g distribution = Wholesaleretail/TotalValueAdded 
	rename Year year
	
	drop if Country == "" | year==.
	gen type = "country"
	replace type = "region" if inlist(Country, "Australia and New Zealand", "Central America", "Eastern Africa", "Eastern Asia", "Eastern Africa", "Latin America and the Caribbean")
	replace type = "region" if inlist(Country, "Northern Africa", "Northern America", "Northern Europe", "Southern Europe", "Southern Asia", "Southern Africa", "South-Eastern Asia")
	replace type = "region" if inlist(Country, "South America", "Western Africa", "Western Asia", "Western Europe")
	replace type = "continent" if inlist(Country, "Africa", "Americas", "Asia", "Europe", "Oceania")
	replace type = "world" if Country == "World"
	save ../output/nationalAccount.dta , replace
	
	
end

main


	
	
