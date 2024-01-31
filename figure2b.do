/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 2012_v3.dta
					- 2022_v3.dta
	Output: 		polargraph.png
	
	* 	This program ranks base year's occupations according to median hourly wage,
		allocates each occupation into a percentile and calculates the difference observed
		in each percentile. Finally, produces the figure showing the polarization patter 
		for the paper.
	
*/		
	
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"
	cd $project
	
	tempfile sgt	
	local female 2
			
	use $project/data/clean/2022_v3 ,clear
	
	gen lswt = uweeklywh * weight 	
	drop if (lswt == 0 | lswt == .)
	drop if occ1 == 6	
	drop if (wage == 0 | wage == .)
	drop if emp_status>1	
	drop if age_group == 8
	
	drop if female == `female'
	
	* Demographics *****************	
	gen 		educ_3 = 1 if educat5 == 1 | educat5 == 2
	replace 	educ_3 = 2 if educat5 == 3 | educat5 == 4
	replace 	educ_3 = 3 if educat5 == 5
			
	gen ages = 0
	replace ages = 1 if age_group <7
	replace ages = 2 if inrange(age_group,7,10)
	replace ages = 3 if age_group >10	
	*********************************	
	
	gen hrw = wage/uweeklywh	
	sort hrw 	
	
	egen rank = rank(hrw), by(isco08)
	egen count = count(hrw), by(isco08)
	gen pct_occ = 10 * (rank - 0.5) / count
	replace pct_occ =int(pct) +1
	
	collapse (rawsum) lswt_t1=lswt ,by(year isco08 pct_occ  educ_3 female)
	
	sort female educ_3 pct_occ isco08 pct_occ
	
	egen occsh_2022 = sum(lswt_t1),by(isco08)
	egen demogs_2022=sum(lswt), 	by(isco08 female educ_3)
	egen sgt_t1=sum(lswt), 			by(female educ_3)
	egen t=sum(lswt)
	replace occsh_2022=occsh_2022/t	
	replace demogs_2022=demogs_2022/t
	
		
	sort female isco08 educ_3	
	
	
	save $project/data/occ-shares-2022, replace
		
**# First year # ***
	use $project/data/clean/2012_v3 ,clear
	
	drop if s6>64
	
	gen lswt = uweeklywh * weight 
	drop if (wage == 0 | wage == .)
	drop if occ1 == 6	
	drop if (lswt == 0 | lswt == .)
	drop if emp_status>1
	
	drop if female == `female'

	* Demographics *****************	
	gen 		educ_3 = 1 if educat5 == 1 | educat5 == 2
	replace 	educ_3 = 2 if educat5 == 3 | educat5 == 4
	replace 	educ_3 = 3 if educat5 == 5
			
	gen ages = 0
	replace ages = 1 if age_group <7
	replace ages = 2 if inrange(age_group,7,10)
	replace ages = 3 if age_group >10	
	*********************************	
	
	gen hrw = wage/uweeklywh	
	egen occ_mdwg = mean(hrw), by(isco08)
	
	keep isco08 lswt occ_mdwg female educ_3 ages hrw
	rename occ_mdwg occ_mdwg2012
	egen avlswt2012 =mean(lswt),	by(isco08 female educ_3)
	egen occsh_2012 =sum(lswt),		by(isco08)
	egen demogs_2012=sum(lswt), 	by(isco08 female educ_3)
	egen sgt_t0=sum(lswt), 			by(female educ_3)
	
	egen avlswt2012_demog =mean(lswt),	by(isco08 female)
	
	egen t=sum(lswt)
	replace occsh_2012=occsh_2012/t
	replace demogs_2012=demogs_2012/t
	replace sgt_t0 = sgt_t0/t
		
	count if occsh_2012==.
	capture count if occsh_2022==.
	
	capture mvencode occsh_2022, mv(0)
	* Must drop occupation if no employment in this occupation in 2004 since no base value
	drop if occsh_2012==.
	
	egen rank_2 = rank(hrw), by(isco08)
	egen count = count(hrw), by(isco08)
	gen pct_occ = 10 * (rank_2 - 0.5) / count
	replace pct_occ =int(pct) +1
	
	sort female isco08 educ_3
	
