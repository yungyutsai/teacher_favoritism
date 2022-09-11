use "$wdata/J1_W1_favoritism.dta", clear

drop if schid == 1071 | schid == 2081 //Drop same-gender school (Impossible for gender favoritism)

merge m:1 teaid using "$wdata/J1_W1_Teacher.dta", update replace
drop if _m == 2
drop _m

merge 1:1 stuid using "$wdata/J1_W3_Teacher_a.dta"
drop if _m == 2
drop _m

merge 1:1 stuid using "$wdata/J1_W3.dta"
drop if _m == 2
drop _m

merge m:1 teaid using "$wdata/J1_W2_Teacher_b.dta"
drop if _m == 2
drop _m
merge m:1 teaid using "$wdata/J1_W3_Teacher_b.dta"
drop if _m == 2
drop _m

gen teachlength = 1
replace teachlength = 3 if W2_teachbegin7 == 1 & W3_teachbegin7 == 1
replace teachlength = 2 if W2_teachbegin7 == 1 & W3_teachbegin7 == 0
replace teachlength = 1 if W2_teachbegin7 == 0 | W3_teachbegin8 == 1

** Default use partial correlation
gen favoritism_female = favoritism_female_1
gen favoritism_mainlander = favoritism_mainlander_1
gen favoritism_achieve = favoritism_achieve_1

save "$wdata/J1_for_analysis.dta", replace
