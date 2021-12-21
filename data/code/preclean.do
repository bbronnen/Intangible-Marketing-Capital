clear all
macro drop _all

program main
	preAmbule
	readBrandFinanceData	
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
	global locationData "../../raw/brand_value_data"
end 
	
program readBrandFinanceData
	forvalues yr = 2007/2021 {
		import delim using "$locationData/brandirectory-ranking-data-global-`yr'.csv", varn(1) clear
		rename brandvaluem brandValue
		drop if position >100 
		destring brandValue, force replace 
		keep brand year brandValue position
		if `yr'>2007 append using ../output/brandFinance.dta
		save ../output/brandFinance.dta, replace	
		display "`yr'"
		sleep 200
		}
end

main










	
	
