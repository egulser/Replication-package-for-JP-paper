
/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - 2004_v3.dta
					- 2012_v3.dta
	Output: 		polargraph.png
	
	* 	This program ranks base year's occupations according to median hourly wage,
		allocates each occupation into a percentile and calculates the difference observed
		in each percentile. Finally, produces the figure showing the polarization patter 
		for the paper.
	
*/
	
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"
	cd $project

	* Prep 2012 and 2022 samples
	use $project/data/clean/2004_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
		
	egen occsh_2004=sum(lswt),by(isco88)
	egen t=sum(lswt)
	replace occsh_2004=occsh_2004/t
	keep isco88 occsh_2004
	quietly by isco88, sort: keep if _n==1
	save $project/data/occ-shares-2004,replace
		
	use $project/data/clean/2012_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if wage == 0 
	drop if wage == .
		
	drop if lswt == 0
	assert lswt != 0	
	assert lswt != .	

	egen occsh_2012=sum(lswt),by(isco88)
	egen t=sum(lswt)
	replace occsh_2012=occsh_2012/t
	keep isco88 occsh_2012
	quietly by isco88, sort: keep if _n==1
	save $project/data/occ-shares-2012, replace
	
	* Prepare 1980 sample
	use $project/data/clean/2004_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
	
	gen hrw = wage/uweeklywh
	
	egen occ_mdwg = median(hrw), by(isco88)
	
	keep isco88 lswt occ_mdwg
	rename occ_mdwg occ_mdwg2004
	egen avlswt2004=mean(lswt),	by(isco88)
	egen occsh_2004=sum(lswt),	by(isco88)
	egen t=sum(lswt)
	replace occsh_2004=occsh_2004/t

	* Merge in 1990 occ shares
	sort  isco88
	merge isco88 using $project/data/occ-shares-2012
	drop _merge
	
	count if occsh_2004==.
	
	* Calculate percentiles by occupation
	sort occ_mdwg2004
	egen tot = sum(avlswt2004)
	gen rank = sum(avlswt2004)
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 100*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	egen gwt = sum(avlswt2004),by(perc)
	gen ewt = avlswt2004/gwt

	*Proportional Growth by Occupation
	gen doccsh0412 = (occsh_2012 - occsh_2004)/occsh_2004

	*Average Proportional Emp Growth by Occupation in Each Percentile
	*Same as Employment Share Change (in Percentage Points) since Each is 1 Percent to Start
	egen pdesh_0412 = sum(ewt*doccsh0412),by(perc)

	sort perc occ_mdwg2004

	replace pdesh_0412=pdesh_0412

	quietly by perc: gen first = _n==1
	keep if first==1
	sort perc
	list perc pdesh_0412 // pdesh_9000 pdesh_8000
	
	save $project/data/occ-shares-0412-byperc,replace

	rm $project/data/occ-shares-2004.dta
	rm $project/data/occ-shares-2012.dta


	************************************
	* Figure 1a
	************************************
	clear
	set mem 5m

	use $project/data/occ-shares-0412-byperc,clear
	label var perc "Occupation's Percentile in 2004 Wage Distribution"

	lowess pdesh_0412 perc ,gen(predsh0412) bwidth(.3) ylabel(-0.5(0.5)1.5) ytick(-0.5(0.5)1.5, grid)  ///
	ytitle("Observed change in employment shares") ///	
	saving($project/gph/low-demp-medwage-raw-0412.gph ,replace)
	graph export $project/fig/lowes0412.png ,replace 
	

	label var predsh0412 "2004-2012"
	saveold  $project/data/firstperiod.dta, replace
	
		tw spike	predsh0412 perc,  lw(medium) ///
		|| qfit predsh0412 perc, lcolor(red) lpattern(solid) ///
				 mcolor(blue) 	 ylabel(-0.3(0.20).3,) ylabel(,labsize(Large)) ///
				 legend( pos(4) ring(0) region(lstyle(outline)))  ///
				l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
				xtitle("Occupation's Percentile in 2004 Wage Distributions", 	///
				size(medsmall)) name(pattern64, replace)	
		
		graph export $project/fig/fig1a.png, replace		
	