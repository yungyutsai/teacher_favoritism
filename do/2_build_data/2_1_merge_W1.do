** Merge student, parent, teacher data
use "$wdata/J1_W1_Student.dta", clear

merge 1:1 stuid using "$wdata/J1_W1_Parent.dta"
drop if _m == 2
drop _m

merge 1:1 stuid using "$wdata/J1_W1_Teacher_a.dta"
keep if _m == 3 //drop those not matched teacher evaluation
drop _m

merge m:1 teaid using "$wdata/J1_W1_Teacher_b.dta"
keep if _m == 3
drop _m

** Demographics and Parent Variables
foreach x in famincome faisei moisei faedu moedu{
	gen `x' = `x'_pa //parent report first, student proxy second
	replace `x' = `x'_st if `x' == . | `x' == 9 | `x' == 0
}
lab de edu 	0 "not applicable" 1 "primary school" 2 "junior high school" 3 "senior high school" ///
			4 "vocational school" 5 "associate bachelor" 6 "bachelor"  7 "graduate" ///
			8 "illiterate" 9 "missing"
lab val faedu edu 
lab val moedu edu 
			
reg famincome faisei moisei i.faedu i.moedu i.schid falive molive i.hometype i.faethnic i.moethnic parmarried i.sibling //Imputed missing value
predict yhat
replace famincome = yhat if famincome == .
drop yhat faedu_st moedu_st famincome_st faisei_st moisei_st famincome_pa moedu_pa faedu_pa moisei_pa faisei_pa
gen logfamincome = log(famincome)
recode logfamincome . = 0
order logfamincome, a(famincome)

gen holo = faethnic == 1 | moethnic == 1 //either father or mother is holo
gen hakka = faethnic == 2 | moethnic == 2
gen mainlander = faethnic == 3 | moethnic == 3
gen aboriginal = faethnic == 4 | moethnic == 4 //either father or mother is aboriginal
order holo hakka mainlander aboriginal, a(moethnic)

recode faedu (0 8 = 0)(1 = 6)(2 = 9)(3/4 = 12)(5 = 14)(6 = 16)(7 = 18), gen(faeduyr)
recode moedu (0 8 = 0)(1 = 6)(2 = 9)(3/4 = 12)(5 = 14)(6 = 16)(7 = 18), gen(moeduyr)
gen paeduyr = (faeduyr + moeduyr)/2
gen paisei = (faisei + moisei)/2

gen gendermatch = teafemale == female

** Personality Variables

misstable patterns filial clean polite obedience organized goodstudent goodbehave moderate frugal tolerance curious responsibility imagination selfcare explorecause friendly consideration harmony humble honest collegeimportant scoreimportant fun selfdecide share tradition anywhere spotlight freedom follower closefriend sociable joingroup consultelder appearance clever teamworker ownway

local covlist = "filial clean polite obedience organized goodstudent goodbehave moderate frugal tolerance curious responsibility imagination selfcare explorecause friendly consideration harmony humble honest collegeimportant scoreimportant fun selfdecide share tradition anywhere spotlight freedom follower closefriend sociable joingroup consultelder appearance clever teamworker ownway"

foreach x in `covlist'{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

foreach x in `covlist'{
	quiet reg `x' famincome faisei moisei i.faedu i.moedu i.schid female birthyr falive molive i.hometype i.faethnic i.moethnic parmarried i.sibling
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == . //Imputed missing value
	drop yhat
}

** Self Concept

misstable patterns cantsolve cantcontrol powerless valuable noproud optimal satisfy useless nothing

local covlist = "cantsolve cantcontrol powerless valuable noproud optimal satisfy useless nothing"

foreach x in `covlist'{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

