use "$rdata/J1_W10_Student/TYP2011_Nov2017.dta", clear

gen wave = 10
lab var wave "Wave"
gen year = 2011
lab var year "Year"

**New Student id
gen stuid = id2
lab var stuid "Student ID"

recode degree (2 = 1 "junior high") (3 4 = 2 "senior high") (5 = 3 "some college") (6 = 4 "undergraduate") (7 = 5 "master") (99 = .), gen(_highestedu) label(_highestedu)
recode _highestedu 1 = 9 2 = 12 3 = 14 4 = 16 5 = 18 6 = 22, gen(_eduyr)
lab var _highestedu "Highest Educational Degree"
lab var _eduyr "Year of Education"

** Organize
drop id id1 id2 m1* highest_sch highest_sch_open degree typesch npsch survey_method

order wave year stuid

save "$wdata/J1_W10_Student.dta", replace
