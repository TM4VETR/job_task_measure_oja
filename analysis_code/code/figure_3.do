* -----------------------------------------------------------
* Prepare data for figure 3
* -----------------------------------------------------------
* Load data set for version i, generate round indicator, and destring stea_id
forval i = 1/4  {
use "data/round`i'", clear
capture gen round = `i'
destring stea_id, replace
save "data/round`i'", replace
}

	* V7 is loaded, append the rest
	forval i = 1/4  {
	* Load data set for version i
	append using "data/round`i'"
	}

* define round label for plotting
lab def round 1 "Round 1" 2 "Round 2" 3 "Round 3" 4 "Round 4"
lab val round round

* Keep all valid VO's (only VO's from jd in V7 to drop duplicates)
drop if Task_cat == 0
keep if  round < 4 & job_has_jd == "has_jd" | round == 4 & zone == 2
egen stea_round_tag = tag(stea_id round)
tab stea_round_tag round

* Fix task categories for R1
recode Task_cat (4=5) (5=4) if round == 1 

* Create dummies to plot distribution of isco major groups across rounds
iscogen isco_mjr = major(isco_4)
tab isco_mjr, gen(isco_mjr_)
* Create dummies to plot distribution of tasks across rounds
capture tab Task_cat, gen(Task_cat_)

* -----------------------------------------------------------
* Generate graphs for figure 3 in the manuscript
* -----------------------------------------------------------

* Distribution of major groups as a percentage of job ads
graph bar isco_mjr_* if stea_round_tag ///
    ,  stack over(round) scheme(cleanplots) bar(1,lwidth(*.25)) bar(2,lwidth(*.25))  bar(3,lwidth(*.25))  bar(4,lwidth(*.25))   bar(5,lwidth(*.25)) bar(6,lwidth(*.25)) bar(7,lwidth(*.25))  bar(8,lwidth(*.25)) ///
    title("{bf:Share of job advertisements belonging to each ISCO major group}", size(*.75)) legend(pos(6) rows(2) order(1 "Managers" ///
                 2 "Professionals" ///
                 3 "Technicians and ass. professionals" ///
                 4 "Clerical support workers" ///
                 5 "Services and sales workers" ///
                 6 "Craft and related trades workers" ///
                 7 "Plant and machine operators" ///
                 8 "Elementary occupations")) name(isco_dist_stea, replace) nodraw	
				
				 

		 
* Distribution of task categories as a percentage of VO's	 
graph bar Task_cat_1 Task_cat_2 Task_cat_3 Task_cat_4 Task_cat_5 ///
    , stack over(round) scheme(cleanplots) bar(1,lwidth(*.25)) bar(2,lwidth(*.25))  bar(3,lwidth(*.25))  bar(4,lwidth(*.25))   bar(5,lwidth(*.25)) ///
    title("{bf:Share of verb-object pairs belonging to each task category}", size(*.75)) legend(pos(6) rows(1) order(1 "Analytical" ///
                 2 "Management" ///
                 3 "Interactive" ///
                 4 "Cognitive" ///
                 5 "Manual")) name(task_dist_vo, replace) nodraw
				 

* Combine and export graph as .png
graph combine task_dist_vo isco_dist_stea, rows(2) imargin(0 0 1 0) iscale(*.95)
	graph export "figures/figure_3.png", width(5500) height(3500) replace
	graph close


	
* -----------------------------------------------------------
* Alternative grayscale version
* -----------------------------------------------------------

