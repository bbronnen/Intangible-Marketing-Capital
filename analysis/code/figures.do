clear all
macro drop _all

program main
	preAmbule
	figureGrowthBrandValue
	figureRatioDistribution
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
	
program figureGrowthBrandValue
	graph drop _all
	use $locationData/brandFinance, clear
	collapse (sum) valueBrandFinance, by(year)
	replace valueBrandFinance = valueBrandFinance/1000000
	twoway line valueBrandFinance year,  ///
		xtitle(year,size(medsmall)) ///
		ytitle(total value (trillion USD),size(medsmall)) ///
		xlabel(2007(2)2021, labsize(medsmall)) ///
		ylabel(1(.5)4, labsize(medsmall)) ///
		graphregion(color(gs16)) ///
		title((A)) name(left)

	graph export ../output/figures/totalValue.png, replace
	
	use $locationData/brandFinance, clear
	replace valueBrandFinance = log(valueBrandFinance/1000)
	bys nameBrand: egen stdev = sd(rank)
	bys nameBrand: gen obs = _N
	
	gsort -obs -stdev nameBrand year
	twoway (line valueBrandFinance year if nameBrand == "COCA COLA", lcolor("140 181 210") lpattern("_--")) ///
		(line valueBrandFinance year if nameBrand == "GENERAL ELECTRIC", lcolor("102 156 196") lpattern("_-")) ///
		(line valueBrandFinance year if nameBrand == "APPLE", lcolor("51 123 215") lpattern("l")) ///
		(line valueBrandFinance year if nameBrand == "MICROSOFT", lcolor("0 90 156") lpattern("_")) , ///
		legend(label(1 "Coca Cola") label(2 "General Electric") label(3 "Apple") label(4 "Microsoft"))  ///
		xtitle(year,size(medsmall)) ytitle(log total value (billion USD),size(medsmall)) xlabel(2007(2)2021, labsize(medsmall)) ///
		ylabel(1(1)6, labsize(medsmall)) graphregion(color(gs16)) title((B)) name(right)
		
	graph export ../output/figures/examplesBrandValue.png, replace
	
end

program figureRatioDistribution
	use $locationData/nationalAccount, clear
	
	graph drop _all
	twoway (line distribution year if Country == "Europe", lcolor("179 206 225") lpattern("-")) ///
		(line distribution year if Country == "United States", lcolor("140 181 210") lpattern("l")) ///
		(line distribution year if Country == "China, People's Republic of", lcolor("102 156 196") lpattern("_-"))  ///
		, ///
		legend(label(1 "Europe") label(2 "United States") label(3 "China") )  ///
		xtitle(year,size(medsmall)) ytitle(share of value-added, size(medsmall)) xlabel(1970(5)2020, labsize(medsmall)) ///
		ylabel(.05(.03).17, labsize(medsmall)) graphregion(color(gs16)) 
	
	graph export ../output/distribution_trend.eps, replace
	
end
	


main










	
	
