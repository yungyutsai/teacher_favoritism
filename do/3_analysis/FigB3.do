use "$wdata/Main_Estimations_All.dta", clear
ap using "$wdata/Bootstrap_Estimations_All"

keep if exhibition == "FigB3"
keep if parm == "2.newgroup#c.favoritism" | (parm == "1.newgroup#c.favoritism" & outcome ~= "achieve")

gen xvar = favoritism
gen yvar = outcome
gen out = 1
replace out = 2 if strpos(col,"_ch") ~= 0
replace out = 3 if strpos(col,"_en") ~= 0
replace out = 4 if strpos(col,"_ma") ~= 0
replace out = 5 if strpos(col,"_sc") ~= 0
replace out = 6 if strpos(col,"_so") ~= 0

replace xvar = "gender" if xvar == "female"
replace yvar = "gender" if yvar == "female"
replace xvar = "ethnicity" if xvar == "mainlander"
replace yvar = "ethnicity" if yvar == "mainlander"
replace xvar = "achievement" if xvar == "achieve"
replace yvar = "achievement" if yvar == "achieve"

gen id = out

gen est = estimate if idn == 0
gen se = estimate if idn ~= 0
collapse (mean)est (sd)se, by(parm xvar yvar out id)
gen min95 = est - 1.96*se
gen max95 = est + 1.96*se

twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(none)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(-0.2(1)0.3, labc(none) tlc(none)) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "Female vs. Male") name("t1", replace) fxsize(110) fysize(5)

twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(none)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(none) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "Mainlander vs. Non-Mainlander") name("t2", replace) fxsize(100) fysize(5)
		
twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(none)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(none) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "High-Achievers vs. Low-Achievers") name("t3", replace) fxsize(100) fysize(5)

twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(white)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(none) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "Gender" "Favoritism") name("x1", replace) fxsize(25) fysize(30)

twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(white)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(none) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "Ethnicity" "Favoritism") name("x2", replace) fxsize(25) fysize(30)

twoway	(scatteri 0 0 0 0, msymbol(none)), /// 
		title(" ") scheme(s1color) plotregion(lcolor(white)) ///
		yscale(range(-0.25 0.3) lc(none)) xscale(range(-1 1) lc(none)) ///
		ylabel(none) xlabel(none) ytitle("") xtitle("") ///
		text(0 0 "Achievement" "Favoritism") name("x3", replace) fxsize(25) fysize(30)
		
		
twoway 	(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 1, lc(navy)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "gender" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "gender" & yvar == "gender" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(-0.2(0.1)0.3, angle(0) format(%4.1f)) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") plotregion(fcolor(gs15)) ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("a", replace) fxsize(110) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 1, lc(navy)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "ethnicity" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "gender" & yvar == "ethnicity" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("b", replace) fxsize(100) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 1, lc(navy)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "gender" & yvar == "achievement" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "gender" & yvar == "achievement" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("c", replace) fxsize(100) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 1, lc(navy)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "gender" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "ethnicity" & yvar == "gender" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(-0.2(0.1)0.3, angle(0) format(%4.1f)) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("d", replace) fxsize(110) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 1, lc(navy)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "ethnicity" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "ethnicity" & yvar == "ethnicity" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") plotregion(fcolor(gs15)) ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("e", replace) fxsize(100) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 1, lc(navy)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "ethnicity" & yvar == "achievement" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "ethnicity" & yvar == "achievement" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("f", replace) fxsize(100) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 1, lc(navy)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "gender" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "achievement" & yvar == "gender" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(-0.2(0.1)0.3, angle(0) format(%4.1f)) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("g", replace) fxsize(110) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 1, lc(navy)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "ethnicity" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "achievement" & yvar == "ethnicity" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") ///
		yline(0, lc(black) lp(dash)) legend(off) scheme(s1color) name("h", replace) fxsize(100) fysize(30)

twoway 	(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 1, lc(navy)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 1, mc(navy) ms(O)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 2, lc(maroon)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 2, mc(maroon) ms(S)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 3, lc(forest_green)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 3, mc(forest_green) ms(D)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 4, lc(ebblue)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 4, mc(ebblue) ms(T)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 5, lc(cranberry)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 5, mc(cranberry) ms(Oh)) ///
		(rcap min95 max95 id if xvar == "achievement" & yvar == "achievement" & out == 6, lc(midgreen)) ///
		(sc est id if xvar == "achievement" & yvar == "achievement" & out == 6, mc(midgreen) ms(Sh)), ///
		yscale(range(-0.25 0.3)) ylabel(none) ///
		xscale(range(0.5 6.5)) xlabel(none) xtitle("") plotregion(fcolor(gs15)) ///
		yline(0, lc(black) lp(dash)) scheme(s1color) name("i", replace) fxsize(100) fysize(30) ///
		legend(col(6) order(2 "Total Score" 4 "Reading" 6 "English" ///
		8 "Math" 10 "Science" 12 "Social Science") ring(0) pos(6) size(small))
		
grc1leg t1 t2 t3 x1 a b c x2 d e f x3 g h i, scheme(s1color) cols(4) hol(1) legendfrom(i) imargin(0 0 0 0) 
graph export "$figures/FigureB3.eps", as(eps) replace font("Times New Roman")
graph export "$figures/FigureB3.jpg", as(jpg) replace quality(100)
graph export "$figures/FigureB3.png", as(png) replace
