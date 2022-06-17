global student "female birthyr falive molive i.faethnic i.moethnic parmarried sibling logfamincome faisei moisei i.faedu i.moedu i.achieve"
global student_group "female#newgroup c.birthyr#newgroup falive#newgroup molive#newgroup i.faethnic#newgroup i.moethnic#newgroup parmarried#newgroup c.sibling#newgroup c.logfamincome#newgroup c.faisei#newgroup c.moisei#newgroup i.faedu#newgroup i.moedu#newgroup i.achieve#newgroup"
global teacher "teafemale gendermatch teaage teanorm teagraduate teaexp teamarried teachildren tea_punishment tea_strict tea_responsibility teanightclass teacramschool teaadmission"
global teacher_group "teafemale#newgroup gendermatch#newgroup c.teaage#newgroup teanorm#newgroup teagraduate#newgroup c.teaexp#newgroup teamarried#newgroup c.teachildren#newgroup c.tea_punishment#newgroup c.tea_strict#newgroup c.tea_responsibility#newgroup c.teanightclass#newgroup c.teacramschool#newgroup c.teaadmission#newgroup teasubject#newgroup"

foreach x in female mainlander achieve{
	
	if "`x'" == "female"{
		local label1 = "Male"
		local label2 = "Female"
	}
	if "`x'" == "mainlander"{
		local label1 = "Non-Mainlander"
		local label2 = "Mainlander"
	}
	if "`x'" == "achieve"{
		local label1 = "Low Achievers"
		local label2 = "High Achievers"
	}

	use "$wdata/J1_for_analysis.dta", clear
	gen newgroup = `x'
	
	egen favoritism = std(favoritism_`x')
	
	gen schid0 = schid
	
	egen bctavg = mean(bct), by(schid)
	replace bct = bct - bctavg
	
	areg bct $student $student_group i.newgroup /*$teacher $teacher_group*/, a(schid)
	predict bcthat
	
	if "`x'" == "achieve"{ //Only include high and low achievers
		drop if newgroup == 1
		recode newgroup 2 = 1
	}
	
	
	reg bct favoritism c.favoritism#i.newgroup
	egen bin = cut(favoritism), group(12)
	egen meanbct = mean(bct), by(bin newgroup)
	egen meanbcthat = mean(bcthat), by(bin newgroup)
	egen meanfavoritism = mean(favoritism), by(bin newgroup)

	gen x = .
	gen y = .
	
	twoway 	(lfitci bct favoritism if newgroup == 0, lw(none) fc(navy%20)) ///
			(lfitci bct favoritism if newgroup == 1, lw(none) fc(maroon%20)) ///
			(lfit bct favoritism if newgroup == 0, lc(navy) lp(dash)) ///
			(lfit bct favoritism if newgroup == 1, lc(maroon)) ///
			(sc meanbct meanfavoritism if newgroup == 0, mc(navy) ms(Oh)) ///
			(sc meanbct meanfavoritism if newgroup == 1, mc(maroon) ms(D) msize(small)) ///
			(connect y x, lc(navy) lp(dash) mc(navy) ms(Oh)) ///
			(connect y x, lc(maroon) mc(maroon) ms(D) msize(small)), ///
			scheme(s1color) /// 
			xtitle(Standardized Favoritism) ytitle("BCT Score (Demean within Schools)") ///
			xlabel(-2(0.5)2, format(%4.1f)) ylabel(-80(20)80,angle(0) grid) ///
			legend(order(9 "`label1'" 10 "`label2'") ring(0) position(4) size(small)) 
	graph export "$figures/Figure2_`x'_bct.eps", as(eps) replace font("Times New Roman")
	graph export "$figures/Figure2_`x'_bct.jpg", as(jpg) replace quality(100)
	graph export "$figures/Figure2_`x'_bct.png", as(png) replace 
	
	
	twoway 	(lfitci bcthat favoritism if newgroup == 0, lw(none) fc(navy%20)) ///
			(lfitci bcthat favoritism if newgroup == 1, lw(none) fc(maroon%20)) ///
			(lfit bcthat favoritism if newgroup == 0, lc(navy) lp(dash)) ///
			(lfit bcthat favoritism if newgroup == 1, lc(maroon)) ///
			(sc meanbcthat meanfavoritism if newgroup == 0, mc(navy) ms(Oh)) ///
			(sc meanbcthat meanfavoritism if newgroup == 1, mc(maroon) ms(D) msize(small)) ///
			(connect y x, lc(navy) lp(dash) mc(navy) ms(Oh)) ///
			(connect y x, lc(maroon) mc(maroon) ms(D) msize(small)), ///
			scheme(s1color) /// 
			xtitle(Standardized Favoritism) ytitle("BCT Score (Demean within Schools)") ///
			xlabel(-2(0.5)2, format(%4.1f)) ylabel(-80(20)80,angle(0) grid) ///
			legend(order(9 "`label1'" 10 "`label2'") ring(0) position(4) size(small)) 
	graph export "$figures/Figure2_`x'_bcthat.eps", as(eps) replace font("Times New Roman")
	graph export "$figures/Figure2_`x'_bcthat.jpg", as(jpg) replace quality(100)
	graph export "$figures/Figure2_`x'_bcthat.png", as(png) replace
}
