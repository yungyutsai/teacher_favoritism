use "$tables/temp/FigureB1.dta", clear

gen greater_bl = .
gen smaller_bl = .
gen greater_lo = .
gen smaller_lo = .

keep if (parm == "1.newgroup#c.favoritism" & strpos(idstr,"achieve") == 0) |  parm == "2.newgroup#c.favoritism"

replace parm = "b"

foreach b in b{
	foreach x in female mainlander achieve{
		foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
			sum est if parm == "`b'" & idstr == "`x',`y'" & idnum == 0
			local main = r(mean)
			replace greater_bl = est > `main' if parm == "`b'" & idstr == "`x',`y'" & idnum > 0
			replace smaller_bl = est < `main' if parm == "`b'" & idstr == "`x',`y'" & idnum > 0
			sum est if parm == "`b'" & idstr == "`x',`y'" & idnum == -1
			local main = r(mean)
			replace greater_lo = est > `main' if parm == "`b'" & idstr == "`x',`y'" & idnum > 0
			replace smaller_lo = est < `main' if parm == "`b'" & idstr == "`x',`y'" & idnum > 0
		}
	}
}


** Female - Academic
sum est if parm == "b" & idstr == "female,teacherconsultacademic" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "female,teacherconsultacademic" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "female,teacherconsultacademic" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "female,teacherconsultacademic" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,teacherconsultacademic" & idnum > 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 8 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.05)0.2, format(%4.2f)) xscale(ra(-0.2 0.2)) ///
		legend(off) ///
		text(7 `location_bl' "Baseline Estimate:" "`mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(7.5 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB1a.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1a.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1a.png", as(png) replace

** Mainlander - Academic
sum est if parm == "b" & idstr == "mainlander,teacherconsultacademic" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "mainlander,teacherconsultacademic" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "mainlander,teacherconsultacademic" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "mainlander,teacherconsultacademic" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "mainlander,teacherconsultacademic" & idnum > 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 8 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.05)0.2, format(%4.2f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(7 `location_bl' "Baseline Estimate: `mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(7.5 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB1c.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1c.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1c.png", as(png) replace

** Achievement - Academic
sum est if parm == "b" & idstr == "achieve,teacherconsultacademic" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "achieve,teacherconsultacademic" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.01
local location_lo = `mainest_lo' - 0.01

sum greater_bl if parm == "b" & idstr == "achieve,teacherconsultacademic" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "achieve,teacherconsultacademic" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "achieve,teacherconsultacademic" & idnum > 0, ///
		width(0.02) start(-0.4) fc(gs12) lc(gs10)) ///
		(scatteri 4 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 4 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(1)4, angle(0)) ///
		xtitle("Estimate") xlabel(-0.4(0.1)0.4, format(%4.1f)) xscale(ra(-0.4 0.4)) ///
		legend(off) ///
		text(3 `location_bl' "Baseline" "Estimate:" "`mainest_bl'" "p-value:" "`p_bl'", place(e) color(black) just(left) size(small)) ///
		text(3.8 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB1e.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1e.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1e.png", as(png) replace


** Female - Emotional
sum est if parm == "b" & idstr == "female,teacherconsultemotion" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "female,teacherconsultemotion" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "female,teacherconsultemotion" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "female,teacherconsultemotion" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,teacherconsultemotion" & idnum > 0, ///
		width(0.01) start(-0.205) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 8 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.05)0.2, format(%4.2f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(7 `location_bl' "Baseline" "Estimate:" "`mainest_bl'" "p-value:" "`p_bl'", place(e) color(black) just(left) size(small)) ///
		text(7.75 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB1b.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1b.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1b.png", as(png) replace

** Mainlander - Emotional
sum est if parm == "b" & idstr == "mainlander,teacherconsultemotion" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "mainlander,teacherconsultemotion" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' + 0.005

sum greater_bl if parm == "b" & idstr == "mainlander,teacherconsultemotion" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "mainlander,teacherconsultemotion" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "mainlander,teacherconsultemotion" & idnum > 0, ///
		width(0.0075) start(-0.165) fc(gs12) lc(gs10)) ///
		(scatteri 10.25 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 10.25 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)10, angle(0)) ///
		xtitle("Estimate") xlabel(-0.15(0.05)0.15, format(%4.2f)) xscale(ra(-0.165 0.165)) ///
		legend(off) ///
		text(9.5 `location_bl' "Baseline Estimate: `mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(8 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(e) color(black) just(left) size(small))
graph export "$figures/FigureB1d.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1d.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1d.png", as(png) replace

** Achievement - Emotional
sum est if parm == "b" & idstr == "achieve,teacherconsultemotion" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "achieve,teacherconsultemotion" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.01
local location_lo = `mainest_lo' - 0.01

sum greater_bl if parm == "b" & idstr == "achieve,teacherconsultemotion" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "achieve,teacherconsultemotion" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "achieve,teacherconsultemotion" & idnum > 0, ///
		width(0.015) start(-0.31) fc(gs12) lc(gs10)) ///
		(scatteri 5 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 5 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(1)5, angle(0)) ///
		xtitle("Estimate") xlabel(-0.4(0.1)0.4, format(%4.1f)) xscale(ra(-0.31 0.31)) ///
		legend(off) ///
		text(4 `location_bl' "Baseline Estimate:" "`mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(4.75 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB1f.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB1f.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB1f.png", as(png) replace

** Achievement - BCT
sum est if parm == "b" & idstr == "achieve,bct" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "achieve,bct" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "achieve,bct" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "achieve,bct" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "achieve,bct" & idnum > 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 9 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 9 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(3)9, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.21 0.21)) ///
		legend(off) ///
		text(6 `location_bl' "Baseline Estimate:" "`mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(8.5 `location_lo' "Leave-one-out" "Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB2d.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2d.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2d.png", as(png) replace

** Female - Science
sum est if parm == "b" & idstr == "female,bct_sc" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "female,bct_sc" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "female,bct_sc" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "female,bct_sc" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,bct_sc" & idnum > 0, ///
		width(0.0075) start(-0.15) fc(gs12) lc(gs10)) ///
		(scatteri 10 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 10 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)10, angle(0)) ///
		xtitle("Estimate") xlabel(-0.15(0.05)0.15, format(%4.2f)) xscale(ra(-0.15 0.15)) ///
		legend(off) ///
		text(8.5 `location_bl' "Baseline Estimate: `mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(9 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB2b.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2b.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2b.png", as(png) replace

** Female - BCT
sum est if parm == "b" & idstr == "female,bct" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "female,bct" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "female,bct" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "female,bct" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "female,bct" & idnum > 0, ///
		width(0.0075) start(-0.15) fc(gs12) lc(gs10)) ///
		(scatteri 12 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 12 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(3)12, angle(0)) ///
		xtitle("Estimate") xlabel(-0.15(0.05)0.15, format(%4.2f)) xscale(ra(-0.15 0.15)) ///
		legend(off) ///
		text(9.5 `location_bl' "Baseline Estimate: `mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(11.25 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB2a.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2a.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2a.png", as(png) replace

** Mainlander - BCT
sum est if parm == "b" & idstr == "mainlander,bct" & idnum == 0
local main_bl = r(mean)
local mainest_bl : display %4.3f r(mean)
sum est if parm == "b" & idstr == "mainlander,bct" & idnum == -1
local main_lo = r(mean)
local mainest_lo : display %4.3f r(mean)

local location_bl = `main_bl' + 0.005
local location_lo = `mainest_lo' - 0.005

sum greater_bl if parm == "b" & idstr == "mainlander,bct" & idnum > 0
local p_bl : display %4.3f r(mean)
sum greater_lo if parm == "b" & idstr == "mainlander,bct" & idnum > 0
local p_lo : display %4.3f r(mean)

twoway	(hist est if parm == "b" & idstr == "mainlander,bct" & idnum > 0, ///
		width(0.01) start(-0.2) fc(gs12) lc(gs10)) ///
		(scatteri 8 `main_bl' 0 `main_bl', recast(line) lc(black) lp(dash)) ///
		(scatteri 8 `main_lo' 0 `main_lo', recast(line) lc(black) lp(dash)), ///
		scheme(s1color) ytitle("Density") ylabel(0(2)8, angle(0)) ///
		xtitle("Estimate") xlabel(-0.2(0.1)0.2, format(%4.1f)) xscale(ra(-0.2 0.2)) ///
		legend(off) ///
		text(6 `location_bl' "Baseline Estimate: `mainest_bl'" "p-value: `p_bl'", place(e) color(black) just(left) size(small)) ///
		text(7 `location_lo' "Leave-one-out Estimate: `mainest_lo'" "p-value: `p_lo'", place(w) color(black) just(right) size(small))
graph export "$figures/FigureB2c.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB2c.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB2c.png", as(png) replace

