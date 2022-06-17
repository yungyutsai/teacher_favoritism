use "$wdata/J1_for_analysis.dta", clear

gen n = 1
unique schid
gen nschool = r(sum)
unique cid
gen nclass = r(sum)
egen nstudent = count(n)
egen avgstudentinc = count(n), by(cid)

lab var nschool "Number of Schools"
lab var nclass "Number of Classes"
lab var nstudent "Number of Students"
lab var avgstudentinc "Average Number of Students in a Class"

gen age = 2000 - birthyr
gen highachiever = achieve == 2
gen middleachiever = achieve == 1
gen lowachiever = achieve == 0
replace famincome = famincome / 1000

lab var female "Female"
lab var mainlander "Mainlander"
lab var holo "Holo"
lab var hakka "Haka"
lab var aboriginal "Indigenous"
lab var highachiever "High Achiever"
lab var middleachiever "Middle Achiever"
lab var lowachiever "Low Achiever"
lab var age "Age as of 2000"
lab var falive "Live with Father"
lab var molive "Live with Mother"
lab var parmarried "Parents are Married"
lab var sibling "Number of Sibling(s)"
lab var famincome "Family Montly Income (NTD)"
lab var faisei "Father ISEI"
lab var moisei "Mother ISEI"
lab var faeduyr "Father Year of Education"
lab var moeduyr "Mother Year of Education"
lab var favoritism_female "Gender Favoritism (Favor Female)"
lab var favoritism_mainlander "Ethnicity Favoritism (Favor Mainlanders)"
lab var favoritism_achieve "Achievement Favoritism (Favor High Achievers)"
lab var favoritism_female_5 "Gender Favoritism (Favor Female)"
lab var favoritism_mainlander_5 "Ethnicity Favoritism (Favor Mainlanders)"
lab var favoritism_achieve_5 "Achievement Favoritism (Favor High Achievers)"
lab var bct "Total Score"
lab var bct_ch "Reading"
lab var bct_en "English"
lab var bct_ma "Math"
lab var bct_sc "Science"
lab var bct_so "Social Science"


summarystat female (mainlander holo hakka aboriginal) (highachiever middleachiever lowachiever) age falive molive parmarried sibling famincome faisei moisei faeduyr moeduyr (favoritism_female favoritism_mainlander favoritism_achieve) (favoritism_female_5 favoritism_mainlander_5 favoritism_achieve_5) (bct bct_ch bct_en bct_ma bct_sc bct_so) avgstudentinc nschool nclass nstudent , st(mean sd min max) replace panel("Ethnicity" "Previous Achievement" "Teacher Favoritism (Baseline Approach)" "Teacher Favoritism (Leave-One-Out Approach)" "Standardized Exam Score") norestore

save "$wdata/Summary_Sata.dta", replace

use "$wdata/J1_for_analysis.dta", clear

gen n = 1
unique schid
gen nschool = r(sum)
unique cid
gen nclass = r(sum)
egen nstudent = count(n)
egen avgstudentinc = count(n), by(cid)

lab var nschool "Number of Schools"
lab var nclass "Number of Classes"
lab var nstudent "Number of Students"
lab var avgstudentinc "Average Number of Students in a Class"

gen age = 2000 - birthyr
gen highachiever = achieve == 2
gen middleachiever = achieve == 1
gen lowachiever = achieve == 0
replace famincome = famincome / 1000

collapse (sd)female mainlander holo hakka aboriginal highachiever middleachiever lowachiever age falive molive parmarried sibling famincome faisei moisei faeduyr moeduyr favoritism_female favoritism_mainlander favoritism_achieve favoritism_female_5 favoritism_mainlander_5 favoritism_achieve_5 bct bct_ch bct_en bct_ma bct_sc bct_so avgstudentinc, by(schid)


summarystat female (mainlander holo hakka aboriginal) (highachiever middleachiever lowachiever) age falive molive parmarried sibling famincome faisei moisei faeduyr moeduyr (favoritism_female favoritism_mainlander favoritism_achieve) (favoritism_female_5 favoritism_mainlander_5 favoritism_achieve_5) (bct bct_ch bct_en bct_ma bct_sc bct_so) avgstudentinc, st(mean) replace panel("Ethnicity" "Previous Achievement" "Teacher Favoritism (Baseline Approach)" "Teacher Favoritism (Leave-One-Out Approach)" "Standardized Exam Score") norestore

keep v2
rename v2 v6
merge 1:1 _n using "$wdata/Summary_Sata.dta"
order v6, a(v3)
replace v6 = "Within-school SD" in 1
drop _m

save "$wdata/Summary_Sata.dta", replace
export excel "$tables/Tab1.xlsx", replace