* Distribution of major groups as a percentage of job ads
graph bar isco_mjr_* if stea_round_tag ///
    ,  stack over(round) scheme(cleanplots) bar(1, fcolor(gs1)  lcolor(black) lwidth(*.25)) ///   // very dark
			bar(2, fcolor(gs3)  lcolor(black) lwidth(*.25)) ///
			bar(3, fcolor(gs6)  lcolor(black) lwidth(*.25)) ///
			bar(4, fcolor(gs8) lcolor(black) lwidth(*.25)) ///
			bar(5, fcolor(gs10) lcolor(black) lwidth(*.25)) ///  
			bar(6, fcolor(gs12) lcolor(black) lwidth(*.25)) ///   // very light with thick border
			bar(7, fcolor(gs14) lcolor(black) lwidth(*.25)) ///   // very light with thick border
			bar(8, fcolor(gs16) lcolor(black) lwidth(*.25)) ///   // very light with thick border
				title("{bf:Share of job advertisements belonging to each ISCO major group}", size(*.75)) legend(pos(6) rows(2) order(1 "Managers" ///
                 2 "Professionals" ///
                 3 "Technicians and ass. professionals" ///
                 4 "Clerical support workers" ///
                 5 "Services and sales workers" ///
                 6 "Craft and related trades workers" ///
                 7 "Plant and machine operators" ///
                 8 "Elementary occupations")) name(isco_dist_stea, replace) 	
				
				 

		 
* Distribution of task categories as a percentage of VO's	 
graph bar Task_cat_1 Task_cat_2 Task_cat_3 Task_cat_4 Task_cat_5 ///
    , stack over(round) scheme(cleanplots) bar(1, fcolor(gs1)  lcolor(black) lwidth(*.25)) ///   // very dark
						bar(2, fcolor(gs3)  lcolor(black) lwidth(*.25)) ///
						bar(3, fcolor(gs6)  lcolor(black) lwidth(*.25)) ///
						bar(4, fcolor(gs8) lcolor(black) lwidth(*.25)) ///
						bar(5, fcolor(gs11) lcolor(black) lwidth(*.25)) ///   // very light with thick border
			title("{bf:Share of verb-object pairs belonging to each task category}", size(*.75)) legend(pos(6) rows(1) order(1 "Analytical" ///
                 2 "Management" ///
                 3 "Interactive" ///
                 4 "Cognitive" ///
                 5 "Manual")) name(task_dist_vo, replace) 
				 

* Combine and export graph as .tif 
graph combine task_dist_vo isco_dist_stea, rows(2) imargin(0 0 1 0) iscale(*.95)
	graph export "figures/figure_3_graysc.png", width(5500) height(3500) replace
	graph close
	
	
* -----------------------------------------------------------
* Create and export table containing data used for the graphs
* -----------------------------------------------------------

* create isco table (data for graph "isco_dist_stea")
tempname mem_isco
tempfile res_isco

* Postfile 
postfile `mem_isco' str15 round_lab n_ads pct_mgr pct_prof pct_tech pct_cler pct_serv pct_craf pct_mach pct_elem pct_sum using "`res_isco'", replace

* Get levels of rounds + add a "totat" indicator to double check
levelsof round, local(r_levels)
local r_levels "`r_levels' 99" // 99 will represent "total if all rounds"

foreach r of local r_levels {
    
    * Define condition round or total (99)
    if `r' == 99 {
        local cond "stea_round_tag == 1" 
        local lab "Total"
    }
    else {
        local cond "round == `r' & stea_round_tag == 1"
        local lab "Round `r'"
    }

    * Denominator: Total Ads
    quietly count if `cond'
    local n_total = r(N)
    
    * Numerators: Specific ISCO Codes
    
    * 1. Managers
    quietly count if `cond' & isco_mjr == 1
    local p1 = r(N) / `n_total'
    
    * 2. Professionals
    quietly count if `cond' & isco_mjr == 2
    local p2 = r(N) / `n_total'
    
    * 3. Technicians
    quietly count if `cond' & isco_mjr == 3
    local p3 = r(N) / `n_total'
    
    * 4. Clerical
    quietly count if `cond' & isco_mjr == 4
    local p4 = r(N) / `n_total'
    
    * 5. Services
    quietly count if `cond' & isco_mjr == 5
    local p5 = r(N) / `n_total'
    
    * 7. Craft 
    quietly count if `cond' & isco_mjr == 7
    local p7 = r(N) / `n_total'
    
    * 8. Plant/Machine
    quietly count if `cond' & isco_mjr == 8
    local p8 = r(N) / `n_total'
    
    * 9. Elementary
    quietly count if `cond' & isco_mjr == 9
    local p9 = r(N) / `n_total'
    
    * Column Total (Check sum)
    local p_sum = `p1' + `p2' + `p3' + `p4' + `p5' + `p7' + `p8' + `p9'

    * Post row
    post `mem_isco' ("`lab'") (`n_total') (`p1') (`p2') (`p3') (`p4') (`p5') (`p7') (`p8') (`p9') (`p_sum')
}
postclose `mem_isco'


* Prepare task table (data for graph "task_dist_vo") 
tempname mem_task
tempfile res_task

postfile `mem_task' str15 round_lab n_vos pct_ana pct_man pct_int pct_cog pct_hnd pct_sum using "`res_task'", replace

