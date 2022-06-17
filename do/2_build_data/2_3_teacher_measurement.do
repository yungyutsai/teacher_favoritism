use "$wdata/J1_W1_favoritism.dta", clear
keep teaid
duplicates drop

merge 1:1 teaid using "$wdata/J1_W1_Teacher_b.dta"
keep if _m == 3
drop _m

reg teapunattitude teapunorder teapunbehave teastrict tealove teacarving teafemale teaage teanorm teagraduate i.teasubject teamarried teachildren teaexp
predict yhat
replace teapunattitude = round(yhat,1) if teapunattitude == .
drop yhat

factor teapunattitude teapunorder teapunbehave teastrict tealove teacarving teaduty teavolunteer, factor(3)
rotate, blank(0.3)

predict tea_punishment tea_strict tea_responsibility

save "$wdata/J1_W1_Teacher.dta", replace
