use "$rdata/J1_W3_Student/j1w3s_Jan2020.dta", clear

gen wave = 3
lab var wave "Wave"
gen year = 2002
lab var year "Year"
gen grade = 9
lab var grade "Grade"

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student ID"

** Attitude toward Teacher
gen consultmentor = cs322000 == 2
lab var consultmentor "Will reach out to mentor if enconder challenge"


** Aspiration / Self-concept
recode cs406000 (1 = 1 "junior high school") (2 = 2 "senior high school") (3 = 3 "some college") (4 = 4 "undergraduate") (5 = 5 "master") (6 = 6 "doctoral") (7/9 = 7 "other/missing"), gen(expectedu) label(expectedu)
lab var expectedu "Expect highest education level given current ability and enviroment"

gen hopeattendhs = cs403000 <= 2 
lab var hopeattendhs "Hope could attend high school"

gen couldattendhs = cs404000 <= 2 
lab var couldattendhs "Think could attend high school"

gen cantsolve = cs914001
lab var cantsolve "I cannot solve my problem"
gen cantcontrol = cs914002
lab var cantcontrol "I cannot control things happen on me"

gen optimal = cs914003
lab var optimal "I take optimal attitude on myself"
gen satisfy = cs914004
lab var satisfy "I am satisfy with myself"
gen useless = cs914005
lab var useless "I feel I am useless"
gen nothing = cs914006
lab var nothing "I feel I am nothing"

foreach x of varlist cantsolve-nothing{
	recode `x' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (9 = .)
	lab de `x' 4 "very agree" 3 "agree" 2 "disagree" 1 "very disagree"
	lab val `x' `x'
}

** Organize

drop id id1 classno cs* bs*

order wave year stuid

save "$wdata/J1_W3_Student.dta", replace
