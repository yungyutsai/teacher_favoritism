use "$rdata/J1_W1_Teacher/j1w1tb_Jan2020.dta", clear

** Teacher id
gen teaid = classno
lab var teaid "Teacher's ID"

** Demographic
gen teafemale = bisex == 2
lab var teafemale "Teacher is Female"

gen teabirthyr = bibirth + 1911
lab var teabirthyr "Teacher's Bitrh Year"

gen teaage = 2000 - teabirthyr
lab var teaage "Teacher's Age"

gen teanorm = biedu == 1
lab var teanorm "Teacher graduate from norm university"

gen teagraduate = bidegree == 2
lab var teagraduate "Teacher have graduate degree"

recode bisubjet (1 = 1 "Chinese")(2 = 2 "English")(3 = 3 "Math")(5/8 = 0 "Other"), gen(teasubject) label(teasubject)
lab var teasubject "Teacher's teaching subject"
recode bisubjet (1 = 1 "Chinese")(2 = 2 "English")(3 = 3 "Math")(4 = 4 "Physical and chemical")(5 = 5 "History")(6 = 6 "Civic Study")(7 = 7 "Geography")(8 = 0 "Other"), gen(teasubject_d) label(teasubject_d)
lab var teasubject_d "Teacher's teaching subject (Detailed)"



gen teamarried = bi109000 == 1
lab var teamarried "Teacher is married"

gen teachildren = 0
replace teachildren = 1 if bi112a01 == 1 | bi112a01 == 2
replace teachildren = 2 if bi112b01 == 1 | bi112b01 == 2
replace teachildren = 3 if bi112c01 == 1 | bi112c01 == 2
lab var teachildren "Teacher's number of children"

recode bi202000 99 = .
gen teaexp = bi202000
replace teaexp = bi204000 if teaexp == .
lab var teaexp "Teacher's year of experience"

gen teavolunteer = bi205000  == 1
lab var teavolunteer "Teacher volunteer to serve as mentor"

** Attitude
recode bi304000 (1 = 5 "very helpful")(2 = 4 "helpful") (3 = 3 "neutral") (4 = 2 "helpless") (5 = 1 "very helpless")(0 9 = .), gen(teanightclass) label(teanightclass) 
lab var teanightclass "Teacher's attitude toward night class"
recode bi305000 (1 = 5 "very helpful")(2 = 4 "helpful") (3 = 3 "neutral") (4 = 2 "helpless") (5 = 1 "very helpless")(0 9 = .), gen(teacramschool) label(teacramschool) 
lab var teacramschool "Teacher's attitude toward cram school"
recode bi306000 (1 = 5 "very helpful")(2 = 4 "helpful") (3 = 3 "neutral") (4 = 2 "helpless") (5 = 1 "very helpless")(0 9 = .), gen(teaadmission) label(teaadmission) 
lab var teaadmission "Teacher's attitude toward multiple admission approach"

recode bi308001 (1 = 4 "usually helpful")(2 = 3 "sometime helpful") (3 = 2 "not really helpful") (4 = 1 "helpless")(0 9 = .), gen(teapunattitude) label(teapunattitude) 
lab var teapunattitude "Teacher's attitude toward physical punishment can improve students' learning attitude"
recode bi308002 (1 = 4 "usually helpful")(2 = 3 "sometime helpful") (3 = 2 "not really helpful") (4 = 1 "helpless")(0 9 = .), gen(teapunorder) label(teapunorder) 
lab var teapunorder "Teacher's attitude toward physical punishment can improve class order"
recode bi308003 (1 = 4 "usually helpful")(2 = 3 "sometime helpful") (3 = 2 "not really helpful") (4 = 1 "helpless")(0 9 = .), gen(teapunbehave) label(teapunbehave) 
lab var teapunbehave "Teacher's attitude toward physical punishment can improve students' behave"

recode bi309001 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree")(0 9 = .), gen(teastrict) label(teastrict)
lab var teastrict "Strict teacher leads to good students"
recode bi309002 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree")(0 9 = .), gen(tealove) label(tealove)
lab var tealove "Education of love only apply on several students"
recode bi309003 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree")(0 9 = .), gen(teacarving) label(teacarving)
lab var teacarving "Jade without carving, will not become a beautiful artifact."
recode bi309004 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree")(0 9 = .), gen(teaduty) label(teaduty)
lab var teaduty "Serving as mentor is a duty"

** Organization

drop classno bi*

order teaid

save "$wdata/J1_W1_Teacher_b.dta", replace
