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
	
	capture confirmdir temp	
	di _rc
	if !_rc {
		cd temp
		cap !del *.*
		cd ..
		rmdir temp
		}
	mkdir temp
	
	global locationData "../../data/output"
end 
	
program figureGrowthBrandValue
	cap graph drop left1 right1
	use $locationData/brandFinance, clear	
	mmerge nameBrand year using $locationData/assetData, type(1:1) unm(none)
	drop if year == 2021
	bys nameBrand: gen obs = _N 
	drop if obs<1
	keep if US == 1
	tab nameBrand
	gen valueSelective = valueBrandFinance*(1-missing(Property)) 
	gen propertySelective = PropertyPlantandEquipment

	collapse (sum) valueSelective valueBrandFinance propertySelective, by(year)
	gen valueBrandFinanceMM = valueBrandFinance/1000000
	gen propertySelective2 = propertySelective/1000000
	gen normBrandFinance = valueSelective/propertySelective
	
	twoway line valueBrandFinanceMM year ,  ///
		xtitle(year,size(medsmall)) ///
		ytitle(trillion USD,size(medsmall)) ///
		xlabel(2008(4)2020, labsize(medsmall)) ///
		ylabel(0.5(.25)2, labsize(medsmall)) ///
		graphregion(color(gs16)) ///
		title(Combined brand value) name(left1)

	twoway line normBrandFinance year,  ///
		xtitle(year,size(medsmall)) ///
		ytitle(value/PPE,size(medsmall)) ///
		xlabel(2008(4)2020, labsize(medsmall)) ///
		ylabel(.2(.1).8, labsize(medsmall)) ///
		graphregion(color(gs16)) ///
		title(Normalized brand value) name(right1)

	graph combine left1 right1, graphregion(color(gs16)) ysize(5) xsize(10)
	graph export ../output/figures/USBrandValueSideBySide.png, replace
	

	cap graph drop right2 left2
	forvalues case = 1/2 {
		if `case' == 2 {
			use $locationData/brandFinance, clear 
			local nm "right2"
			local source "Brand Finance"
		}
		if `case' == 1 {
			use $locationData/interBrand, clear 
			local nm "left2"
			local source "Interbrand"
		}
		replace value = log10(value/1000)
		bys nameBrand: egen stdev = sd(rank)
		bys nameBrand: gen obs = _N
	
		gsort -obs -stdev nameBrand year
		twoway (line value year if nameBrand == "COCA COLA", lcolor("140 181 210") lpattern("_--")) ///
			(line value year if nameBrand == "GENERAL ELECTRIC", lcolor("102 156 196") lpattern("_-")) ///
			(line value year if nameBrand == "APPLE", lcolor("51 123 215") lpattern("l")) ///
			(line value year if nameBrand == "MICROSOFT", lcolor("0 90 156") lpattern("_")) , ///
			legend(region(lstyle(none)) ring(0) position(5) bmargin(small) label(1 "Coca Cola") label(2 "General Electric") label(3 "Apple") label(4 "Microsoft"))  ///
			xtitle(year,size(medsmall)) ytitle(10log total value (billion USD),size(medsmall)) xlabel(2008(4)2020, labsize(medsmall)) ///
			ylabel(.5(.5)3, angle(90) labsize(medsmall)) graphregion(color(gs16)) title(`source') name(`nm')
		
		graph export ../output/figures/examplesBrandValue`case'.pdf, replace
	}
	
	
	graph combine left2 right2, 	graphregion(color(gs16)) ysize(5) xsize(10)
	graph export ../output/figures/examplesBrandValueSideBySide.pdf, replace
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
	

program figureEmployment
	use $locationData/employmentBySector, clear

	gen distribution = WholesaleRetail/TotalEmployment
	gen manufacturing = Manufacturing/TotalEmployment
	//drop if year<2000 
	graph drop _all
	local regions "Europe US"
	foreach reg of local regions {
		if "`reg'" == "US" local early = 1970
		if "`reg'" == "Europe" local early = 2000
		
		twoway (line distribution year if region == "`reg'", lcolor("179 206 225") lpattern("l")) ///
			   (line manufacturing year if region == "`reg'", lcolor("140 181 210") lpattern("--")) ///
		, ///
		legend(region(lstyle(none)) ring(0) position(5) bmargin(small) /// 
			label(1 "WholesaleRetail") label(2 "Manufacturing") )  ///
		xtitle(year,size(medsmall)) ytitle(share of labor force, size(medsmall)) ///
		xlabel(`early'(5)2020, labsize(medsmall)) ///
		ylabel(.04(.02).22, labsize(medsmall)) ///
		graphregion(color(gs16)) ///
		title(`reg') name(`reg')
	}
	
	graph combine Europe US, graphregion(color(gs16)) ysize(5) xsize(10)
	graph export ../output/figures/examplesEmploymentSideBySide.pdf, replace
	
end

main










	
	
