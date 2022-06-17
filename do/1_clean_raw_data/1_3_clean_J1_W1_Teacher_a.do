use "$rdata/J1_W1_Teacher/j1w1t_Jan2020.dta", clear

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student's ID"

**Teacher id
gen teaid = classno
lab var teaid "Teacher's ID"

** Basic
gen inclasinceg7 = at005000 >= 4
lab var inclasinceg7 "In the class since the first semester of grade 7"

** Teacher-Student Relationship
recode at006001 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherclose) label(teacherclose)
recode at006002 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsult) label(teacherconsult)
recode at006003 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsultacademic) label(teacherconsultacademic)
recode at006004 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsultemotion) label(teacherconsultemotion)
recode at006005 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherconsultfriend) label(teacherconsultfriend)
recode at006006 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherparentrelation) label(teacherparentrelation)
recode at006007 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherunderstand) label(teacherunderstand)
recode at006008 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherlike_te) label(teacherlike_te)

** Evaluation
recode at007000 (1 = 5 "top 5") (2 = 4 "6 - 10") (3 = 3 "11 - 20") (4 = 2 "21 - 30") (5 = 1 "31 -") (9 = .), gen(classrank_te) label(classrank_te)
lab var classrank_te "Class Rank (Teacher Report)"

gen hardworking_te = at011001 if at011001 ~= 9
gen goodbehave_te = at011002 if at011002 ~= 9
gen learnenough_te = at011003 if at011003 ~= 9

recode at012001 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(responsibility_te) label(responsibility_te)
recode at012002 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(friendly_te) label(friendly_te)
recode at012003 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(helpother_te) label(helpother_te)
recode at012004 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(zealous_te) label(zealous_te)
recode at012005 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(leadership_te) label(leadership_te)
recode at012006 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(optimism_te) label(optimism_te)
recode at012007 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(confident_te) label(confident_te)
recode at012008 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(humor_te) label(humor_te)
recode at012009 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(justice_te) label(justice_te)
recode at012010 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(motivated_te) label(motivated_te)

recode at012013 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(speechtalent_te) label(speechtalent_te)
recode at012015 (1 = 4 "very agree") (2= 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(sciencetalent_te) label(sciencetalent_te)

** Expectation
recode at015000 (1 = 1 "junior high school") (2 = 2 "senior high school") (3 = 3 "some college") (4 = 4 "undergraduate") (5 = 5 "master") (6 = 6 "doctoral") (7 = 7 "no expectation") (9 = .), gen(expectedu_te) label(expectedu_te)
lab var expectedu_te "Expect highest education level"

gen attendhs_te = at014000 == 1
lab var attendhs_te "Sutible to attend High School"

** Organization

drop id id1 classno at0*

order stuid

save "$wdata/J1_W1_Teacher_a.dta", replace
