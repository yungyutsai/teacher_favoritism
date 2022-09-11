global student "female birthyr falive molive i.faethnic i.moethnic parmarried sibling logfamincome faisei moisei i.faedu i.moedu i.achieve"
global student_group "female#newgroup c.birthyr#newgroup falive#newgroup molive#newgroup i.faethnic#newgroup i.moethnic#newgroup parmarried#newgroup c.sibling#newgroup c.logfamincome#newgroup c.faisei#newgroup c.moisei#newgroup i.faedu#newgroup i.moedu#newgroup i.achieve#newgroup"
global teacher "teafemale gendermatch teaage teanorm teagraduate teaexp teamarried teachildren tea_punishment tea_strict tea_responsibility teanightclass teacramschool teaadmission i.teasubject"
global teacher_group "teafemale#newgroup gendermatch#newgroup c.teaage#newgroup teanorm#newgroup teagraduate#newgroup c.teaexp#newgroup teamarried#newgroup c.teachildren#newgroup c.tea_punishment#newgroup c.tea_strict#newgroup c.tea_responsibility#newgroup c.teanightclass#newgroup c.teacramschool#newgroup c.teaadmission#newgroup teasubject#newgroup"

cap mkdir "$wdata/bootstrap"

** Main Result

use "$wdata/J1_for_analysis.dta", clear

gen newgroup = .

** Table 2 (Pygmalion effect)

gen attendhs2 = hopeattendhs_w3 - attendhs
gen expecteduyr2 = expecteduyr_w3 - expecteduyr
gen sel_concept2 = sel_concept_w3 - sel_concept

foreach x in female mainlander achieve{ //Favoritism
	replace newgroup = `x'
	foreach z in 1 5{ //Baseline or Leave-one-out Approach
		if ("`z'" == "1") local method = "bl" //baseline
		if ("`z'" == "5") local method = "lo" //leave-one-out
		cap drop favoritism
		egen favoritism = std(favoritism_`x'_`z')
		loc c = 0
		foreach y in attendhs_te expecteduyr_te attendhs2 expecteduyr2 { //Outcomes
			loc c = `c' + 1
			cap drop std`y'
			egen std`y' = std(`y')
			
			areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_Tab5_`x'_`y'_`method'_c`c'.dta", replace) idstr("Tab5,`x',`y',`method',c`c'") idnum(0)
		}
	}
}

** Table 3 (Teacher student relationship)

foreach x in female mainlander achieve{ //Favoritism
	replace newgroup = `x'
	foreach z in 1 5{ //Baseline or Leave-one-out Approach
		if ("`z'" == "1") local method = "bl" //baseline
		if ("`z'" == "5") local method = "lo" //leave-one-out
		cap drop favoritism
		egen favoritism = std(favoritism_`x'_`z')
		loc c = 0
		foreach y in consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend{ //Outcomes
			loc c = `c' + 1
			cap drop std`y'
			egen std`y' = std(`y')
			
			areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_Tab6_`x'_`y'_`method'_c`c'.dta", replace) idstr("Tab6,`x',`y',`method',c`c'") idnum(0)
		}
	}
}

** Table 4, 5, 6 (Achievement)
foreach x in female mainlander achieve{ //Favoritism
	if ("`x'" == "female") local t = 2
	if ("`x'" == "mainlander") local t = 3
	if ("`x'" == "achieve") local t = 4
	replace newgroup = `x'
	foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so{ //Outcomes
		cap drop std`y'
		egen std`y' = std(`y')
		foreach z in 1 5{ //Baseline or Leave-one-out Approach
		if ("`z'" == "1") local method = "bl" //baseline
		if ("`z'" == "5") local method = "lo" //leave-one-out
			cap drop favoritism
			egen favoritism = std(favoritism_`x'_`z')
			
			** Column (1)
			areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_Tab`t'_`x'_`y'_`method'_c1.dta", replace) idstr("Tab`t',`x',`y',`method',c1") idnum(0)

			** Column (2)
			areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_Tab`t'_`x'_`y'_`method'_c2.dta", replace) idstr("Tab`t',`x',`y',`method',c2") idnum(0)
			
			** Column (3)
			areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_Tab`t'_`x'_`y'_`method'_c3.dta", replace) idstr("Tab`t',`x',`y',`method',c3") idnum(0)
		}
	}
}

