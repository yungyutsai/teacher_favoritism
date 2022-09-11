global student "female birthyr falive molive i.faethnic i.moethnic parmarried sibling logfamincome faisei moisei i.faedu i.moedu i.achieve"
global student_group "female#newgroup c.birthyr#newgroup falive#newgroup molive#newgroup i.faethnic#newgroup i.moethnic#newgroup parmarried#newgroup c.sibling#newgroup c.logfamincome#newgroup c.faisei#newgroup c.moisei#newgroup i.faedu#newgroup i.moedu#newgroup i.achieve#newgroup"
global teacher "teafemale gendermatch teaage teanorm teagraduate teaexp teamarried teachildren tea_punishment tea_strict tea_responsibility teanightclass teacramschool teaadmission i.teasubject"
global teacher_group "teafemale#newgroup gendermatch#newgroup c.teaage#newgroup teanorm#newgroup teagraduate#newgroup c.teaexp#newgroup teamarried#newgroup c.teachildren#newgroup c.tea_punishment#newgroup c.tea_strict#newgroup c.tea_responsibility#newgroup c.teanightclass#newgroup c.teacramschool#newgroup c.teaadmission#newgroup teasubject#newgroup"

** Placebo Test
forv i = 1(1)1000{
	if `i' == 1 {
		dis "Placebo Test (1000)"
		dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
	}
	_dots `i' 0
	
	qui{
		use "$wdata/J1_W1_favoritism.dta", clear
		
		keep cid favoritism_*_1
		duplicates drop
		
		set seed `i'
		gen random = rnormal()
		sort random
		replace cid = _n //random assign teacher to a class
		
		merge 1:m cid using "$wdata/J1_for_analysis.dta"
		keep if _m == 3
		drop _m
		
		gen attendhs2 = hopeattendhs_w3 - attendhs
		gen expecteduyr2 = expecteduyr_w3 - expecteduyr
		foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
			egen std`y' = std(`y')
		}
		
		foreach x in female mainlander achieve{
			cap drop favoritism newgroup
			egen favoritism = std(favoritism_`x'_1)
			gen newgroup = `x'
			
			foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
				cap areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid)
				cap parmest, saving("$tables/temp/FigureB1_`x'_`y'.dta", replace) idstr("`x',`y'") idnum(`i')
			}
		}
	
		if `i' == 1{
			clear
			foreach x in female mainlander achieve{
				foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
					cap ap using "$tables/temp/FigureB1_`x'_`y'.dta"
				}
			}
			keep if strpos(parm,"favoritism") ~= 0
			save "$tables/temp/FigureB1.dta", replace
		}
		else{
			use "$tables/temp/FigureB1.dta", clear
			foreach x in female mainlander achieve{
				foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
					cap ap using "$tables/temp/FigureB1_`x'_`y'.dta"
				}
			}
			keep if strpos(parm,"favoritism") ~= 0
			save "$tables/temp/FigureB1.dta", replace
		}

	}
}

** Main Result
use "$wdata/J1_for_analysis.dta", clear

gen newgroup = .
gen attendhs2 = hopeattendhs_w3 - attendhs
gen expecteduyr2 = expecteduyr_w3 - expecteduyr

foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
	egen std`y' = std(`y')
}

foreach x in female mainlander achieve{
	
	cap drop favoritism  
	egen favoritism = std(favoritism_`x'_1)
	replace newgroup = `x'
	foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
		areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
		parmest , saving("$tables/temp/FigureB1_`x'_`y'.dta", replace) idstr("`x',`y'") idnum(0)
	}
	
}

use "$tables/temp/FigureB1.dta", clear
foreach x in female mainlander achieve{
	foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
		ap using "$tables/temp/FigureB1_`x'_`y'.dta"
	}
}
keep if strpos(parm,"favoritism") ~= 0
save "$tables/temp/FigureB1.dta", replace


** Main Result (leave-one-out)
use "$wdata/J1_for_analysis.dta", clear

gen newgroup = .
gen attendhs2 = hopeattendhs_w3 - attendhs
gen expecteduyr2 = expecteduyr_w3 - expecteduyr

foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
	egen std`y' = std(`y')
}

foreach x in female mainlander achieve{
	
	cap drop favoritism  
	egen favoritism = std(favoritism_`x'_5)
	replace newgroup = `x'
	foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
		areg std`y' favoritism c.favoritism#1.newgroup c.favoritism#2.newgroup i.newgroup $student $student_group $teacher $teacher_group, a(schid) vce(cl claid)
		parmest , saving("$tables/temp/FigureB1_`x'_`y'.dta", replace) idstr("`x',`y'") idnum(-1)
	}
	
}

use "$tables/temp/FigureB1.dta", clear
foreach x in female mainlander achieve{
	foreach y in bct bct_ch bct_en bct_ma bct_sc bct_so attendhs_te expecteduyr_te attendhs2 expecteduyr2 consultmentor teacherconsultacademic teacherconsultemotion teacherconsultfriend {
		ap using "$tables/temp/FigureB1_`x'_`y'.dta"
	}
}
keep if strpos(parm,"favoritism") ~= 0
save "$tables/temp/FigureB1.dta", replace
