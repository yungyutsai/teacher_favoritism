use "$tables/temp/FigureB2b_Random_Assign_Teacher.dta", clear

gen greater = .
gen smaller = .

keep if (parm == "1.newgroup#c.favoritism" & strpos(idstr,"achieve") == 0) |  parm == "2.newgroup#c.favoritism"

replace parm = "b"

foreach b in b{
	foreach x in female mainlander achieve{
		foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so {
			sum est if parm == "`b'" & idstr == "`x',`y'" & idnum == 0
			local main = r(mean)
			replace greater = est > `main' if parm == "`b'" & idstr == "`x',`y'" & idnum ~= 0
			replace smaller = est < `main' if parm == "`b'" & idstr == "`x',`y'" & idnum ~= 0
		}
	}
}

tab idstr parm, sum(smaller) nost nof
tab idstr parm, sum(greater) nost nof

** Achievement
sum est if parm == "b" & idstr == "achieve,bct" & idnum == 0
local main = r(mean)
local mainmainest : display %4.3f r(mean)
local location = `main' - 0.01
sum greater if parm == "b" & idstr == "achieve,bct" & idnum ~= 0
local p : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "achieve,bct" & idnum ~= 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main' 0 `main', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(7.5 `location' "Main Estimate: `mainmainest'" "p-value: `p'", place(w) color(black) just(left))
graph export "$figures/FigureB2d.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2d.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2d.png", as(png) replace

** Female - Science
sum est if parm == "b" & idstr == "female,bct_sc" & idnum == 0
local main = r(mean)
local mainmainest : display %4.3f r(mean)
local location = `main' + 0.01
sum greater if parm == "b" & idstr == "female,bct_sc" & idnum ~= 0
local p : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,bct_sc" & idnum ~= 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 15 `main' 0 `main', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(3)15, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(8 `location' "Main Estimate: `mainmainest'" "p-value: `p'", place(e) color(black) just(left))
graph export "$figures/FigureB2b.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2b.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2b.png", as(png) replace

** Female
sum est if parm == "b" & idstr == "female,bct" & idnum == 0
local main = r(mean)
local mainmainest : display %4.3f r(mean)
local location = `main' + 0.01
sum greater if parm == "b" & idstr == "female,bct" & idnum ~= 0
local p : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,bct" & idnum ~= 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 15 `main' 0 `main', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(3)15, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(8 `location' "Main Estimate: `mainmainest'" "p-value: `p'", place(e) color(black) just(left))
graph export "$figures/FigureB2a.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2a.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2a.png", as(png) replace

** Mainlander
sum est if parm == "b" & idstr == "mainlander,bct" & idnum == 0
local main = r(mean)
local mainmainest : display %4.3f r(mean)
local location = `main' + 0.01
sum greater if parm == "b" & idstr == "mainlander,bct" & idnum ~= 0
local p : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "mainlander,bct" & idnum ~= 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main' 0 `main', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(5 `location' "Main Estimate: `mainmainest'" "p-value: `p'", place(e) color(black) just(left))
graph export "$figures/FigureB2c.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2c.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2c.png", as(png) replace
