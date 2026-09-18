* -----------------------------------------------------------
* Prepare data for figure 5
* -----------------------------------------------------------
clear all
use "data/round4", clear
keep if zone == 2
bys stea_id: gen freq = _N
iscogen siops = siops(isco_4)
gen siops_r = round(siops, 1.0) 
egen stea_tag = tag(stea_id)

* -----------------------------------------------------------
* Generate graphs for figure 3 in the manuscript
* -----------------------------------------------------------

* Plot number of VO's across binned occupational status
scatterfit freq siops_r if stea_tag, ci binned mweighted binvar(siops_r) fitmodel(poisson) ///
				opts(ytitle(Number of tasks per job ad) xtitle(SIOPS) ylab(1(1)5) xlab(10(10)80) aspectratio(0.8) legend(off))
	graph export "figures/figure_5.png", width(4500) height(3000) replace
		graph close
	

	
	
	

