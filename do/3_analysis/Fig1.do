use "$wdata/J1_for_analysis.dta", clear
rename teacherlike_te teacherlike_te_W1

merge 1:1 stuid using "$wdata/J1_W3_Teacher_a.dta"
keep if _m == 3
drop _m

rename teacherlike_te teacherlike_te_W3

merge m:1 teaid using "$wdata/J1_W3_Teacher_b.dta"
keep if _m == 3
drop _m

gen same = W3_teachbegin9 == 0 & W2_teachbegin8 == 0

local cov = "female mainlander achieve hakka aboriginal logfamincome paisei paeduyr pers*"

foreach w in W1 W3{
foreach x in female mainlander achieve {
	gen favoritism_`x'_`w' = .
	local control = subinstr("`cov'","`x'","",.)
	forv i = 1(1)79{
	quiet{
		** Partial Correlation
		cap pcorr teacherlike_te_`w' `x' `cov' if cid == `i'
		cap mat p = r(p_corr)
		cap replace favoritism_`x'_`w' = p[1,1] if cid == `i'	
		cap recode favoritism_`x'_`w' . = 0
		}
	}
}
}

keep year schid claid favoritism_female_W1 favoritism_mainlander_W1 favoritism_achieve_W1 favoritism_female_W3 favoritism_mainlander_W3 favoritism_achieve_W3 same

foreach x in female mainlander achieve {
	egen mean_`x'_W1 = mean(favoritism_`x'_W1), by(schid)
	egen mean_`x'_W3 = mean(favoritism_`x'_W3), by(schid)
	gen favoritism_`x'_W1_demean = favoritism_`x'_W1 - (mean_`x'_W1)
	gen favoritism_`x'_W3_demean = favoritism_`x'_W3 - (mean_`x'_W3)
	drop mean_`x'*
}

duplicates drop

foreach x in female mainlander achieve {
	
pwcorr favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 1, sig
mat S = r(sig)
local sig = S[1,2]
local corr_1 : display %4.3f r(rho)
if `sig' < 0.1{
	local corr_1 = "`corr_1'*"
}
if `sig' < 0.05{
	local corr_1 = "`corr_1'*"
}
if `sig' < 0.01{
	local corr_1 = "`corr_1'*"
}
pwcorr favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 0, sig
mat S = r(sig)
local sig = S[1,2]
local corr_2 : display %4.3f r(rho)
if `sig' < 0.1{
	local corr_2 = "`corr_2'*"
}
if `sig' < 0.05{
	local corr_2 = "`corr_2'*"
}
if `sig' < 0.01{
	local corr_2 = "`corr_2'*"
}

	
twoway 	(sc favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 1, mc(maroon) ms(D) msize(small)) ///
		(lfit favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 1, lc(maroon)) ///
		(sc favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 0, mc(navy) ms(Oh)) ///
		(lfit favoritism_`x'_W3_demean favoritism_`x'_W1_demean if same == 0, lc(navy) lp(dash)), ///
		ylabel(-1(0.2)1, format(%4.1f) angle(0)) xlabel(-1(0.2)1, format(%4.1f)) scheme(s1color) ///
		xtitle(Teacher Favoritism in Grade Seventh) ytitle(Teacher Favoritism in Grade Ninth) ///
		legend(ring(0) col(2) order(1 "Same Teacher" 3 "Different Teachers") pos(4) size(small)) ///
		text(0.6 0.4 "Correlation for" "Same Teacher Classes" " " "`corr_1'*", color(maroon)) ///
		text(-0.6 0.4 "Correlation for" "Different Teachers Classes" " " "`corr_2'*", color(navy))
graph export "$figures/Figure1_`x'.eps", as(eps) replace font("Times New Roman")
graph export "$figures/Figure1_`x'.jpg", as(jpg) replace quality(100)
graph export "$figures/Figure1_`x'.png", as(png) replace
}
