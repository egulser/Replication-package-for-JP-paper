
/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 2012_v3.dta
					- isco08.dta
	Output: 		iscotask2012.dta
	
	* 	This program i)  merges occupation based labor shares for 2012 to O*NET 17.0 task measures 
					 ii) assigns each occupation to a composite task measure for which the occupation ranks highest in intensity.
					 iii) 
	
*/



		
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"	
	cd $project
	
	use $project/data/clean/2012_v3 ,clear
	
	capture gen lswt = uweeklywh * weight	
	
	local minwage2012 (701+739)/2	
	local minwage2016 1404	
	local minwage2022 (4253+5500)/2		
	
	local skillproxy 	wage
	local skillproxy2 	wage/uweeklywh
	local skillproxy3 	educat5	
	
	local stat1 mean
	local stat2 median
	
	drop if emp_status != 1 
	

	drop if parttime
	tab isco88 [aw=weight]
	drop if isco08 == 62 | isco08 == 61 | isco08 == 63
	
	tab isco08 year [aw=lswt]

	
	collapse (count) num_obs = lswt (`stat2') wage (sum) lswt , by(isco08 year)
	drop if isco08 == .
	

	save $project/data/lswt2012.dta, replace

	use $project/data/isco08.dta ,clear
	gen int isco08_1 = isco08 /100
	
	collapse (mean) t*, by(isco08_1)
	
	ren isco08_1 isco08
	
	merge 1:1 isco08 using $project/data/lswt2012.dta
	
	drop if _merge != 3
	
	drop _merge
	
	do $project/do/task_construct.do

	* Occupation task links - tagging occupations based on their highest task value
	
	gen occ_nr_cog_anal  	= 0
	gen occ_nr_cog_pers  	= 0
	gen occ_r_cog  			= 0	
	gen occ_r_man 	 		= 0
	gen occ_nr_man_phys 	= 0
	gen occ_nr_man_pers 	= 0
	
		
	foreach var of varlist nr_cog_anal-nr_man_pers {
		forval i = 1/36 {
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
	sort occtask isco08
	
	replace occtask = 1 if isco08 == 22
	replace occtask = 4 if isco08 == 94
	
	
	keep year isco08 occtask
	sort isco08 
	saveold $project/data/iscotask2012.dta ,replace
	