** Figure 3
cap drop newgroup
egen newgroup = group(female mainlander achieve)

cap drop stdbct
egen stdbct = std(bct)

foreach x in female mainlander achieve{
	gen favoritism_`x'_bl = favoritism_`x'_1 > 0
	gen favoritism_`x'_lo = favoritism_`x'_5 > 0
}

foreach x in bl lo{
	gen favor_female_`x' = favoritism_female_`x' == female
	gen favor_mainlander_`x' = favoritism_mainlander_`x' == mainlander
	gen favor_achieve_`x' = favoritism_achieve_`x' == 1 & achieve == 2 | favoritism_achieve_`x' == 0 & achieve == 0

	gen favor_`x' = favor_female_`x' + favor_mainlander_`x' + favor_achieve_`x'
}

areg stdbct favor_female_bl#favor_mainlander_bl#favor_achieve_bl favoritism_female_bl#favoritism_mainlander_bl#favoritism_achieve_bl $student $teacher, a(schid) vce(cl claid)
cap parmest , saving("$wdata/bootstrap/Main_Fig3_bl.dta", replace) idstr("Fig3,,bct,bl,") idnum(0)

areg stdbct favor_female_lo#favor_mainlander_lo#favor_achieve_lo favoritism_female_bl#favoritism_mainlander_bl#favoritism_achieve_bl $student $teacher, a(schid) vce(cl claid)
cap parmest , saving("$wdata/bootstrap/Main_Fig3_lo.dta", replace) idstr("Fig3,,bct,lo,") idnum(0)

** Figure B3 (Placebo Test)

cap gen newgroup = .
cap gen newgroup2 = .
foreach z in bct bct_ch bct_en bct_ma bct_sc bct_so{
	cap drop std`z'
	egen std`z' = std(`z')
}

foreach x in female mainlander achieve{
	cap drop favoritism
	egen favoritism = std(favoritism_`x')
	replace newgroup2 = `x'
	foreach y in female mainlander achieve{
		replace newgroup = `y'
		foreach z in bct bct_ch bct_en bct_ma bct_sc bct_so{
			areg std`z' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
			cap parmest , saving("$wdata/bootstrap/Main_FigB3_`x'_`y'_`z'.dta", replace) idstr("FigB3,`x',`y',`z'") idnum(0)
		}
	}
}

*** Append All

clear
local files : dir "$wdata/bootstrap" files "Main*.dta" //Get data list
foreach file in `files' {
	ap using "$wdata/bootstrap/`file'"
}

keep if strpos(parm,"favor")~= 0
drop if parm == "2o.newgroup#co.favoritism"

gen exhibition = substr(idstr,1,strpos(idstr,",")-1)
replace idstr = substr(idstr,strpos(idstr,",")+1,.)
gen favoritism = substr(idstr,1,strpos(idstr,",")-1)
replace idstr = substr(idstr,strpos(idstr,",")+1,.)
gen outcome = substr(idstr,1,strpos(idstr,",")-1)
replace idstr = substr(idstr,strpos(idstr,",")+1,.)
gen method = substr(idstr,1,strpos(idstr,",")-1)
replace idstr = substr(idstr,strpos(idstr,",")+1,.)
gen column = idstr
drop idstr

drop if strpos(parm,"favoritism")~= 0 & exhibition == "Fig3"


order exhibition favoritism outcome method column
compress

save "$wdata/Main_Estimations_All.dta", replace
