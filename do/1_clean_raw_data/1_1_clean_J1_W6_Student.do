use "$rdata/J1_W6_Student/j1w6s_Jan2019", clear

gen wave = 6
lab var wave "Wave"
gen year = 2005
lab var year "Year"

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student ID"

** Academic Achievement
gen gsat = fs108000 == 1
lab var gsat "Take GSAT"
gen gsatscore = fs108a00
gen gsat_ch = fs108a01
gen gsat_en = fs108a02
gen gsat_ma = fs108a03

foreach x in gsatscore gsat_ch gsat_en gsat_ma{
	recode `x' 0 97/99 = . 90 = 0
}

lab var gsatscore "Test Score of GSAT"
lab var gsat_ch "Test Score of GSAT Chinese"
lab var gsat_en "Test Score of GSAT English"
lab var gsat_ma "Test Score of GSAT Math"

** Organize
drop id id1 fs* respon

order wave year stuid

save "$wdata/J1_W6_Student.dta", replace
