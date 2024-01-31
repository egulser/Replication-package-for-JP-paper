	
	
	cd $project	
	
	use $project/data/clean/2004_v5, clear
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta	
	saveold $project/data/tmp/2004_secall, replace

	use $project/data/clean/2008_v5, clear
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta
	saveold $project/data/tmp/2008_secall, replace	
	
	use $project/data/clean/2012_v5, clear
	egen 	tot_emp_occ = total(lswt), by(isco88)
	egen 	tot_emp 	= total(lswt)
	gen 	sh_emp_occ 	= tot_emp_occ /tot_emp*100 
	tab isco88 , sum(sh_emp_occ)
	collapse (mean) sh_emp_occ , by(isco88 year)
	list
	ren sh_emp_occ sh_emp	
	merge isco88 using $project/data/iscotask2004.dta
	saveold $project/data/tmp/2012_secall, replace	
	
	use 			$project/data/tmp/2004_secall ,clear
	append using 	$project/data/tmp/2008_secall
	append using 	$project/data/tmp/2012_secall
	
	drop _merge isco88
	
	
	collapse (rawsum) sh_emp, by(occtask year)
	replace sh_emp = sh_emp/100
	
	reshape wide sh_emp, i(year) j(occtask)

	gen sh_emp7 = sh_emp1+sh_emp2
	gen sh_emp8 = sh_emp5+sh_emp6
	
	saveold $project/data/allsectors04, replace
	
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
	local ind Economy
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
	