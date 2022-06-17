use "$rdata/J1_W12_Student/TYP2014_Nov2019.dta", clear

gen wave = 12
lab var wave "Wave"
gen year = 2014
lab var year "Year"

**New Student id
gen stuid = id2
lab var stuid "Student ID"

**Education
recode m2sedu (1 = 1 "junior high") (2 3 = 2 "senior high") (4 5 = 3 "some college") (6/8 = 4 "undergraduate") (9 = 5 "master") (10 = 6 "doctoral") (98/99 = .), gen(highestedu) label(highestedu)
recode highestedu 1 = 9 2 = 12 3 = 14 4 = 16 5 = 18 6 = 22, gen(eduyr)
lab var highestedu "Highest Educational Degree"
lab var eduyr "Year of Education"

** Organize
drop id id1 id2 m2*

order wave year stuid

save "$wdata/J1_W11_Student.dta", replace
