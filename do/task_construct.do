	
	foreach task of varlist t_* {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
	}
	
qui {	
	
		/* Non-routine cognitive: Analytical */
	/* 
	
	4.A.2.a.4 Analyzing data/information
	4.A.2.b.2 Thinking creatively
	4.A.4.a.1 Interpreting information for others 
	
	*/

	#delimit;
	egen nr_cog_anal=rowtotal(t_4A2a4 t_4A2b2 t_4A4a1); 
	
	/* Non-routine cognitive: Interpersonal */
	/*
	
	4.A.4.a.4 Establishing and maintaining personal relationships
	4.A.4.b.4 Guiding, directing and motivating subordinates 
	4.A.4.b.5 Coaching/developing others
	
	*/
	
	egen nr_cog_pers=rowtotal(t_4A4a4 t_4A4b4 t_4A4b5);
	
	/* Routine cognitive */
	/*
	
	4.C.3.b.7 Importance of repeating the same tasks
	4.C.3.b.4 Importance of being exact or accurate
	4.C.3.b.8 Structured v. Unstructured work (reverse)
	
	*/
	
	egen r_cog=rowtotal(t_4C3b7 t_4C3b4 t_4C3b8_rev);
	
	/* Routine manual */
	/*
	
	4.C.3.d.3 Pace determined by speed of equipment
	4.A.3.a.3 Controlling machines and processes 
	4.C.2.d.1.i Spend time making repetitive motions 
	
	*/
	
	
	egen r_man=rowtotal(t_4C3d3 t_4A3a3 t_4C2d1i);
	
	/* Non-routine manual: phys. adaptability */
	/*
	
	4.A.3.a.4 Operating vehicles, mechanized devices, or equipment
	4.C.2.d.1.g Spend time using hands to handle, control or feel objects, tools or controls
	1.A.2.a.2 Manual dexterity
	1.A.1.f.1 Spatial orientation
	
	*/
	
	egen nr_man_phys=rowtotal(t_4A3a4 t_4C2d1g t_1A2a2 t_1A1f1);
	
	/* Non-routine manual: interpersonal adaptability */
	/* 
	2.B.1.a Social Perceptiveness*/
	

	egen nr_man_pers=rowtotal(t_2B1a); 
	replace nr_man_pers=. if t_2B1a==.;
	
	#delimit cr
		
	drop t_*
}

		foreach task of varlist nr_cog_anal-nr_man_pers {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
		summ `task' 
	}
		



/*

gen year = 2012
gen int isco08_v2 = isco08/100

collapse (mean) nr_cog_anal-nr_man_pers , by(isco08_v2)

ren isco08_v2 isco08

saveold onet2012, replace

	
		foreach task of varlist nr_cog_anal-nr_man_pers {
		summ `task' [aw=lswt]
		replace `task'=[`task'-r(mean)]/r(sd)
		summ `task' 
	}
		