foreach r of local r_levels {
    
    if `r' == 99 {
        local cond "Task_cat != ." // All valid rows
        local lab "Total"
    }
    else {
        local cond "round == `r'"
        local lab "Round `r'"
    }
    
    * Denominator
    quietly count if `cond'
    local n_total = r(N)
    
    * Numerators: Task Cats 1-5
    local row_sum = 0
    forval k = 1/5 {
        quietly count if `cond' & Task_cat == `k'
        local p_t`k' = r(N) / `n_total'
        local row_sum = `row_sum' + `p_t`k''
    }
    
    post `mem_task' ("`lab'") (`n_total') (`p_t1') (`p_t2') (`p_t3') (`p_t4') (`p_t5') (`row_sum')
}
postclose `mem_task'

* Export to word file
putdocx clear
putdocx begin

* create table 1: ISCO distribution
use "`res_isco'", clear

* Convert to percentages
foreach v of varlist pct_* {
    replace `v' = `v' * 100
}

* Format
format pct_* %9.1f
format n_ads %9.0fc
format pct_sum %9.0f // no decimals for total

putdocx paragraph, style(Heading1)
putdocx text ("ISCO Composition (% of Ads)")

putdocx table tbl_isco = data(round_lab n_ads pct_mgr pct_prof pct_tech pct_cler pct_serv pct_craf pct_mach pct_elem pct_sum), varnames 

* Bold total row (last row)
local last = _N + 1
putdocx table tbl_isco(`last',.), bold

* Headers
putdocx table tbl_isco(1,1) = ("Round")
putdocx table tbl_isco(1,2) = ("N (Ads)")
putdocx table tbl_isco(1,3) = ("Managers")
putdocx table tbl_isco(1,4) = ("Professionals")
putdocx table tbl_isco(1,5) = ("Technicians")
putdocx table tbl_isco(1,6) = ("Clerical")
putdocx table tbl_isco(1,7) = ("Services")
putdocx table tbl_isco(1,8) = ("Craft")
putdocx table tbl_isco(1,9) = ("Plant/Mach")
putdocx table tbl_isco(1,10) = ("Elementary")
putdocx table tbl_isco(1,11) = ("Total %")


* create table 2: task distribution
use "`res_task'", clear
* Convert Shares to percentages 
foreach v of varlist pct_* {
    replace `v' = `v' * 100
}

* Format
format pct_* %9.1f 
format n_vos %9.0fc
format pct_sum %9.0f // no decimals for total

putdocx paragraph, style(Heading1)
putdocx text ("Task Composition (% of VOs)")

putdocx table tbl_task = data(round_lab n_vos pct_ana pct_man pct_int pct_cog pct_hnd pct_sum), varnames 

* Bold the Total Row
local last = _N + 1
putdocx table tbl_task(`last',.), bold

* Headers
putdocx table tbl_task(1,1) = ("Round")
putdocx table tbl_task(1,2) = ("N (VOs)")
putdocx table tbl_task(1,3) = ("Analytical")
putdocx table tbl_task(1,4) = ("Management")
putdocx table tbl_task(1,5) = ("Interactive")
putdocx table tbl_task(1,6) = ("Cognitive")
putdocx table tbl_task(1,7) = ("Manual")
putdocx table tbl_task(1,8) = ("Total %")

* Save output
putdocx save "tables/figure_3_data.docx", replace


