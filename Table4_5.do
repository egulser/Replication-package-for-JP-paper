
/* Notes

	Author: 		Evren Gülser
	Date : 			Auguts - December 2023
	Paper: 			Job Polarization and Routinization
	Database used:  - piaac_tr_derived.dta 
	- 2004_v3.dta
					- 2012_v3.dta
	Output: 		polargraph.png
	
	* 	This program creates a dataset to estimate Eq (3) and Eq (4) in paper and empirical models in thesis.
		To compare the suitabiltiy of task measures derived from PIAAC and O*NET, this program utilizes Piaac 
		data for Turkey and O*NET data.
		
	* 	PIAAC task measures are obtained using the crosswalk in	Rica et al. (2020)
	
*/
	
		
	
	global project "/Users/evrengulser/Desktop/TUIKDATA/replication_kit"	
	use $project/data/piaac_tr_derived.dta ,clear
	
	
	*using task items in Rica et al. (2020)
	
	
	/*
	Abstract 1 	Face complex problems (<30 mins)										F_Q05b 
			 2 	Use more advanced math or statistics such as calculus..., 				G_Q03h
			 3 	Read articles in professional journals or scholarly publications		G_Q01d
			 4 	Planning the activities of others										F_Q03b
			 5 	Persuading/influencing people											F_Q04a
			  	
	Routine	 1 	Planning your own activities (inverse)									F_Q03a
			 2 	Organising your own time (inverse)										F_Q03c
			 3 	Instructing, training or teaching people... (inverse)					F_Q02b
			 4 	Making speeches or giving presentations (inverse)						F_Q02c
			 5 	Advising people (inverse)												F_Q02e
			  	
	Manual	 1 	Working physically for a long period									F_Q06b
			 2 	Using skill or accuracy with hands or fingers							F_Q06c
	
	*/
	
	ren F_Q05b a1
	ren G_Q03h a2
	ren G_Q01d a3
	ren F_Q03b a4
	ren F_Q04a a5
	
	ren F_Q03a r1
	ren F_Q03c r2	
	ren F_Q02b r3
	ren F_Q02c r4
	ren F_Q02e r5
	
	ren F_Q06b m1
	ren F_Q06c m2
	
	
	*Inverse of routine tasks
	
	replace r1 = 6 - r1
	replace r2 = 6 - r2
	replace r3 = 6 - r3
	replace r4 = 6 - r4
	replace r5 = 6 - r5
	
	gen weight = SPFWT0
	
	foreach var of varlist a1-m2 {
		summ `var' [aw=weight]
		replace `var'= (`var'-r(mean))/r(sd)
	}
	
	
	gen abstract 	= a1 + a2 + a3 + a4 + a5 
	gen routine 	= r1 + r2 + r3 + r4 + r5
	gen manual 		= m1 + m2
	
	
	foreach var of varlist abstract-manual {
		summ `var' [aw=weight]
		replace `var'= (`var'-r(mean))/r(sd)
	}

	
	gen occ2 = ISCO2C
	gen occ1 = ISCO1C
	
	destring, replace dpcomma
	
	drop if (occ2< 11 | occ2>99)
	
	local tasks abstract routine manual

	gen sector_1 = ISIC1C 
	gen sector_2 = ISIC2C
	gen hincome = EARNHRBONUSDCL
	gen female = 1- A_N01_T // female dummy
	gen male   = 1-female
	gen edcat3 = B_Q01a_T
	gen edcat5 = EDCAT6
	gen pared  = PARED
	gen private_public_nonprof = D_Q03
	gen private = (private_public_nonprof == 1)
	gen emp_status = D_Q04 // 1 - employee 2- self employed
	gen selfemp = emp_status - 1 
	gen exp = C_Q09
	gen age_int_5 = AGEG5LFS
	gen age_int_10 = AGEG10LFS
	gen firmsize = D_Q06a
	gen exp_sq = exp^2
	tab firmsize , gen(firm_d)
	tab occ2, gen(occ2_d)
	gen nativesp = (NATIVESPEAKER == 2) // non-native
	gen compex = (COMPUTEREXPERIENCE == 2)
	gen contract_permanent = (D_Q09 == 1)
	gen exp_sq_100 = exp_sq/100
	gen compex_2 = (COMPUTEREXPERIENCE == 1)
	gen jobtrain = B_Q12c == 1
	gen motherseduc = J_Q06b_T
	gen isco08 = ISCO08_C
	
	gen isco88 = isco08
	iscogen occ4 = isco88(isco08), from(isco08)
	gen int occ5 = occ4/100
	replace isco88 = occ5
	
	replace isco08 = occ2
	
	egen occ_mean_abs = mean(abstract), by(occ2)
	egen occ_mean_rou = mean(routine), 	by(occ2)
	egen occ_mean_man = mean(manual), 	by(occ2)
	
	egen isco88_mean_abs = mean(abstract),  by(occ5)
	egen isco88_mean_rou = mean(routine), 	by(occ5)
	egen isco88_mean_man = mean(manual), 	by(occ5)	
	
	collapse (mean) isco88_mean* [aw=weight], by(occ5)
	gen isco88 = occ5
	saveold rti_piaac_isco88, replace
	
	gen isco08_mean_abs = occ_mean_abs
	gen isco08_mean_rou = occ_mean_rou
	gen isco08_mean_man = occ_mean_man
	
	tab isco88_mean_abs
	tab isco08_mean_abs
	
	preserve
	
	collapse (mean) abstract routine manual [aw=weight], by(isco88)
	drop if isco88 == .
	
	saveold isco88_piaac, replace
	
	restore
	
	preserve
	collapse (mean) abstract routine manual [aw=weight], by(isco08)	
	saveold isco08_piaac, replace
	
	restore
		
	
	
	collapse (mean) occ_* [aw=weight] , by(occ2)

	
	xi i.sector_1
	
	gen sector_1_dummy = 0
	
	forval i = 1/20 {
		local y = `i' + 1
		replace sector_1_dummy = `i'*_Isector_1_`y' if _Isector_1_`y' != 0
	}

	replace sector_1_dummy = sector_1_dummy + 1
	tab sector_1_dummy
	gen sec_1_d = sector_1_dummy
	
	
	reg hincome `tasks' i.sector_1_dummy  i.private_public_nonprof i.emp_status exp i.age_int_5 i.firmsize
	
	local occ_d i.occ2
	local ind_firm_d _Isector_1_* firm_d* private jobtrain  contract_permanent
	local occ occ2_d*
	local title Estimation Results of Task Scores with male education occupation and industry dummmies and age tenure and tenure squared
	local ns nativesp
	local var contract_permanent
	
	local demog male age_int_5 
	local humanc i.edcat5 compex exp exp_sq_100 motherseduc nativesp 
	local jobcharac private jobtrain  contract_permanent
	
	
	estimates clear
	
	reg hincome abstract routine manual male compex `var'  nativesp  age_int_5 exp exp_sq i.edcat5 i.pared `ind_firm_d' `occ' [aw=weight]
	
	
	*model1-2 abstract 
	eststo mod1: reg abstract 	`humanc' `demog' `jobcharac' `ind_firm_d' 		[aw=weight]
	eststo mod2: reg abstract 	`humanc' `demog' `jobcharac' `ind_firm_d' `occ' [aw=weight]
  
	*model3-4 routine`humanc'   `jobcharac' 
	eststo mod3: reg routine 	`humanc' `demog' `jobcharac' `ind_firm_d' 		[aw=weight]
	eststo mod4: reg routine 	`humanc' `demog' `jobcharac' `ind_firm_d' `occ' [aw=weight]
  
	*model5-6 manual`humanc'   `jobcharac' 
	eststo mod5: reg manual 	`humanc' `demog' `jobcharac' `ind_firm_d' 		[aw=weight]
	eststo mod6: reg manual 	`humanc' `demog' `jobcharac' `ind_firm_d' `occ' [aw=weight]
	
	esttab  	mod1 mod2 mod3 mod4 mod5 mod6 ///
				using $project/table/table2.csv , ///
	p(%12.2f)  	replace /* title (`title') */ unstack label ar2  ///
				/*star(* .10 ** .05 *** .01)*/  drop (*Isector_1_* firm_d* occ2_d*) compress
								
	estimates clear
	estimates dir
		
	
	eststo mod1: reg hincome abstract-manual edcat5  exp exp_sq_100 i.firmsize  ///
	male 	private jobtrain    nativesp motherseduc  [aw=weight] 
	
		
	
	eststo mod1: reg hincome `humanc' `demog'  `ind_firm_d' 		 		[aw=weight] 
	
	eststo mod2: reg hincome `tasks'  `ind_firm_d' 							[aw=weight] 
	
	eststo mod3: reg hincome `occ' `ind_firm_d' 							[aw=weight] 
	
	eststo mod4: reg hincome `tasks'  `humanc' `demog'  `ind_firm_d' 		[aw=weight] 
	
	eststo mod5: reg hincome `humanc' `demog'  `ind_firm_d' `occ'			[aw=weight] 
	
	eststo mod6: reg hincome `tasks' `ind_firm_d' `occ'					 	[aw=weight] 
	
	eststo mod7: reg hincome `tasks' `humanc' `demog' `ind_firm_d' `occ' 	[aw=weight] 
	
	
	
	esttab  	mod1 mod2 mod3 mod4 mod5 mod6 mod7 ///
				using $project/table/table3.csv , ///
				p(%12.2f) replace /* title (`title') */  label ar2 ///
				/*star(* .10 ** .05 *** .01)*/  drop (*Isector_1_* firm_d* occ2_d*) compress
	
	local taskmeans occ_mean_abs occ_mean_rou occ_mean_man
	
	estimates clear
	
	local otherc i.edcat5 compex exp exp_sq_100 motherseduc  private jobtrain 				
	
	reg abstract hincome `humanc' `demog'  `ind_firm_d' [aw=weight]
	
	
	eststo mod1: 	reg hincome abstract-manual `taskmeans' [aw=weight]
					
					
	eststo mod2: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.occ_mean_abs	///
					c.routine#c.occ_mean_rou 	///	
					c.manual#c.occ_mean_man  	[aw=weight]
					
					
	eststo mod3: 	reg hincome abstract-manual `taskmeans' ///
					male nativesp jobtrain private [aw=weight]
					
					
	eststo mod4: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.occ_mean_abs	///
					c.routine#c.occ_mean_rou 	///	
					c.manual#c.occ_mean_man  	///				
					male nativesp jobtrain private ///
					[aw=weight]
					
	eststo mod5: 	reg hincome abstract-manual `taskmeans' ///
					male nativesp `otherc' [aw=weight]					
					
	
	eststo mod6: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.occ_mean_abs	///
					c.routine#c.occ_mean_rou 	///	
					c.manual#c.occ_mean_man  	///				
					male `otherc'[aw=weight]		
					
	*PROPOSITION 2				
	esttab  	mod1 mod2 mod3 mod4 mod5 mod6 ///
				using $project/table/table4.csv , ///
	b(%12.2f)			p(%12.2f) replace /* title (`title') */  label ar2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15) interaction(" X ")  compress				
	
	egen occweight = sum(weight), by(occ2)
	egen occweight_tot = total(weight), by(occ2)
	
	gen isco08 = occ2
	
	merge m:1 isco08 using $project/data/tasks2012.dta 
	
	pca nr_cog_anal nr_cog_pers 
	predict onet_abstract, score
	
	pca r_cog r_man
	predict onet_routine, score
	
	pca nr_man_pers nr_man_phys
	predict onet_manual, score
	
	estimates clear
	eststo mod1: pwcorr occ_mean* onet_*
	
	eststo clear
	/*
	estpost pwcorr occ_mean* onet_*, star(.05) 
	eststo correlation
	esttab correlation using Correlations.rtf, unstack compress b(2)
	*/
						
	eststo mod1: 	reg hincome abstract-manual `taskmeans' [aw=weight]
					
					
	eststo mod2: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.onet_abstract	///
					c.routine#c.onet_routine 	///	
					c.manual#c.onet_manual  	[aw=weight]
					
					
	eststo mod3: 	reg hincome abstract-manual `taskmeans' ///
					male nativesp jobtrain private [aw=weight]
					
					
	eststo mod4: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.onet_abstract		///
					c.routine#c.onet_routine 		///	
					c.manual#c.onet_manual  		///				
					male nativesp jobtrain private ///
					[aw=weight]
					
	eststo mod5: 	reg hincome abstract-manual `taskmeans' ///
					male nativesp `otherc' [aw=weight]					
					
	
	eststo mod6: 	reg hincome abstract-manual `taskmeans' ///
					c.abstract#c.onet_abstract		///
					c.routine#c.onet_routine 		///	
					c.manual#c.onet_manual  		///				
					male `otherc'[aw=weight]		
										

	
	
	esttab  	mod1  ///
				using $project/table/table6.csv , ///
	b(%12.2f)	p(%12.2f) replace /* title (`title') */  label ar2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress		
	
	/* Principal Component Analysis 
	
	pca a1 a2 a3 a4 a5
	predict pca1, score
	
	pca r1 r2 r3 r4 r5
	predict pcr1, score
	
	pca m1 m2
	predict pcm1, score
	
	drop abstract routine manual
	
	ren pca1 abstract
	ren pcr1 routine
	ren pcm1 manual
	
	*/
	
	
	gen b_abstract =.
	gen b_routine =.
	gen b_manual =.
	gen b_cons = .
	
	
	local occ2_1 11 12 13 14 21 22 23 24 25 26 31 32 33 34 35 
	local occ2_2 `occ2_1' 41 42 43 51 52 53 54 61 71 72 73 74 75 81 82 83 91 92 93 96
 	
	foreach i in `occ2_2' {
	
		reg hincome abstract routine manual [aw=occweight] if occ2 == `i'	
		replace b_abstract = _b[abstract] 	if occ2 == `i'
		replace b_routine = _b[routine] 	if occ2 == `i'
		replace b_manual = _b[manual] 		if occ2 == `i'
		replace b_cons = _b[_cons] 			if occ2 == `i'
	
	}	
	
	estimates clear
	
	eststo mod1: reg b_manual b_abstract 			[aw=occweight]
					 
	eststo mod2: reg b_abstract b_routine 			[aw=occweight]
					 
	eststo mod3: reg b_routine b_manual 			[aw=occweight]
					 
	eststo mod4: reg b_cons b_abstract 				[aw=occweight]
				
	eststo mod5: reg b_cons b_routine 				[aw=occweight]
					
	eststo mod6: reg b_cons b_manual 				[aw=occweight]
	
	
	
	esttab  	mod1 mod2 mod3 mod4 mod5 mod6 ///
				using $project/table/table5_kobayashi.csv , ///
	b(%12.2f)	p(%12.2f) replace /* title (`title') */  label ar2 ///
				/*star(* .10 ** .05 *** .01)*/  varwidth(15)  compress				
	
