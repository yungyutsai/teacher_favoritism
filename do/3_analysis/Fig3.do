use "$wdata/Main_Estimations_All.dta", clear
ap using "$wdata/Bootstrap_Estimations_All"

keep if exhibition == "Fig3"
 
gen coef = est if idn == 0
gen se = est if idn ~= 0
collapse (mean)coef = coef (sd)se = se, by(method parm)

gen upper = coef + 1.96*se
gen lower = coef - 1.96*se

gen id = 0
replace id = 1 if parm == "1.favor_female_bl#0b.favor_mainlander_bl#0b.favor_achieve_bl"
replace id = 2 if parm == "0b.favor_female_bl#1.favor_mainlander_bl#0b.favor_achieve_bl"
replace id = 3 if parm == "0b.favor_female_bl#0b.favor_mainlander_bl#1.favor_achieve_bl"
replace id = 4 if parm == "1.favor_female_bl#1.favor_mainlander_bl#0b.favor_achieve_bl"
replace id = 5 if parm == "1.favor_female_bl#0b.favor_mainlander_bl#1.favor_achieve_bl"
replace id = 6 if parm == "0b.favor_female_bl#1.favor_mainlander_bl#1.favor_achieve_bl"
replace id = 7 if parm == "1.favor_female_bl#1.favor_mainlander_bl#1.favor_achieve_bl"
replace id = 1 if parm == "1.favor_female_lo#0b.favor_mainlander_lo#0b.favor_achieve_lo"
replace id = 2 if parm == "0b.favor_female_lo#1.favor_mainlander_lo#0b.favor_achieve_lo"
replace id = 3 if parm == "0b.favor_female_lo#0b.favor_mainlander_lo#1.favor_achieve_lo"
replace id = 4 if parm == "1.favor_female_lo#1.favor_mainlander_lo#0b.favor_achieve_lo"
replace id = 5 if parm == "1.favor_female_lo#0b.favor_mainlander_lo#1.favor_achieve_lo"
replace id = 6 if parm == "0b.favor_female_lo#1.favor_mainlander_lo#1.favor_achieve_lo"
replace id = 7 if parm == "1.favor_female_lo#1.favor_mainlander_lo#1.favor_achieve_lo"

drop if id == 0

forv i = 1(1)7{
	sum coef if id == `i' & method == "bl"
	local coef`i': display %4.3f r(mean)
}

twoway 	(rcap upper lower id if method == "bl", lc(navy)) ///
		(sc coef id if method == "bl", mc(navy)), ///
		scheme(s1color) xtitle("") xlabel(none) xscale(ra(0.5 7.5)) ///
		ylabel(-0.3(0.1)0.4, angle(0) format(%4.1f)) yscale(ra(-0.3 0.418)) ///
		legend(order(2 "Estimates" 1 "95% CI")) ///
		yline(0, lc(black)) ytitle(Estimate) ///
		text(-0.2 1 "Gender" "Favortism", size(small) place(s)) ///
		text(-0.2 2 "Ethnic" "Favortism", size(small) place(s)) ///
		text(-0.2 3 "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 4 "Gender" "+" "Ethnic" "Favortism", size(small) place(s)) ///
		text(-0.2 5 "Gender" "+" "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 6 "Ethnic" "+" "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 7 "Triple" "Favortism", size(small) place(s)) ///
		text(`coef1' 1.1 "`coef1'", size(small) place(e)) ///
		text(`coef2' 2.1 "`coef2'", size(small) place(e)) ///
		text(`coef3' 3.1 "`coef3'", size(small) place(e)) ///
		text(`coef4' 4.1 "`coef4'", size(small) place(e)) ///
		text(`coef5' 5.1 "`coef5'", size(small) place(e)) ///
		text(`coef6' 6.1 "`coef6'", size(small) place(e)) ///
		text(`coef7' 7.1 "`coef7'", size(small) place(e))
graph export "$figures/Figure3a.eps", as(eps) replace font("Times New Roman")
graph export "$figures/Figure3a.jpg", as(jpg) replace quality(100)
graph export "$figures/Figure3a.png", as(png) replace 

forv i = 1(1)7{
	sum coef if id == `i' & method == "lo"
	local coef`i': display %4.3f r(mean)
}

twoway 	(rcap upper lower id if method == "lo", lc(navy)) ///
		(sc coef id if method == "lo", mc(navy)), ///
		scheme(s1color) xtitle("") xlabel(none) xscale(ra(0.5 7.5)) ///
		ylabel(-0.3(0.1)0.4, angle(0) format(%4.1f)) yscale(ra(-0.3 0.418)) ///
		legend(order(2 "Estimates" 1 "95% CI")) ///
		yline(0, lc(black)) ytitle(Estimate) ///
		text(-0.2 1 "Gender" "Favortism", size(small) place(s)) ///
		text(-0.2 2 "Ethnic" "Favortism", size(small) place(s)) ///
		text(0.25 3 "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 4 "Gender" "+" "Ethnic" "Favortism", size(small) place(s)) ///
		text(-0.2 5 "Gender" "+" "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 6 "Ethnic" "+" "Achievement" "Favortism", size(small) place(s)) ///
		text(-0.2 7 "Triple" "Favortism", size(small) place(s)) ///
		text(`coef1' 1.1 "`coef1'", size(small) place(e)) ///
		text(`coef2' 2.1 "`coef2'", size(small) place(e)) ///
		text(`coef3' 3.1 "`coef3'", size(small) place(e)) ///
		text(`coef4' 4.1 "`coef4'", size(small) place(e)) ///
		text(`coef5' 5.1 "`coef5'", size(small) place(e)) ///
		text(`coef6' 6.1 "`coef6'", size(small) place(e)) ///
		text(`coef7' 7.1 "`coef7'", size(small) place(e))
graph export "$figures/Figure3b.eps", as(eps) replace font("Times New Roman")
graph export "$figures/Figure3b.jpg", as(jpg) replace quality(100)
graph export "$figures/Figure3b.png", as(png) replace
