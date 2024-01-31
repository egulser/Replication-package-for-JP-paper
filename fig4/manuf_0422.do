		
		
	cd $project

	use $project/data/clean/2012_v6, clear
	keep if ind_broad_4 == 2
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_sec4, replace

	use $project/data/clean/2016_v6, clear
	keep if ind_broad_4 == 2
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta		
	drop if _merge != 3
	saveold $project/data/tmp/2016_sec4, replace	
	
	use $project/data/clean/2022_v6, clear
	keep if ind_broad_4 == 2
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta		
	drop if _merge != 3
	saveold $project/data/tmp/2022_sec4, replace	
	
	use 			$project/data/tmp/2012_sec4 ,clear
	append using 	$project/data/tmp/2016_sec4
	append using 	$project/data/tmp/2022_sec4
	
	drop _merge isco08
	
	
	collapse (rawsum) sh_emp, by(occtask year)
	replace sh_emp = sh_emp/100
	
	reshape wide sh_emp, i(year) j(occtask)

	gen sh_emp7 = sh_emp1+sh_emp2
	gen sh_emp8 = sh_emp5+sh_emp6	
	
	append using $project/data/manuf04
	
	sort year
	
	insobs 1, after(6)
	replace year = 2012 in 7
	
	forval i = 1/6 {	
	replace sh_emp`i' = (sh_emp`i'[3] + sh_emp`i'[4])/2 in 7
	}
	
	gen t = _n
	
	drop if t == 3 | t == 4
	sort year 
	
	replace sh_emp7 = sh_emp1+sh_emp2 if year == 2012
	replace sh_emp8 = sh_emp5+sh_emp6 if year == 2012	
	
	/*
	forval i = 2/6 {
		local z = `i'-1
		replace sh_emp`i' = sh_emp`z' + sh_emp`i'
	}
	*/
	
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
	
	/*
	twoway 	area sh_emp6 sh_emp5 sh_emp4 sh_emp3 sh_emp2 sh_emp1 year,  ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("Employement Share") ///
			title("`ind'", ///
			size(medium)) ylabel(0(.1)1, nogrid) legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving(task`ind'.gph, replace)	
	
	twoway 	   area sh_emp1  year,   color(%30) 	///
			|| area sh_emp2  year,   color(%30) 	///	
			|| area sh_emp3  year,   color(%30)  	///
			|| area sh_emp4  year,   color(%30)  	///
			|| area sh_emp5  year,   color(%30)  	///
			|| area sh_emp6  year,   color(%30)  	///			
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///			
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("Employement Share") ///
			title("`ind'", ///
			size(medium)) ylabel(0(.1).6, nogrid) legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving(task`ind'.gph, replace)	
	*/
	set scheme lean1
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("`ytitle'") ///
			title("`ind'", ///
			size(medium)) ylabel(0(.1).6, nogrid) legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving($project/gph/task`ind'.gph, replace)	
	
	graph export $project/fig/task`ind'.png ,replace
	
	/*
	
	append using $project/data/clean/2008_v5
	append using $project/data/clean/2012_v5
	
	
