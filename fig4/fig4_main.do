
/* Notes

	Author: 		Evren Gülser
	Date : 			December 2023
	Paper: 			Job Polarization and Routinization
	Output: 		fig4.png
	Stata package:  plotplain package is required to produce the figures
											
	
	* 	This program ranks base year's occupations according to median hourly wage,
		allocates each occupation into a percentile and calculates the difference observed
		in each percentile. Finally, produces the figure showing the polarization patter 
		for the paper.
	
*/
		
	
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"	
	cd $project
	global dos $project/fig4
	
	do $dos/services_0412.do
	do $dos/services_0422.do
	
	do $dos/manuf_0412.do
	do $dos/manuf_0422.do
	
	do $dos/economy_0412.do
	do $dos/economy_0422.do
		
	cd $project/gph
	
	grc1leg taskEconomy.gph taskManufacturing.gph taskServices.gph, rows(1) ///
	imargin(0 0 0) iscale(1) legendfrom(taskServices.gph)  	///
	ysize(5) xsize(9.0) name(grc_graphs_employmentshare, replace) 			///
	saving($project/gph/grc_graphs, replace) pos(6) span l1title("Employment Share")

	gr draw grc_graphs_employmentshare,  ysize(2.6) xsize(5) 
	
	
	graph export $project/fig/fig4.png, replace
	
		