**# Second Year # ***
	
	
	* Calculate percentiles/deciles by occupation
	sort occ_mdwg2012 pct
	egen tot = sum(avlswt2012)
	gen rank = sum(avlswt2012)
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 10*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	
	egen gwt 		= sum(avlswt2012), by(perc)
	gen ewt 		= avlswt2012/gwt
	
	egen gwt_demog 	= sum(avlswt2012_demog),by(perc)
	gen ewt_demog  	= avlswt2012_demog/gwt_demog
	
	sort female educ_3 pct_occ isco08
	
	merge m:1 female educ_3 pct_occ isco08 using $project/data/occ-shares-2022
			
	drop if _merge !=3	
	tab isco08 perc
	
	local method 2
	
**# Method choose #1
	
	if `method' == 1 {

		tab pct perc if isco08 == 51
		tab pct perc if isco08 == 52
		tab pct perc if isco08 == 75
		tab pct perc if isco08 == 82
		tab pct perc if isco08 == 72
		tab pct perc if isco08 == 26
		tab pct perc if isco08 == 14
		
		replace perc = 2  if pct_occ == 6 & isco08 == 51
		replace perc = 3  if pct_occ == 9 & isco08 == 52
		replace perc = 4  if pct_occ == 5 & isco08 == 75
		replace perc = 4  if pct_occ == 4 & isco08 == 82
		replace perc = 6  if pct_occ == 1 & isco08 == 72
		replace perc = 10 if pct_occ == 6 & isco08 == 26	
		replace perc = 7  if pct_occ == 1 & isco08 == 14
	}
		
	if `method' == 2 {
			
		replace perc = 2  if isco08 == 51
		replace perc = 2  if isco08 == 52
		replace perc = 4  if isco08 == 75
		replace perc = 5  if isco08 == 82
		replace perc = 6  if isco08 == 72
		replace perc = 10 if isco08 == 26
		replace perc = 8  if isco08 == 14
		replace perc = 8  if isco08 == 33
		replace perc = 7  if isco08 == 83
		replace perc = 5  if isco08 == 91
		replace perc = 7  if isco08 == 41
	}	
	

		
**# Calculating the change 	

	*Proportional Growth by Occupation
	gen doccsh1222 = (occsh_2022 - occsh_2012)/occsh_2012
	gen demogs1222 = (demogs_2022-demogs_2012)/demogs_2012
	
	*Average Proportional Emp Growth by Occupation in Each Percentile/Decile
		
**# Bookmark #2 Change 1 to 2 for the other result:

*1 	egen demopdesh_1222 = sum(ewt_demog*doccsh1222),by(perc female )

*2 	egen demopdesh_1222 = sum(ewt_demog*demogs1222),by(perc female )

		
	egen pdesh_1222 		= sum(ewt*doccsh1222),by(perc)
	egen demopdesh_1222 	= sum(ewt_demog*demogs1222),by(perc female)
	collapse (mean) demopdesh*  /// 
					pdesh_1222 demogs* doccsh1222 sgt_t0 sgt_t1 , by(perc female educ_3)
					
	egen demogspdesh = sum(demopdesh_1222),by(perc female)	
	egen demogspdesh_educ = sum(demopdesh_1222),by(perc educ_3)
		
	set scheme plotplain
	
	* Display the figure without decomposition
	
	tw bar pdesh_1222 perc ,xlabel(1(1)10) ytitle("Percentage Change") xtitle("Employment-weighted deciles over 2012's hourly wage distribution")
	
	graph export $project/fig/deciles_pre_deco1222.png, replace
	
	
	* With decomposition
	
	tw bar demogspdesh perc if !female , barw(0.9) color(eltblue%30) ///
	|| bar demogspdesh perc if female, 	barw(0.8) color(maroon%30) ///
	|| qfit demogspdesh perc if !female, lp(dash) 	 ///
	|| qfit demogspdesh perc if female , lp(solid) lc(maroon) ///	
	,legend(pos(6) rows(2) ring(1) region(lcolor(black)) /// 	
	order(1 "Males" 2 "Females" 3 "Quadratic fit for males" 4 "Quadratic fit for Females" )) 		 ///
	xtitle("Employment-weighted deciles over hourly wage distribution of 2012") ///
	ytitle("Percentage Change") 		 	 ///
	xlabel(1(1)10) saving($project/gph/deciles_gender_deco_2012_2022.gph, replace)
	
	graph export $project/fig/fig2b.png , replace
	
