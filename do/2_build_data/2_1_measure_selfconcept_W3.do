use "$wdata/J1_W3_Student.dta", clear

** Self Concept

misstable patterns cantsolve cantcontrol optimal satisfy useless nothing

local covlist = "cantsolve cantcontrol optimal satisfy useless nothing"

foreach x in `covlist'{
	local predictor = subinstr("`covlist'","`x'","",.)
	quiet reg `x' `predictor'
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

foreach x in nothing satisfy{
	quiet reg `x' cantsolve cantcontrol optimal useless
	quiet predict yhat
	quiet replace `x' = round(yhat) if `x' == .
	drop yhat
}

factor cantsolve cantcontrol optimal satisfy useless nothing, factor(1)
rotate, blank(0.5)
predict sel_concept
replace sel_concept = - sel_concept

** Education Expectation

recode expectedu (1 = 9)(2 = 12)(3 = 14)(4 = 16)(5 = 18)(6 = 22)(7/. = 9), gen(expecteduyr)  

rename hopeattendhs hopeattendhs_w3
rename sel_concept sel_concept_w3 
rename expecteduyr expecteduyr_w3

** Save

save "$wdata/J1_W3.dta", replace
