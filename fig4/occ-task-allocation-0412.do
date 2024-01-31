/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 20104_v3.dta
					- isco88.dta
	Output: 		iscotask2012.dta
	
	* 	This program i)  merges occupation based labor shares for 2004 to O*NET 7.0 task measures 
					 ii) assigns each occupation to a composite task measure for which the occupation ranks highest in intensity by using a sorting algorithm.					
	
*/
		
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"	
	cd $project
	
	use $project/data/clean/2004_v3 ,clear
	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2004 (303+318)/2
	local minwage2008 (481+503)/2
	local minwage2012 (701+739)/2	
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	

	tab isco88 [aw=weight]
	drop if isco88 == 62 | isco88 == 61 
	
	drop if wage == 0
	
	tab isco88 year [aw=lswt], col nofreq
	
	drop if emp_status !=1
	
	tab isco88 year [aw=lswt], col nofreq
	
	
	collapse (count) num_obs = lswt (`stat2') wage (sum) lswt , by(isco88 year)
	drop if isco88 == .
	

	save $project/data/lswt2004.dta, replace

	use $project/data/isco88.dta, clear
	gen int isco88_1 = isco88 /100
	
	collapse (mean) t*, by(isco88_1)
	
	ren isco88_1 isco88
	
	merge 1:1 isco88 using $project/data/lswt2004.dta
	
	drop if _merge != 3
	
	drop _merge
	
	do $project/do/task_construct.do

	* Occupation task links - tagging occupations based on their highest task value.
	
	gen occ_nr_cog_anal  	= 0
	gen occ_nr_cog_pers  	= 0
	gen occ_r_cog  			= 0	
	gen occ_r_man 	 		= 0
	gen occ_nr_man_phys 	= 0
	gen occ_nr_man_pers 	= 0
	
		
	foreach var of varlist nr_cog_anal-nr_man_pers {
		forval i = 1/25 {
			if `var'>=nr_cog_anal in `i' {
				if `var'>=nr_cog_pers in `i' {
					if `var'>=r_man in `i' {
						if `var'>=r_cog in `i' {
							if `var'>=nr_man_phys in `i' {
								if `var'>=nr_man_pers in `i' {
									replace occ_`var' = 1 in `i'
								}
							}	
						}
					}	
				}
			}
		}
	}
	
	gen occtask = occ_nr_cog_anal + 2*occ_nr_cog_pers + 3*occ_r_cog + 4*occ_r_man + 5*occ_nr_man_phys + 6*occ_nr_man_pers
	
	order occtask 
	
	
	*Exceptions
	
	replace occtask = 5 if isco88 == 93
	
	
	
	keep year isco88 occtask
	sort isco88 
	saveold $project/data/iscotask04.dta ,replace
