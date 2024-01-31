	
/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 2004_v3.dta
					- 2012_v3.dta
	Output: 		polargraph.png
	
	* 	This program ranks base year's occupations according to median hourly wage,
		allocates each occupation into a decile and calculates the difference observed
		in each decile. For each decile decomposes the change in employment share into 
		males and females. Displays the results with a figure.	
	
*/		
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"
	cd $project
	
	tempfile sgt
	local female 2	
	local fy 2004 
	local ly 2012
	local isco isco88
												
	use $project/data/clean/`ly'_v3 ,clear
	
	count 
	
	gen lswt = uweeklywh * weight 
	*drop if emp_status != 1
	drop if (lswt == 0 | lswt == .)
	drop if occ1 == 6	
	drop if (wage == 0 | wage == .)
	drop if emp_status>1
	
	drop if age_group == 14
	
	drop if female == `female'
	
	****************  Demographics *********************
	
	gen 		educ_3 = 1 if educat5 == 1 | educat5 == 2
	replace 	educ_3 = 2 if educat5 == 3 | educat5 == 4
	replace 	educ_3 = 3 if educat5 == 5
			
	gen ages = 0
	replace ages = 1 if age_group <7
	replace ages = 2 if inrange(age_group,7,10)
	replace ages = 3 if age_group >10	
	***************************************************
	
	gen hrw = wage/uweeklywh
	
	egen rank = rank(hrw), by(`isco')
	egen count = count(hrw), by(`isco')
	gen pct_occ = 10 * (rank - 0.5) / count
	replace pct_occ =int(pct) +1
	
	collapse (rawsum) lswt_t1=lswt ,by(year `isco' pct_occ educ_3 female)
	
	sort female educ_3 pct_occ `isco'
	
	egen occsh_`ly' = sum(lswt_t1),by(`isco')
	egen demogs_`ly'=sum(lswt), 	by(`isco' female educ_3)
	egen sgt_t1=sum(lswt), 			by( female educ_3)
	egen t=sum(lswt)
	replace occsh_`ly'=occsh_`ly'/t
	replace demogs_`ly'=demogs_`ly'/t
	replace sgt_t1 = sgt_t1/t	

	save $project/data/occ-shares-`ly',replace

	**# Bookmark #1 Prepare data for the first period
			
	use $project/data/clean/`fy'_v3 ,clear
	
	gen lswt = uweeklywh * weight 
	drop if (lswt == 0 | lswt == .)
	drop if occ1 == 6	
	drop if (wage == 0 | wage == .)
	drop if emp_status>1
	
	drop if age_group > 13
	
	****************  Demographics ********************* 
	
	gen 		educ_3 = 1 if educat5 == 1 | educat5 == 2
	replace 	educ_3 = 2 if educat5 == 3 | educat5 == 4
	replace 	educ_3 = 3 if educat5 == 5
			
	gen ages = 0
	replace ages = 1 if age_group <7
	replace ages = 2 if inrange(age_group,7,10)
	replace ages = 3 if age_group >10	
	***************************************************
	
	gen hrw = wage/uweeklywh
	
	egen occ_mdwg = mean(hrw), by(`isco')
	
	keep `isco' lswt occ_mdwg female educ_3 ages hrw
	rename occ_mdwg occ_mdwg`fy'
	egen avlswt`fy' =mean(lswt),	by(`isco' female educ_3)
	egen occsh_`fy' =sum(lswt),		by(`isco')
	egen demogs_`fy'=sum(lswt), 	by(isco88 female educ_3)
	egen sgt_t0=sum(lswt), 			by( female educ_3)
	
	egen avlswt`fy'_demog =mean(lswt),	by(`isco' female educ_3)
	
	egen t=sum(lswt)
	replace occsh_`fy'=occsh_`fy'/t
	replace demogs_`fy'=demogs_`fy'/t
	replace sgt_t0 = sgt_t0/t
	
	
	count if occsh_`fy'==.
	sort hrw 
	
	egen rank_2 = rank(hrw), by(`isco')
	egen count = count(hrw), by(`isco')
	gen pct_occ = 10 * (rank_2 - 0.5) / count
	replace pct_occ =int(pct) +1
	
	
	* Calculate percentiles by occupation
	sort occ_mdwg`fy' pct
	egen tot = sum(avlswt`fy')
	gen rank = sum(avlswt`fy')
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 10*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	
	egen gwt = sum(avlswt`fy'),by(perc)
	gen ewt = avlswt`fy'/gwt
	
	egen gwt_demog = sum(avlswt`fy'_demog),by(perc)
	gen ewt_demog  = avlswt`fy'_demog/gwt_demog
	
	sort female educ_3 pct_occ `isco'
	
	merge m:1 female educ_3 pct_occ `isco' using $project/data/occ-shares-`ly'

	drop if _merge !=3
	
	
	*Proportional Growth by Occupation
	gen doccsh_`fy'_`ly'= (occsh_`ly' - occsh_`fy')/occsh_`fy'
	gen demogs_`fy'_`ly'= (demogs_`ly'-demogs_`fy')/demogs_`fy'
	

	*Average Proportional Emp Growth by Occupation in Each Percentile or Decile
	
	egen 	 pdesh_`fy'_`ly'	= sum(ewt*doccsh_`fy'_`ly'),by(perc)
	egen demopdesh_`fy'_`ly' 	= sum(ewt_demog*demogs_`fy'_`ly'),by(perc female educ_3)
	egen demogs_v1_`fy' 		= sum(ewt_demog*demogs_`fy'),by(perc female educ_3)
	egen demogs_v1_`ly' 		= sum(ewt_demog*demogs_`ly'),by(perc female educ_3)
	
	tab `isco', su(doccsh_`fy'_`ly')
	tab `isco', su(pdesh_`fy'_`ly')
	tab `isco' perc
	
	egen doccsh_`fy'_`ly'_v2 = sum(doccsh_`fy'_`ly'), by(perc)
	tab `isco', su(doccsh_`fy'_`ly'_v2)
	
	sort perc occ_mdwg`fy'
			
	collapse (mean) demopdesh_`fy'_`ly' demogs_v1_`fy' demogs_v1_`ly' /// 
					pdesh_`fy'_`ly' doccsh_`fy'_`ly' sgt_t0 sgt_t1 , by(perc female educ_3)
										
	egen sumdemopdesh = sum(demopdesh_2004_2012), by(perc)			
	egen demogspdesh = sum(demopdesh_`fy'_`ly'),by(perc female)	
	egen demogspdesh_educ = sum(demopdesh_`fy'_`ly'),by(perc educ_3)
	
	set scheme plotplain
	
	* Without decomposition
	
	set scheme plotplain
	tw bar pdesh_`fy'_`ly' perc ,xlabel(1(1)10) ytitle("Percentage Change") xtitle("Employment-weighted deciles over 20004's hourly wage distribution")
	
	graph export $project/fig/deciles_pre_deco0412.png, replace
	
	* With decomposition

	tw bar demogspdesh perc if !female , barw(0.9) color(eltblue%30) ///
	|| bar demogspdesh perc if female, 	barw(0.8) color(maroon%30) ///
	|| qfit demogspdesh perc if !female, lp(dash) 	 ///
	|| qfit demogspdesh perc if female , lp(solid) lc(maroon) ///	
	,legend(pos(6) rows(2) ring(1) region(lcolor(black)) /// 	
	order(1 "Males" 2 "Females" 3 "Quadratic fit for males" 4 "Quadratic fit for Females" )) 		 ///
	xtitle("Employment-weighted deciles over hourly wage distribution of 2004") ///
	ytitle("Percentage Change") 		 	 ///
	xlabel(1(1)10) saving($project/gph/deciles_gender_deco_2004_2012.gph, replace)
	
	graph export $project/fig/fig2a.png, replace
	
	
