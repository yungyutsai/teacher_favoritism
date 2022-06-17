use "$rdata/J1_W3_Teacher/j1w3t_Jan2020_2.dta", clear

** New Student id
gen stuid = id1 + 100000
lab var stuid "Student's ID"

** Teacher id
gen teaid = classno
lab var teaid "Teacher's ID"

** Evaluation
recode ct005007 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherlike_te) label(teacherlike_te)

** Academic Achievement
gen bct_ch = ct029001 if ct029001 ~= 99
gen bct_en = ct029002 if ct029002 ~= 99
gen bct_ma = ct029003 if ct029003 ~= 99
gen bct_sc = ct029004 if ct029004 ~= 99
gen bct_so = ct029005 if ct029005 ~= 99
gen bct = ct029006 if ct029006 ~= 999

lab var bct "Test Score of BCT"
lab var bct_ch "Test Score of BCT-Reading"
lab var bct_en "Test Score of BCT-English"
lab var bct_ma "Test Score of BCT-Math"
lab var bct_sc "Test Score of BCT-Science"
lab var bct_so "Test Score of BCT-SocialScience"

** Teacher-Student Relationship
recode ct005003 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsultacademic_W3) label(teacherconsultacademic_W3)
recode ct005004 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsultemotion_W3) label(teacherconsultemotion_W3)

** Organization
drop id id1 classno ct*

order stuid

save "$wdata/J1_W3_Teacher_a.dta", replace
