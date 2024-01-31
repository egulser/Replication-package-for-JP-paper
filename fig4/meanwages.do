		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project

	*local ytitle Log Real Mean Hourly Wage
	
	use $project/data/clean/2004_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2004_sec4_wage, replace

	use $project/data/clean/2008_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2008_sec4_wage, replace	
	
	use $project/data/clean/2012_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_sec4_wage_88, replace	
	
	use $project/data/clean/2012_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_sec4_wage_08, replace

	use $project/data/clean/2016_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2016_sec4_wage, replace	
	
	use $project/data/clean/2022_v6, clear
	keep if ind_broad_4 == 4	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2022_sec4_wage, replace	
	
	use 			$project/data/tmp/2004_sec4_wage ,clear
	append using 	$project/data/tmp/2008_sec4_wage
	append using 	$project/data/tmp/2012_sec4_wage_88
	
	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	tempfile firstset
	saveold "`firstset'.dta", replace
			
	use	 			$project/data/tmp/2012_sec4_wage_08
	append using 	$project/data/tmp/2016_sec4_wage
	append using 	$project/data/tmp/2022_sec4_wage

	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	
	append using "`firstset'.dta"
	
	
	insobs 1, after(6)
	replace year = 2012 in 7
	
	forval i = 1/6 {	
	replace sh_emp`i' = (sh_emp`i'[1] + sh_emp`i'[6])/2 in 7
	}
	
	gen t = _n
	
	drop if t == 1 | t == 6
	sort year 	
	drop t
	gen sh_emp7 = (sh_emp1+sh_emp2)/2
	gen sh_emp8 = (sh_emp5+sh_emp6)/2	
	
	
	forval y = 1/8 {
		replace sh_emp`y' = log(sh_emp`y')
	}
	
	
	sort year
	
	label var sh_emp1 "NR cognitive" 
	label var sh_emp2 "NR personal"
	label var sh_emp3 "Routine cognitive"
	label var sh_emp4 "Routine manual"
	label var sh_emp5 "NR manual physical" 
	label var sh_emp6 "NR manual personal"	
	label var sh_emp7 "Abstract" 
	label var sh_emp8 "Manual"		
	
	local lw medium thick
	local lc black
	local ind Services
	local lpattern1 l 
	local lpattern2 -
	local lpattern3 .-.
	local lpattern4 -####-####-####-###
	local lpattern5 dot

	set scheme lean1
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2016 2022) ylabel(2.5(0.5)4) ///
			xtitle("Year") ytitle("`ytitle'") ///
			title("`ind'", ///
			size(medium))  legend( size(medium large) pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  name(services, replace)	saving(task`ind'_wage.gph, replace)	
	

**********************************************************************************	
**************************     		   	    **************************************
**************************   ECONOMY  		**************************************
**************************                  **************************************
**********************************************************************************
**********************************************************************************		


		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project

	use $project/data/clean/2004_v6, clear	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2004_secall_wage, replace

	use $project/data/clean/2008_v6, clear

	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2008_secall_wage, replace	
	
	use $project/data/clean/2012_v6, clear
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_secall_wage_88, replace	
	
	use $project/data/clean/2012_v6, clear

	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_secall_wage_08, replace

	use $project/data/clean/2016_v6, clear

	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2016_secall_wage, replace	
	
	use $project/data/clean/2022_v6, clear

	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2022_secall_wage, replace	
	
	use 			$project/data/tmp/2004_secall_wage ,clear
	append using 	$project/data/tmp/2008_secall_wage
	append using 	$project/data/tmp/2012_secall_wage_88
	
	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	tempfile firstset
	saveold "`firstset'.dta", replace
			
	use	 			$project/data/tmp/2012_secall_wage_08
	append using 	$project/data/tmp/2016_secall_wage
	append using 	$project/data/tmp/2022_secall_wage

	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	
	append using "`firstset'.dta"
	
	
	insobs 1, after(6)
	replace year = 2012 in 7
	
	forval i = 1/6 {	
	replace sh_emp`i' = (sh_emp`i'[1] + sh_emp`i'[6])/2 in 7
	}
	
	gen t = _n
	
	drop if t == 1 | t == 6
	sort year 	
	drop t
	gen sh_emp7 = (sh_emp1+sh_emp2)/2
	gen sh_emp8 = (sh_emp5+sh_emp6)/2	
	
	
	forval y = 1/8 {
		replace sh_emp`y' = log(sh_emp`y')
	}
	
	
	sort year
	
	label var sh_emp1 "NR cognitive" 
	label var sh_emp2 "NR personal"
	label var sh_emp3 "R cognitive"
	label var sh_emp4 "R manual"
	label var sh_emp5 "NR manual physical" 
	label var sh_emp6 "NR manual personal"	
	label var sh_emp7 "Abstract" 
	label var sh_emp8 "Manual"		
	
	local lw medium thick
	local lc black
	local ind Economy
	local lpattern1 l 
	local lpattern2 -
	local lpattern3 .-.
	local lpattern4 -####-####-####-###
	local lpattern5 dot

	
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("`ytitle'") ///
			title("`ind'", ///
			size(medium))  legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	name(`ind', replace) saving(task`ind'_wage.gph, replace)	
	
**********************************************************************************	
**************************     		   	    **************************************
**************************   MANUFACTURING  **************************************
**************************                  **************************************
**********************************************************************************
**********************************************************************************	


		
	global project "/Users/evrengulser/Desktop/TUIKDATA/27july"	
	cd $project

	use $project/data/clean/2004_v6, clear	
	keep if ind_broad_4 == 2	
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2004_secmanuf_wage, replace

	use $project/data/clean/2008_v6, clear
	keep if ind_broad_4 == 2
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2008_secmanuf_wage, replace	
	
	use $project/data/clean/2012_v6, clear
	keep if ind_broad_4 == 2
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco88 year)
	ren rhrw sh_emp	
	merge isco88 using iscotask.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_secmanuf_wage_88, replace	
	
	use $project/data/clean/2012_v6, clear
	keep if ind_broad_4 == 2
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_secmanuf_wage_08, replace

	use $project/data/clean/2016_v6, clear
	keep if ind_broad_4 == 2
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2016_secmanuf_wage, replace	
	
	use $project/data/clean/2022_v6, clear
	keep if ind_broad_4 == 2
	gen rhrw = rwage/uweeklywh		
	collapse (mean) rhrw [aw=weight] , by(isco08 year)
	ren rhrw sh_emp	
	merge isco08 using iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2022_secmanuf_wage, replace	
	
	use 			$project/data/tmp/2004_secmanuf_wage ,clear
	append using 	$project/data/tmp/2008_secmanuf_wage
	append using 	$project/data/tmp/2012_secmanuf_wage_88
	
	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	tempfile firstset
	saveold "`firstset'.dta", replace
			
	use	 			$project/data/tmp/2012_secmanuf_wage_08
	append using 	$project/data/tmp/2016_secmanuf_wage
	append using 	$project/data/tmp/2022_secmanuf_wage

	drop _merge
	collapse (mean) sh_emp, by(occtask year)	
	reshape wide sh_emp, i(year) j(occtask)	
	
	append using "`firstset'.dta"
	
	
	insobs 1, after(6)
	replace year = 2012 in 7
	
	forval i = 1/6 {	
	replace sh_emp`i' = (sh_emp`i'[1] + sh_emp`i'[6])/2 in 7
	}
	
	gen t = _n
	
	drop if t == 1 | t == 6
	sort year 	
	drop t
	gen sh_emp7 = (sh_emp1+sh_emp2)/2
	gen sh_emp8 = (sh_emp5+sh_emp6)/2	
	
	
	forval y = 1/8 {
		replace sh_emp`y' = log(sh_emp`y')
	}
	
	
	sort year
	
	label var sh_emp1 "NR cognitive" 
	label var sh_emp2 "NR personal"
	label var sh_emp3 "R cognitive"
	label var sh_emp4 "R manual"
	label var sh_emp5 "NR manual physical" 
	label var sh_emp6 "NR manual personal"	
	label var sh_emp7 "Abstract" 
	label var sh_emp8 "Manual"		
	
	local lw medium thick
	local lc black
	local ind Manufacturing
	local lpattern1 l 
	local lpattern2 -
	local lpattern3 .-.
	local lpattern4 -####-####-####-###
	local lpattern5 dot

	
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("`ytitle'") ///
			title("`ind'", ///
			size(medium))  legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving(task`ind'_wage.gph, replace)	
			
			
	grc1leg taskEconomy_wage.gph taskManufacturing_wage.gph taskServices_wage.gph, rows(1) ///
	imargin(0 0 0)  iscale(1) legendfrom(taskServices_wage.gph)  ysize(5) xsize(9.0) name(grc_graphs_wage, replace) saving(grc_graphs_wage, replace) pos(6) span	l1title("Log Real Hourly Wage")
	
gr draw grc_graphs_wage,  ysize(2.6) xsize(5) scale(1.3)

	graph export $project/fig/fonseca6_v5.pdf, replace
	graph export $project/fig/fonseca6_v5.png, replace
