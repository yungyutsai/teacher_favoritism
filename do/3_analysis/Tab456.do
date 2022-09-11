clear
set more off

forv i = 4(1)6{ //Table
	*** Main Estimates
	use "$wdata/Main_Estimations_All.dta", clear
		
	keep if exhibition == "Tab`i'"
	
	gen panel = .
	replace panel = 1 if outcome == "bct"
	replace panel = 2 if outcome == "bct_ch"
	replace panel = 3 if outcome == "bct_ma"
	replace panel = 4 if outcome == "bct_sc"
	drop if panel == .
	
	replace column = subinstr(column,"c","",.)
	destring column, replace
	replace column = column + 3 if method == "lo"
	keep column panel parm estimate
	reshape wide est, i(panel parm) j(col)
	order panel parm
	
	save "$wdata/coef.dta", replace
	
	*** Bootestrap Estimates
	use "$wdata/Bootstrap_Estimations_All", clear
	
	keep if exhibition == "Tab`i'"
	
	gen panel = .
	replace panel = 1 if outcome == "bct"
	replace panel = 2 if outcome == "bct_ch"
	replace panel = 3 if outcome == "bct_ma"
	replace panel = 4 if outcome == "bct_sc"
	drop if panel == .
	
	replace column = subinstr(column,"c","",.)
	destring column, replace
	replace column = column + 3 if method == "lo"
	keep column panel parm estimate
	
	collapse (sd)est, by(column panel parm)
	
	reshape wide est, i(panel parm) j(col)
	order panel parm
	
	save "$wdata/se.dta", replace
	
	*** Make Table
	use "$wdata/coef.dta"
	ap using "$wdata/se.dta", gen(row)

	** create additional rows for p-value
	expand 2, gen(p)
	forv j = 1(1)6{
		replace estimate`j' = . if p == 1
	}
	replace row = 2 if p == 1
	duplicates drop
	drop p
	
	replace parm = "0.favoritism" if parm == "favoritism" //Just for sorting
	sort panel parm row

	** calculate p-value and adjust format
	forv j = 1(1)6{
		replace estimate`j' = ttail(10000,abs(estimate`j'[_n-2]/estimate`j'[_n-1])) if row == 2
		tostring estimate`j', format(%4.3f) replace force
		replace estimate`j' = "(" + estimate`j' +")" if row == 1
		replace estimate`j' = "[" + estimate`j' +"]" if row == 2
	}
	
	** create additional rows for panel titles
	loc N = _N + 4
	set obs `N'
	
	replace parm = "0" if row == .
	replace panel = mod(_n,4) + 1 if row == .
	sort panel parm row
	
	replace parm = "Panel A: Total Score" if panel == 1 & row == .
	replace parm = "Panel B: Reading Score" if panel == 2 & row == .
	replace parm = "Panel C: Math Score" if panel == 3 & row == .
	replace parm = "Panel D: Science Score" if panel == 4 & row == .
	
	replace parm = "" if row ~= 0 & row ~= .
	drop panel row

	** change name of parm
	replace parm = "Favoritism" if parm == "0.favoritism"
	replace parm = "Favoritism # Female" if parm == "1.newgroup#c.favoritism" & `i' == 4
	replace parm = "Favoritism # Mainlander" if parm == "1.newgroup#c.favoritism" & `i' == 5
	replace parm = "Favoritism # MiddleAchiever" if parm == "1.newgroup#c.favoritism" & `i' == 6
	replace parm = "Favoritism # HighAchiever" if parm == "2.newgroup#c.favoritism" & `i' == 6

	** export table
	export excel "$tables/Tab`i'.xlsx", replace
}
