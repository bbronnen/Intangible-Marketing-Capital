clear all


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
	
	capture confirm file temp
	if !_rc {
		cd temp
		cap erase *.*
		cd ..
		rmdir temp
		}
	mkdir temp
	
	global locationData "../../data/output"
end 
	
program tableBrandFinance
	use $locationData/brandFinance, clear
	preserve
		bys nameBrand: gen freq = _N
		//keep if freq > 10 
		drop freq _merge nameBrandFinance
		bys nameBrand: egen avrank = mean(rank) 
		sort avrank nameBrand year
		export excel using ../output/brandFinance.xlsx, first(variables) replace
	restore
	foreach var of varlist value rank {
		regress `var' i.year
		areg `var', abs(nameBrand)
		areg `var' i.year, abs(nameBrand)
	}	
	collapse value, by(year)
	list
end

program tableInterBrand
	use $locationData/interBrand, clear
	foreach var of varlist value rank {
		regress `var' i.year
		areg `var', abs(nameBrand)
		areg `var' i.year, abs(nameBrand)
	}	
	collapse value, by(year)
	list
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
	corr value*
	regress valueBrandFinance valueInterBrand
	regress valueBrandFinance valueInterBrand i.year
	areg valueBrandFinance valueInterBrand, abs(nameBrand)
	areg valueBrandFinance valueInterBrand i.year, abs(nameBrand)
	
end









	
	
