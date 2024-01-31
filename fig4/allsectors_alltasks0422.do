	

/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 2012_v6.dta
					- 2016_v6.dta
					- 2022_v6.dta
					- allsectors04.dta
	Output: 		polargraph.png
	
	* 	This program i) calculates and links task shares for the second period and creates a dataset,	
					 ii) links first period and displays the tasks shares with an area graph.
			
	
*/	
	
	
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"
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
	
	forval i = 2/6 {
		local t = `i' - 1
	replace sh_emp`i' = sh_emp`i' + sh_emp`t'
	}
	
	
	label var sh_emp1 "Non-Routine Cognitive" 
	label var sh_emp2 "Non-Routine Personal"
	label var sh_emp3 "Routine cognitive"
	label var sh_emp4 "Routine manual"
	label var sh_emp5 "Non-Routine Manual Physical" 
	label var sh_emp6 "Non-Routine Manual Personal"	
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

	
	local lc gs5
	local lw vthin
	
	twoway 	area sh_emp6 sh_emp5 sh_emp4 sh_emp3 sh_emp2 sh_emp1   year,  ///	
	color(	"247 247 247"	///
			"219 219 219"	///
			"189 189 189"	///
			"150 150 150"	///
			"99	99	99"	///
			"37	37 37" )	///
			lw (`lw' `lw' `lw' `lw' `lw' `lw') ///
			lc (`lc' `lc' `lc' `lc' `lc' gs3) ///
			xlabel(2004(4)2016 2022) ///
			xtitle("Year") ytitle("Employement Share") ///
			title("`ind'", ///
			size(medium)) yaxis(1 2) ylabel(0(.2)1, axis(2) nogrid) legend( order(1 2 3 4 5 6) ///
			pos(6) ring(1) rows(2)   ///
			region(lstyle(outline)))  	saving($project/gph/task`ind'.gph, replace)	
		
		
	graph export $project/fig/fig4_areagraph.png, replace
		