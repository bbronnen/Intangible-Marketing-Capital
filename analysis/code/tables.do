clear all
macro drop _all

program main
	preAmbule
	tableBrandFinance
	
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
	foreach var of varlist brandValue position {
		regress `var' i.year
		areg `var', abs(brand)
		areg `var' i.year, abs(brand)
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










	
	
