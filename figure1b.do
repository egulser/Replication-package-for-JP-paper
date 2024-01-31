
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
	

	* Prep 2012 and 2022 samples
	use $project/data/clean/2012_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
		
	egen occsh_2012=sum(lswt),by(isco08)
	egen t=sum(lswt)
	replace occsh_2012=occsh_2012/t
	keep isco08 occsh_2012
	quietly by isco08, sort: keep if _n==1
	save $project/data/occ-shares-2012,replace
		
	use $project/data/clean/2022_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if wage == 0 
	drop if wage == .
		
	drop if lswt == 0
	assert lswt != 0	
	assert lswt != .	

	egen occsh_2022=sum(lswt),by(isco08)
	egen t=sum(lswt)
	replace occsh_2022=occsh_2022/t
	keep isco08 occsh_2022
	quietly by isco08, sort: keep if _n==1
	save $project/data/occ-shares-2022, replace
	
	* Prepare 1980 sample
	use $project/data/clean/2012_v3 ,clear
	
	gen lswt = uweeklywh * weight if (emp_status == 1 & wage != 0 & wage != .)
	drop if emp_status != 1
	drop if (wage == 0 | wage == .)
	
	assert lswt != 0
	assert lswt != .
	
	gen hrw = wage/uweeklywh
	
	egen occ_mdwg = median(hrw), by(isco08)
	
	keep isco08 lswt occ_mdwg
	rename occ_mdwg occ_mdwg2012
	egen avlswt2012=mean(lswt),	by(isco08)
	egen occsh_2012=sum(lswt),	by(isco08)
	egen t=sum(lswt)
	replace occsh_2012=occsh_2012/t

	* Merge in 1990 occ shares
	sort isco08
	merge isco08 using $project/data/occ-shares-2022
	drop _merge

	count if occsh_2012==.
	count if occsh_2022==.
	
	mvencode occsh_2022, mv(0)
	drop if occsh_2012==.

	* Calculate percentiles by occupation
	sort occ_mdwg2012
	egen tot = sum(avlswt2012)
	gen rank = sum(avlswt2012)
	gen arank = (rank + rank[_n-1])/2
	replace arank = rank/2 if arank==.
	gen prank = 100*(arank/tot)
	gen perc = int(prank)
	replace perc = perc + 1
	egen gwt = sum(avlswt2012),by(perc)
	gen ewt = avlswt2012/gwt

	*Proportional Growth by Occupation
	gen doccsh1222 = (occsh_2022 - occsh_2012)/occsh_2012
	

	*Average Proportional Emp Growth by Occupation in Each Percentile
	*Same as Employment Share Change (in Percentage Points) since Each is 1 Percent to Start
	egen pdesh_1222 = sum(ewt*doccsh1222),by(perc)

	sort perc occ_mdwg2012

	replace pdesh_1222=pdesh_1222

	quietly by perc: gen first = _n==1
	keep if first==1
	sort perc
	list perc pdesh_1222 
	
	save $project/data/occ-shares-1222-byperc,replace

	rm $project/data/occ-shares-2012.dta
	rm $project/data/occ-shares-2022.dta

	************************************
	* Figure 1b
	************************************
	clear
	set mem 5m

	use $project/data/occ-shares-1222-byperc,clear
	label var perc "Occupation's Percentile in 2012 Wage Distribution"

	lowess pdesh_1222 perc , gen(predsh1222) bwidth(.3) ytick(-0.5(0.5)1.5, grid) ///
	ytitle("Observed change in employment shares") ///
	saving($project/gph/low-demp-medwage-raw-1222.gph ,replace)
	graph export $project/fig/lowes1222.pdf, replace

	
	tw spike	predsh1222 perc,  lw(medium) ///
		|| qfit predsh1222 perc, lcolor(red) lpattern(solid) ///
				mcolor(blue) 	 ylabel(-0.3(0.20).3) ///
				legend( pos(4) ring(0) region(lstyle(outline)))  ///
				l1title("100 x Change in Employment Share", size(medsmall)) ytitle("") 	///
				xtitle("Occupation's Percentile in 20112 Wage Distributions", 	///
				size(medsmall)) name(pattern64, replace)	
				
	graph export $project/fig/fig1b.png, replace			
	

	