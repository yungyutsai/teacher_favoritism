use "$rdata/J1_W2_Teacher/j1w2t_Jan2020.dta", clear

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student's ID"

**Teacher id
gen teaid = classno
lab var teaid "Teacher's ID"

** Basic
egen teachbegin = mode(bt001000), by(teaid)

keep teaid teachbegin
duplicates drop
gen W2_teachbegin7 = teachbegin <= 2
gen W2_teachbegin8 = teachbegin > 2
drop teachbegin

save "$wdata/J1_W2_Teacher_b.dta", replace


use "$rdata/J1_W3_Teacher/j1w3t_Jan2020_2.dta", clear

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student's ID"

**Teacher id
gen teaid = classno
lab var teaid "Teacher's ID"

** Basic
egen teachbegin = mode(ct001000), by(teaid)

keep teaid teachbegin
duplicates drop
gen W3_teachbegin7 = teachbegin <= 2
gen W3_teachbegin8 = teachbegin > 2 & teachbegin <= 4
gen W3_teachbegin9 = teachbegin > 4
drop teachbegin

save "$wdata/J1_W3_Teacher_b.dta", replace
