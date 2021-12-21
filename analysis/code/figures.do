clear all
macro drop _all

program main
	preAmbule
	figureTotalGrowth
	
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
	
program figureTotalGrowth

	use $locationData/brandFinance, clear
	collapse (sum) brandValue, by(year)
	replace brandValue = brandValue/1000000
	twoway line brandValue year,  ///
		xtitle(year,size(medsmall)) ytitle(total value (trillion USD),size(medsmall)) xlabel(2007(2)2021, labsize(medsmall)) ///
		ylabel(1(.5)4, labsize(medsmall)) graphregion(color(gs16)) title((A)) name(left)

	graph export ../output/figures/totalValue.png, replace
	
	use $locationData/brandFinance, clear
	replace brandValue = log(brandValue/1000)
	bys brand: egen stdev = sd(position)
	bys brand: gen obs = _N
	
	gsort -obs -stdev brand year
	graph drop _all
	twoway (line brandValue year if brand == "American Express", lcolor("179 206 225") lpattern("-")) ///
		(line brandValue year if brand == "Ford", lcolor("140 181 210") lpattern("_--")) ///
		(line brandValue year if brand == "IBM", lcolor("102 156 196") lpattern("_-")) ///
		(line brandValue year if brand == "Apple", lcolor("51 123 215") lpattern("l")) ///
		(line brandValue year if brand == "Microsoft", lcolor("0 90 156") lpattern("_")) , ///
		legend(label(1 "American Express") label(2 "Ford") label(3 "IBM") label(4 "Apple") label(5 "Microsoft"))  ///
		xtitle(year,size(medsmall)) ytitle(log total value (billion USD),size(medsmall)) xlabel(2007(2)2021, labsize(medsmall)) ///
		ylabel(1(1)6, labsize(medsmall)) graphregion(color(gs16)) title((B)) name(right)
		
	graph export ../output/figures/examplesBrandValue.png, replace
	
end


program tableBrandFinance

	use $locationData/brandFinance, clear
	graph export ../output/totalValue.png, replace
	
end


main










	
	