foreach x in nothing useless{
	quiet reg `x' cantsolve cantcontrol powerless valuable noproud optimal satisfy
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}
foreach x in valuable powerless{
	quiet reg `x' cantsolve cantcontrol noproud optimal satisfy useless nothing
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}
foreach x in noproud powerless{
	quiet reg `x' cantsolve cantcontrol valuable optimal satisfy useless nothing
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}
foreach x in optimal powerless{
	quiet reg `x' cantsolve cantcontrol valuable noproud satisfy useless nothing
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}
foreach x in useless valuable{
	quiet reg `x' cantsolve cantcontrol powerless noproud optimal satisfy nothing
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

factor cantsolve cantcontrol powerless valuable optimal satisfy useless nothing, factor(1)
rotate, blank(0.5)
predict sel_concept
replace sel_concept = - sel_concept

factor cantsolve cantcontrol powerless valuable optimal satisfy useless nothing
rotate, blank(0.5)
predict locus_control self_efficacy self_esteem
replace locus_control = - locus_control
replace self_efficacy = - self_efficacy

** Academic Achievement and Behavior

gen classrank = classrank_te
replace classrank = classrank_st if classrank == .

ologit classrank_primary i.classrank i.claid
predict yhat2 yhat3 yhat4 yhat5
gen yhat = 0
replace yhat = 2 if yhat2 > yhat3 & yhat2 > yhat4 & yhat2 > yhat5
replace yhat = 3 if yhat3 > yhat2 & yhat3 > yhat4 & yhat3 > yhat5
replace yhat = 4 if yhat4 > yhat3 & yhat4 > yhat2 & yhat4 > yhat5
replace yhat = 5 if yhat5 > yhat3 & yhat5 > yhat4 & yhat5 > yhat2
replace classrank_primary = yhat if classrank_primary == . //Imputed missing value
drop yhat* classrank_st classrank_te

gen goodbehave_st = 7 - (skipclass + sabotage + steal + hurt + smokedrink + drug)

** Education Expectation

recode expectedu (1 = 9)(2 = 12)(3 = 14)(4 = 16)(5 = 18)(6 = 22)(7/. = 9), gen(expecteduyr)  
recode expectedu_te (1 = 9)(2 = 12)(3 = 14)(4 = 16)(5 = 18)(6 = 22)(7/. = 9), gen(expecteduyr_te)  
recode expectedu_pa (1 = 9)(2 = 12)(3 = 14)(4 = 16)(5 = 18)(6 = 22)(7/. = 9), gen(expecteduyr_pa)  

** Attitudes toward Teacher

misstable patterns teacherlike teacherhate liketeacher hateteacher

local covlist = "teacherlike teacherhate liketeacher hateteacher"

foreach x in `covlist'{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

foreach x in teacherlike teacherhate{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' liketeacher hateteacher
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

misstable patterns teapartiality teacherunfair teacherjustice

local covlist = "teapartiality teacherunfair teacherjustice"

foreach x in `covlist'{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

** Teacher Attitudes

misstable patterns teanightclass teacramschool teaadmission teapunattitude teapunorder teapunbehave teastrict tealove teacarving teaduty

local covlist = "teanightclass teacramschool teaadmission teapunattitude teapunorder teapunbehave teastrict tealove teacarving teaduty"

foreach x in teanightclass teapunattitude{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

tostring claid, replace
encode claid, gen(cid)
label val cid .
quiet sum cid
local maxcid = r(max)

gen violence = sabotage == 1 | hurt == 1
gen illegal = steal == 1 | smokedrink == 1 | drug == 1
gen unhonest = liegrade == 1 | cheat == 1

** Factor Analysis: Personality

factor filial clean polite obedience organized goodstudent goodbehave moderate frugal tolerance curious responsibility imagination selfcare explorecause friendly consideration harmony humble honest collegeimportant scoreimportant fun selfdecide share tradition anywhere spotlight freedom follower closefriend sociable joingroup consultelder appearance clever teamworker ownway, factor(5)
rotate, blank(0.5)

predict pers_nice pers_outgoing pers_gentle pers_creative pers_bookworm

foreach x in pers_nice pers_outgoing pers_gentle pers_creative pers_bookworm{
	quiet sum `x'
	quiet replace `x' = (`x' - r(mean))/r(sd)
}

** Recode Achieve Group (Previous Achievement)
gen achieve = 0 if classrank_primary == 2
replace achieve = 1 if classrank_primary == 3 | classrank_primary == 4
replace achieve = 2 if classrank_primary == 5

** Save

save "$wdata/J1_W1.dta", replace
