* -----------------------------------------------------------
* Prepare data for table 3
* -----------------------------------------------------------
clear all
use "data/round4", clear

* Drop duplicates in full-text 
drop if job_has_jd != "has_jd"

* Identify valid tasks (zone 2 & no missings)
gen valid_task = (zone == 2 & Task_cat != 0)

* Total Frequency per Job Ad (Full Sample)
bysort stea_id: egen freq_all = total(valid_task)

* Frequency in clean sample 
gen freq_clean = freq_all
replace freq_clean = . if freq_all == 0

* Generate indicator for ads without any VO's
gen no_pair = (freq_all == 0)

* Keep job ads as unit
egen stea_tag = tag(stea_id)
keep if stea_tag == 1

* Generate isco major groups
iscogen isco_mjr = major(isco_4)

* Calculate totals
preserve
    collapse (mean) avg_all=freq_all (mean) avg_clean=freq_clean ///
             (mean) share_zero=no_pair (count) N_all=freq_all ///
             (count) N_clean=freq_clean
    
    * Generate a label for this row
    gen isco_label = "Total"
    
    * Save this single row to a tempfile
    tempfile total_stats
    save "`total_stats'"
restore

* Calculate stats by isco major group
collapse (mean) avg_all=freq_all (mean) avg_clean=freq_clean ///
         (mean) share_zero=no_pair (count) N_all=freq_all ///
         (count) N_clean=freq_clean, by(isco_mjr)

* Convert the numeric ISCO variable to a string label so we can append "Total"
decode isco_mjr, gen(isco_label)
drop isco_mjr

* Append total the rest
append using "`total_stats'"

	* Format the numbers
	format avg_all %9.2f       
	format avg_clean %9.2f
	format share_zero %9.2f    
	format N_all %9.0fc         
	format N_clean %9.0fc

* -----------------------------------------------------------
* Create and export table 3
* -----------------------------------------------------------
* Header
putdocx clear
putdocx begin

putdocx paragraph, style(Heading1)
putdocx text ("Descriptive Statistics of Task Expressions in Job Postings by ISCO Major Group")

* Create table from the combined data
putdocx table tbl1 = data(isco_label avg_all avg_clean share_zero N_all N_clean), varnames

* Rename Headers
putdocx table tbl1(1,1) = ("ISCO Major Group")
putdocx table tbl1(1,2) = ("Avg. VOs (All Ads)")
putdocx table tbl1(1,3) = ("Avg. VOs (Ads > 0)")
putdocx table tbl1(1,4) = ("Share w/o Pairs")
putdocx table tbl1(1,5) = ("N (All Ads)")
putdocx table tbl1(1,6) = ("N (Ads > 0)")

* Formatting: Center align data columns
putdocx table tbl1(., 2), halign(center)
putdocx table tbl1(., 3), halign(center)
putdocx table tbl1(., 4), halign(center)
putdocx table tbl1(., 5), halign(center)
putdocx table tbl1(., 6), halign(center)


	* Save and export
	putdocx save "tables/Schulz_table_3", replace
