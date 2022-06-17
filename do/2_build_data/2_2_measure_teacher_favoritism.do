use "$wdata/J1_W1.dta", clear

replace achieve = classrank_primary

forv i = 0(1)5{
	foreach x in female mainlander achieve {
		gen favoritism_`x'_`i' = .
	}
}

sort cid
quiet sum cid
local maxcid = r(max)

egen stdlike = std(teacherlike_te), by(cid)

local cov = "female mainlander achieve hakka aboriginal logfamincome paisei paeduyr pers*"
//At most could include 13 variables (because 1 class has only 14 students)

foreach x in female mainlander achieve {
	local control = subinstr("`cov'","`x'","",.)
	egen std`x' = std(`x'), by(cid)
	forv i = 1(1)`maxcid'{
		if `i' == 1 {
			dis "Calculate Favoritism `x' for Class `i' (`maxcid')"
			dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
		}
		_dots `i' 0
		quiet{
			** Zero-Order Correlation
			cap corr teacherlike_te `x' if cid == `i'
			cap replace favoritism_`x'_0 = r(rho) if cid == `i'
			** Partial Correlation
			cap pcorr teacherlike_te `x' `control' if cid == `i'
			cap mat p = r(p_corr)
			cap replace favoritism_`x'_1 = p[1,1] if cid == `i'
			** Regression: Y-Standardized
			cap reg stdlike `x' `control' if cid == `i'
			cap mat b = e(b)
			replace favoritism_`x'_2 = b[1,1] if cid == `i'
			** Regression: Both-Standardized
			cap reg stdlike std`x' `control' if cid == `i'
			cap mat b = e(b)
			replace favoritism_`x'_3 = b[1,1] if cid == `i'	
		}
	}
	dis "End!"
}

local N = _N

foreach x in female mainlander achieve {
	local control = subinstr("`cov'","`x'","",.)
	forv i = 1(1)`N'{
		if `i' == 1 {
			dis "Calculate Favoritism `x' (Leave one out approach) for Student `i' (`N')"
			dis "----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5"
		}
		_dots `i' 0
		quiet{
			cap pcorr teacherlike_te `x' `control' if cid == cid[`i'] & _n ~= `i'
			cap mat p = r(p_corr)
			cap replace favoritism_`x'_5 = p[1,1] if _n == `i'
		}
	}
	dis "End!"
}

foreach x of varlist favoritism*{
	recode `x' . = 0 
	recode `x' .z = 0
}

replace achieve = 0 if classrank_primary == 2
replace achieve = 1 if classrank_primary == 3 | classrank_primary == 4
replace achieve = 2 if classrank_primary == 5


save "$wdata/J1_W1_favoritism.dta", replace
