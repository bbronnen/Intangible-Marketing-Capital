clear all
macro drop _all

program main
	preAmbule
	tableBrandFinance
	tableNationalAccount
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
	global locationData "../../data/output"
end 
	
program tableBrandFinance
	use $locationData/brandFinance, clear
	foreach var of varlist value rank {
		regress `var' i.year
		areg `var', abs(nameBrand)
		areg `var' i.year, abs(nameBrand)
	}	
end

program tableInterBrand
	use $locationData/interBrand, clear
	foreach var of varlist value rank {
		regress `var' i.year
		areg `var', abs(nameBrand)
		areg `var' i.year, abs(nameBrand)
	}	
end

program tableNationalAccount
	use $locationData/nationalAccount, clear
	foreach var of varlist distribution ratio {
		regress `var' i.year if type == "country"
		areg `var' if type == "country", abs(Country) 
		areg `var' i.year if type == "country", abs(Country)
	}
end

program textClaims
	use $locationData/brandFinance, clear
	drop if missing(brand)
	egen uniqueBrand = group(brand)
	summ uniqueBrand, d
	display "Number of unique brands `r(max)'"
	
	fillin uniqueBrand year
	sort  year uniqueBrand
	gen ranked = 1-missing(brandValue)
	xtset uniqueBrand year
	regress ranked l.ranked i.year
main


program mergeBrandValueData
	use $locationData/brandFinance, clear
	mmerge nameBrand year using $locationData/interBrand, type(1:1) unm(none)
	bys nameBrand: gen obs = _N
	keep if obs == 15
	regress valueBrandFinance valueInterBrand
	regress valueBrandFinance valueInterBrand i.year
	areg valueBrandFinance valueInterBrand, abs(nameBrand)
	areg valueBrandFinance valueInterBrand i.year, abs(nameBrand)
	
	
end









	
	
