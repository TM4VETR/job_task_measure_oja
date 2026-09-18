* -----------------------------------------------------------
* Prepare data for table 2
* -----------------------------------------------------------
clear all
* 1. postfiles to store results in
tempname memhold
tempfile results

* We create a place to store the 8 Col.s of data for each version
postfile `memhold' str2 version n_start n_step1 n_final pct_sample n_isco n_pairs n_distinct_vo avg_vo using "`results'", replace

* 2. Loop through data set versions
forval i = 1/4 {
    
    * Load data
    use "data/round`i'", clear
    
    * Set 0 to missing
    quietly: mvdecode Task_cat, mv(0)
    
    * Generate ISCO major groups (needed for Col. 6)
    quietly iscogen isco_mjr = major(isco_4)

    * Col. 2: Sample size (job ads) before dropping anything
    quietly distinct stea_id
    local n_start = r(ndistinct)
    
    * Col. 3: restriction to "only has_jd / extraction from jd (R4)"
    quietly keep if job_has_jd == "has_jd"
    
    
			quietly distinct stea_id
			local n_step1 = r(ndistinct)
		
	* R4 only: restrict to zone to drop duplicates in full-text
		if `i' == 4 {
			quietly drop if zone == 1 
		}

			
    * Col. 4: drop missings
    quietly keep if Task_cat != .
    
		quietly distinct stea_id
		local n_final = r(ndistinct)
    
    * Col. 5: % of whole sample (Col. 4 / Col. 3)
    local pct_sample = `n_final' / `n_step1'
    
    * Col. 6: "Distinct occupations"
    quietly distinct isco_4
    local n_isco = r(ndistinct)
    
    * Col. 7: Verb object combinations (total)
    quietly egen pair_tag = tag(pair_id)
    quietly count if pair_tag == 1
    local n_pairs = r(N)
    
    * Col. 8: Distinct VO's
    quietly egen vo_tag = tag(verb object)
    quietly count if vo_tag == 1
    local n_distinct_vo = r(N)
    
    * Col. 9: Avg. VO's per job ad (Col. 7 / Col. 4)
    local avg_vo = `n_pairs' / `n_final'
    
    * Display progress
    di "Version `i' Complete. Step 1: `n_step1' -> Final: `n_final'"
    
    * Save row to results file
    post `memhold' ("V`i'") (`n_start') (`n_step1') (`n_final') (`pct_sample') (`n_isco') (`n_pairs') (`n_distinct_vo') (`avg_vo')
}

	* Close postfile
	postclose `memhold'

* 3. Export table 2 to word
use "`results'", clear

	* Format
	format n_* %9.0fc        
	format pct_sample %9.3f
	format avg_vo %9.3f

putdocx clear
putdocx begin

* add title
putdocx paragraph, style(Heading1)
putdocx text ("Table 2")

* create table
putdocx table tbl1 = data(version n_start n_step1 n_final pct_sample n_isco n_pairs n_distinct_vo avg_vo), varnames

* name headers 
putdocx table tbl1(1,1) = ("")
putdocx table tbl1(1,2) = ("Before dropping anything")
putdocx table tbl1(1,3) = ("Only has_jd")
putdocx table tbl1(1,4) = ("No missing VO's")
putdocx table tbl1(1,5) = ("% of whole sample (row 2)")
putdocx table tbl1(1,6) = ("Distinct occupations (N=310)")
putdocx table tbl1(1,7) = ("Verb object combinations")
putdocx table tbl1(1,8) = ("Distinct VO")
putdocx table tbl1(1,9) = ("Avg. VO per job ad")

	* Save and export
	putdocx save "tables/Schulz_table_2.docx", replace