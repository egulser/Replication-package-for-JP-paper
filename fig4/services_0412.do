		
	
	cd $project
	use $project/data/clean/2004_v3 ,clear
	append using $project/data/clean/2008_v3
	append using $project/data/clean/2012_v3
	tab emp_status year
	
qui {
	forval y = 2004(4)2012 {
	
	use $project/data/clean/`y'_v3 ,clear
	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2	
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	
	if year == 2004 {
	drop if wage < (`minwage2004' * 0.75) 
	}
	
	if year == 2008 {
	drop if wage < (`minwage2008' * 0.75) 
	}
	
	if year == 2012 {
	drop if wage < (`minwage2012' * 0.75)
	}
	
	drop if parttime
	tab isco88 [aw=weight]
	drop if isco88 == 33 | isco88 == 62 | isco88 == 61 | isco88 == 13 
	
	tab isco88 year [aw=lswt], col
	
	
	local ind ind_broad_4		
	gen 	ind_broad_4 = 0
	replace ind_broad_4	= 1 if inrange(sector, 1,3)
	replace ind_broad_4	= 2 if inrange(sector, 5, 39)
	replace ind_broad_4	= 3 if inrange(sector, 41, 43)
	replace ind_broad_4	= 4 if inrange(sector, 45, 99)
	assert ind_broad_4 != 0
	
	noi tab isco88 year [aw=lswt], col
	
	saveold $project/data/clean/`y'_v5, replace
	
	}
}


	use $project/data/clean/2004_v5, clear
	keep if ind_broad_4 == 4
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta	
	saveold $project/data/tmp/2004_sec4, replace

	use $project/data/clean/2008_v5, clear
	keep if ind_broad_4 == 4
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta	
	saveold $project/data/tmp/2008_sec4, replace	
	
	use $project/data/clean/2012_v5, clear
	keep if ind_broad_4 == 4
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta	
	saveold $project/data/tmp/2012_sec4, replace	
	
	use 			$project/data/tmp/2004_sec4 ,clear
	append using 	$project/data/tmp/2008_sec4
	append using 	$project/data/tmp/2012_sec4
	
	drop _merge isco88
	
	
	collapse (rawsum) sh_emp, by(occtask year)
	replace sh_emp = sh_emp/100
	
	reshape wide sh_emp, i(year) j(occtask)

	gen sh_emp7 = sh_emp1+sh_emp2
	gen sh_emp8 = sh_emp5+sh_emp6	
	
	saveold $project/data/services04 ,replace
	
	/*
	
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
	local ind Services
	local lpattern1 l 
	local lpattern2 -
	local lpattern3 .-.
	local lpattern4 -####-####-####-###
	local lpattern5 dot
	
	twoway 	line sh_emp7 sh_emp3 sh_emp4 sh_emp8 year,  ///
			lpattern(`lpattern1' `lpattern2' `lpattern3' `lpattern5' ) ///
			lw(`lw' `lw' `lw' `lw') lc(`lc' `lc' `lc' `lc' ) ///
			xlabel(2004(4)2012) ///
			xtitle("Year") ytitle("Employement Share") ///
			title("`ind'", ///
			size(medium)) ylabel(0(.1).6, nogrid) legend( pos(6) ring(1) rows(1)  ///
			region(lstyle(outline)))  	saving(task`ind'.gph, replace)	
	
	/*
	
	append using $project/data/clean/2008_v5
	append using $project/data/clean/2012_v5
	
	
