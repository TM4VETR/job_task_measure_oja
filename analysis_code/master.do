******************************************************************************************************************************************
* Masterfile for:																						    							 *
* A method of qualitative inquiry in Natural Language Processing-extraction: An analysis of job tasks based on job advertisements		 *
* Authors: Timo Wiesner, Wiebke Schulz																									 *
******************************************************************************************************************************************

* Set filepath to the folder containing this file 
global MyProject " "
cd "$MyProject"
local ProjectDir "$MyProject"

* Confirm that the project directory has been defined
cap assert !mi("`ProjectDir'")
if _rc {
	noi di as error "Error: need to define the global"
}


* install ados if needed
foreach pkg in estout grc1leg2 iscogen scatterfit putdocx distinct cleanplots {
    local check_cmd "`pkg'"
					if "`pkg'" == "egenmore" {
						local check_cmd "_gsemean" 
					}
			capture which `check_cmd'
			if _rc != 0 {
				display as text "Installing `pkg'..."
				ssc install `pkg', replace
			}
				else {
					display as text "`pkg' already installed."
				}
}


* Initialize log
clear
set more off
capture mkdir "$MyProject\code"
capture mkdir "$MyProject\code\logs"
capture mkdir "$MyProject\tables"
capture mkdir "$MyProject\figures"
capture mkdir "$MyProject\data"

* Close any open logs
capture log close

* Generate timestamp for the log filename
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$MyProject\code\logs\\`datetime'.txt"

* Start logging
log using "`logfile'", text name(OUP_chapter_replication_material)
* Stata version control
version 17

* Create figures and tables
quietly do "`ProjectDir'\code\figure_3.do"
quietly do "`ProjectDir'\code\figure_5.do"
quietly do "`ProjectDir'\code\table_2.do"
quietly do "`ProjectDir'\code\table_3.do"

* End log
di "End date and time: $S_DATE $S_TIME"
log close OUP_chapter_replication_material
exit

