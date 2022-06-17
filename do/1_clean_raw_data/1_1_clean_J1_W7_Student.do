use "$rdata/J1_W7_Student/j1w7s_Jan2019", clear

gen wave = 7
lab var wave "Wave"
gen year = 2006
lab var year "Year"

**New Student id
gen stuid = id2
lab var stuid "Student ID"

** Academic Achievement
gen _gsat = gs003000 == 1
lab var _gsat "Take GSAT"
gen _gsatscore = gs003001
recode _gsatscore 0 95/99 = . 90 = 0
lab var _gsatscore "Test Score of GSAT"

gen ast = gs005000 == 1
lab var ast "Take AST"
gen ast_ch = gs005001
recode ast_ch 995/999 = .
lab var ast_ch "Test Score of AST-Chinese"
gen ast_en = gs005002
recode ast_en 995/999 = .
lab var ast_en "Test Score of AST-English"
gen ast_ma = gs005003
recode ast_ma 995/999 = .
lab var ast_ma "Test Score of AST-MATH A"
gen ast_mb = gs005004
recode ast_mb 995/999 = .
lab var ast_mb "Test Score of AST-MATH B"

** Organize
drop id1 id2 gs*

order wave year stuid

save "$wdata/J1_W7_Student.dta", replace
