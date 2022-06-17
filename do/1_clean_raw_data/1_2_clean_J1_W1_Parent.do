use "$rdata/J1_W1_Parent/j1w1p_Jul2008.dta", clear

**New Student id
gen stuid = id1 + 100000

**Demographic
gen famincome_pa = apincome * 1000
recode famincome_pa 999000 = .

gen moedu_pa = apedu if aprel == 1
gen faedu_pa = apedu if aprel == 2
replace moedu_pa = apcedu if aprel == 2
replace faedu_pa = apcedu if aprel == 1

gen moisei_pa = apocc if aprel == 1
gen faisei_pa = apocc if aprel == 2
replace moisei_pa = apcocc if aprel == 2
replace faisei_pa = apcocc if aprel == 1

**Recode ISEI
foreach x in "fa" "mo"{
	recode `x'isei_pa ///
	1/6=0		10=65.12 	11=71.72 	12=72.94 	13=65.25 	14=51.01 ///
	19=65.12 	20=76.24 	21=79.49 	22=76.98 	23=75.54 	24=73.91 ///
	25=75.13 	26=75.67 	29=76.24 	30=56.03 	31=52.40 	32=55.40 ///
	33=57.64 	34=52.57 	35=60.93 	36/39=56.03 40=43.51 	41=43.33 ///
	42=41.22 	43=44.08 	44=42.30 	50=29.32 	51=27.57 	52=29.73 ///
	53=25.09 	54=36.86 	60=19.20 	61=19.41 	62=18.29 	63=11.01 ///
	70=28.53 	71=25.39 	72=29.81 	73=31 		74=37.34 	75=23.97 ///
	80=25.45 	81=23.41 	82=24.93 	83=26.80 	84/89=25.45 90=16.50 ///
	91=14.64 	92=11.87 	93=17.53 	94=16.50 	95=23.43 	96=24.07 ///
	98=16.50 	0=0  		99=0
}

**Expectation & Evaluation
gen attendhs_pa = ap137000 == 4

recode ap138000 (1 = 1 "junior high school") (2 = 2 "senior high school") (3 = 3 "some college") (4 = 4 "undergraduate") (5 = 5 "master") (6 = 6 "doctoral") (7/9 = .), gen(expectedu_pa) label(expectedu_pa)
lab var expectedu_pa "Expect least education level"

recode ap107001 (1 = 6 "very satisfy") (2 = 5 "satisfy") (3 = 4 "somewhat satisfy") (4 = 3 "somewhat not satisfy") (5 = 2 "not satisfy") (6 = 1 "very not satisfy") (7/9 = .), gen(satisifyacademic_pa) label(satisifyacademic_pa)
lab var satisifyacademic_pa "Satisfication of Academical Performance"

recode ap107002 (1 = 6 "very satisfy") (2 = 5 "satisfy") (3 = 4 "somewhat satisfy") (4 = 3 "somewhat not satisfy") (5 = 2 "not satisfy") (6 = 1 "very not satisfy") (7/9 = .), gen(satisifybehave_pa) label(satisifybehave_pa)
lab var satisifybehave_pa "Satisfication of Behave Performance"

recode ap133000 (1 = 5 "very good") (2 = 4 "good")(3 = 3 "usual")(4 = 2 "bad")(5 = 1 "very bad")(6/9 = .), gen(overallperform_pa) label(overallperform_pa)
lab var overallperform_pa "Overall Performance at School as a Student"

recode ap106a01 (1 = 5 "never") (2 = 4 "few")(3 = 3 "sometime")(4 = 2 "usual")(5 = 1 "always")(6/9 = .), gen(study_pa) label(study_pa)
lab var study_pa "Have different opinion on study hard with children"

** Organization
drop id id1 ap*

order stuid

save "$wdata/J1_W1_Parent.dta", replace
