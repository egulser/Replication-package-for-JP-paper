	
	
	cd $project	
	
	use $project/data/clean/2012_v6, clear
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2012_secall, replace

	use $project/data/clean/2016_v6, clear
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta	
	drop if _merge != 3
	saveold $project/data/tmp/2016_secall, replace	
	
	use $project/data/clean/2022_v6, clear
	keep if ind_broad_4 == 4
	egen 	tot_emp_occ = total(lswt), by(isco08)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco08 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco08 using $project/data/iscotask2012.dta		
	saveold $project/data/tmp/2022_secall, replace	
	
	use 			$project/data/tmp/2012_secall ,clear
	append using 	$project/data/tmp/2016_secall
	append using 	$project/data/tmp/2022_secall
	
	drop _merge isco08
	
	
	collapse (rawsum) sh_emp, by(occtask year)
	drop if occtask == .
	replace sh_emp = sh_emp/100
	
	reshape wide sh_emp, i(year) j(occtask)

	gen sh_emp7 = sh_emp1+sh_emp2
	gen sh_emp8 = sh_emp5+sh_emp6
	
	append using $project/data/allsectors04
	
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
	
	
	set scheme lean1
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("`ytitle'") ///	
			title("`ind'", ///
			size(medium)) ylabel(0(.1).6, nogrid) legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving($project/gph/task`ind'.gph, replace)	
	