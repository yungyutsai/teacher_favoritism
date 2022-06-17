use "$rdata/J1_W1_Student/j1w1s_May2014.dta", clear

gen wave = 1
lab var wave "Wave"
gen year = 2000
lab var year "Year"
gen grade = 7
lab var grade "Grade"

**New School id
gen location=aslo
tostring loc , replace
gen school=assc
tostring sch , replace
gen cohort=1
tostring cohort , replace
replace sch="0" + sch
replace sch=usubstr(sch,-2,2)
replace sch=loc+sch+cohort
destring sch , gen(schid)
drop location
rename aslo location
lab var schid "School ID"
lab var location "City of the junior high school"

**New Class id
gen classno = ascl
gen class=ascl
tostring class , replace
replace class="0" + class
replace class=usubstr(class,-2,2)
replace class=school+cohort+class
destring class , gen(claid)
destring cohort , replace
lab var cohort "Cohort"
lab var claid "Class ID"

**New Student id
gen stuid = id1 + 100000
lab var stuid "Student ID"

**Demographic
gen female = assex == 2
lab var female "Female"
gen birthyr = asbirth + 1911
lab var birthyr "Year of Birth"

**Family Background
gen falive = asfalive == 1
gen molive = asmalive == 1
lab var falive "Live with Father"
lab var molive "Live with Mother"

recode asfaedu 	(0 9 = 0 "missing or not applicable") (8 = 1 "illiterate") (1 = 2 "primary school") ///
				(2 = 3 "junior high school") (3 = 4 "senior high school") (4 = 5 "vocational school") ///
				(5 = 6 "some college") (6 = 7 "undergraduate") (7 = 8 "graduate"), gen(faedu_st) label(faedu_st)
recode asmaedu 	(0 9 = 0 "missing or not applicable") (8 = 1 "illiterate") (1 = 2 "primary school") ///
				(2 = 3 "junior high school") (3 = 4 "senior high school") (4 = 5 "vocational school") ///
				(5 = 6 "some college") (6 = 7 "undergraduate") (7 = 8 "graduate"), gen(moedu_st) label(moedu_st)
lab var faedu_st "Father's highest education level'"
lab var moedu_st "Mother's highest education level'"

gen famincome_st=asincome
recode famincome_st 0=. 1=15000 2=40000 3=55000 4=65000 5=75000 6=85000 7=95000 8=105000 9=115000 10=125000 11=135000 12=145000 13=155000 99=.
lab var famincome_st "Family average montly income (NTD)"

gen faisei_st=asfaocc
gen moisei_st=asmaocc
lab var faisei_st "Father's ISEI"
lab var moisei_st "Mother's ISEI"

*Recode ISEI
foreach x in "fa" "mo"{
	recode `x'isei_st ///
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

recode as105000 (1 = 1 "apartment") (2 4 5 = 2 "house") (3 = 3 "condominium") (6 9 = 4 "other"), gen(hometype) label(hometype)
lab var hometype "Type of residence place"

recode as111f00 (1 = 1 "holo") (2 = 2 "hakka") (3 = 3 "mainlander") (4 = 4 "aboriginal") (5 9 = 5 "other or missing"), gen(faethnic) label(faethnic)
recode as111m00 (1 = 1 "holo") (2 = 2 "hakka") (3 = 3 "mainlander") (4 = 4 "aboriginal") (5 9 = 5 "other or missing"), gen(moethnic) label(moethnic)
lab var faethnic "Father's Ethnic'"
lab var moethnic "Mother's Ethnic'"

gen parmarried = as112000 == 1
lab var parmarried "Parents are married"

gen sibling = 0
foreach x in a b c d e f{
	replace sibling = sibling + 1 if inrange(as115`x'01,1,4)
}
recode sibling 6 = 5
lab var sibling "Number of siblings"

** Attitude
gen filial = as123001
lab var filial "Filial is important"
gen clean = as123002
lab var clean "Keep clean is important"
gen polite = as123003
lab var polite "Be polite to elders is important"
gen obedience = as123004
lab var obedience "Obedience to parents and teachers is important"
gen organized = as123005
lab var organized "Keep items organized is important"
gen goodstudent = as123006
lab var goodstudent "Be good student is important"
gen goodbehave = as123007
lab var goodbehave "Have good behave is important"
gen moderate = as123008
lab var moderate "Keep moderate is important"
gen frugal = as123009
lab var frugal "Frugal is important"
gen tolerance = as123010
lab var tolerance "Be tolerance is important"
gen curious = as123011
lab var curious "Keep curious is important"
gen responsibility = as123012
lab var responsibility "Responsibility is important"
gen imagination = as123013
lab var imagination "Imagination is important"
gen selfcare = as123014
lab var selfcare "Take care of myself is important"
gen explorecause = as123015
lab var explorecause "Explore cause of things is important"
gen friendly = as123016
lab var friendly "Be friendly is important"
gen consideration = as123017
lab var consideration "Consideration is important"
gen harmony = as123018
lab var harmony "Maintain harmony is important"
gen humble = as123019
lab var humble "Be humble is important"
gen honest = as123020
lab var honest "Be honest is important"

foreach x of varlist filial-honest{
	recode `x' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (9 = .)
	lab de `x' 4 "very important" 3 "important" 2 "not important" 1 "very not important"
	lab val `x' `x'
}

gen collegeimportant = as241b01
lab var collegeimportant "Attend college is important"
gen scoreimportant = as241b03
lab var scoreimportant "Get good grade is important"

foreach x of varlist collegeimportant-scoreimportant{
	recode `x' (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1) (9 = .)
	lab de `x' 5 "very important" 4 "important" 3 "somewhat important" 2 "not important" 1 "very not important"
	lab val `x' `x'
}

gen likeschool = as218001
lab var likeschool "I like the school"
gen likesubject = as205000
lab var likesubject "How much testing subjects do you like?"

foreach x of varlist likeschool{
	recode `x' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (9 = .)
	lab de `x' 4 "very like" 3 "like" 2 "dislike" 1 "very dislike"
	lab val `x' `x'
}
foreach x of varlist likesubject{
	recode `x' (1 = 0) (2 = 1) (3 = 2) (4 = 3) (9 = .)
	lab val `x' `x'
}

** Personality
gen fun = as308001
lab var fun "I like to tell joke or funny story"
gen selfdecide = as308002
lab var selfdecide "I like to decide what to do on my own"
gen share = as308003
lab var share "I like to share with friends"
gen tradition = as308004
lab var tradition "I like to follow the tradition"
gen anywhere = as308005
lab var anywhere "I like to go to anywhere I want"
gen spotlight = as308006
lab var spotlight "I like to become spotlight"
gen freedom = as308007
lab var freedom "I value freedom"
gen follower = as308008
lab var follower "I like to follow directions"
gen closefriend = as308009
lab var closefriend "I like to be close with friends"
gen sociable = as308010
lab var sociable "I like to do things with friends"
gen joingroup = as308011
lab var joingroup "I like to join a warm group"
gen consultelder = as308012
lab var consultelder "I like to consult with elders when doing project"
gen appearance = as308013
lab var appearance "I like people to care about appearance"
gen clever = as308014
lab var clever "I like peform in clever ways"
gen teamworker = as308015
lab var teamworker "I like to be led by others"
gen ownway = as308016
lab var ownway "I like perform in my ownway"

foreach x of varlist fun-ownway{
	recode `x' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (9 = .)
	lab de `x' 4 "very agree" 3 "agree" 2 "disagree" 1 "very disagree"
	lab val `x' `x'
}

** Behave
gen liegrade = as124000 == 1
lab var liegrade "Ever report grade unhonestly to parents"
gen cheat = as125000 == 1
lab var cheat "Ever cheat on exam"
recode as215000 1 = 30 2 = 20 3 = 10 4 = 7 5 = 5 6 = 3 7 = 2 8 = 1 9 = 0 99 = 0, gen(absence)
lab var absence "Days of absence last month"

gen runaway = inrange(as243a01,2,5)
lab var runaway "Ever runaway from home"
gen skipclass = inrange(as243a02,2,5)
lab var skipclass "Ever skip class"
gen sabotage = inrange(as243a03,2,5)
lab var sabotage "Ever breaks others' items"
gen steal = inrange(as243a04,2,5)
lab var steal "Ever steal things from others"
gen hurt = inrange(as243a06,2,5) | inrange(as243a07,2,5)
lab var hurt "Ever hurt or exaction others"
gen smokedrink = inrange(as243a08,2,5)
lab var smokedrink "Ever smoke or drink"
gen betelnut = inrange(as243a09,2,5)
lab var betelnut "Ever chewing betel nut"
gen drug = inrange(as243a10,2,5)
lab var drug "Ever take drug"

** Learning Behavior
gen cramschool = as228000 == 1
lab var cramschool "Ever go to cramschool this semester"
gen studyhour = as306000/10
recode studyhour 99.9 = .
lab var studyhour "Averge time of study per day (hours)"
recode as237002 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(studyhard) label(studyhard)
lab var studyhard "I study hard because teacher will parise hardworking student"

** Attitude toward Teacher
gen teacherlike = as201000 - 1
lab var teacherlike "Number of teacher like me"
gen teacherhate = as202000 - 1
lab var teacherhate "Number of teacher hate me"
gen liketeacher = as203000 - 1
lab var liketeacher "Number of teacher I like"
gen hateteacher = as204000 - 1
lab var hateteacher "Number of teacher I hate"

foreach x of varlist teacherlike-hateteacher{
	recode `x' 8 = .
}

recode as221000 (1 = 4 "always") (2 = 3 "usually") (3 = 2 "sometime") (4 = 1 "never") (9 = .), gen(teapartiality) label(teapartiality)
lab var teapartiality "Teacher treat student with high achievement beter"
recode as222000 (1 = 1 "very fair") (2= 2 "fair") (3 = 3 "unfair") (4 = 4 "very unfair") (9 = .), gen(teacherunfair) labe(teacherunfair)
lab var teacherunfair "Teacher's unevenly treatment is unfair'"
recode as236006 (1 = 4 "very agree") (2 = 3 "agree") (3 = 2 "disagree") (4 = 1 "very disagree") (9 = .), gen(teacherjustice) label(teacherjustice)
lab var teacherjustice "Teacher's reward and punishment is just'"

** Academic Achievement
recode as213000 (1 = 5 "improve a lot") (2 = 4 "improve a little") (3 = 3 "no difference") (4 = 2 "get worse a little") (5 = 1 "get worse a lot") (9 = .), gen(gradechange) label(gradechange)
lab var gradechange "Grade change compared to prmary school"

gen classrank_primary = as207000
lab var classrank_primary "Class rank at primary school"
gen classrank_st = as231000
lab var classrank_st "Class rank (student report)"

foreach x of varlist classrank_primary-classrank_st{
	recode `x' (1 = 5) (2 = 4) (3 = 3) (4 = 2) (5 = 1) (9 = .)
	lab de `x' 5 "top 5" 4 "6 - 10" 3 "11 - 20" 2 "21 - 30" 1 "31 -"
	lab val `x' `x'
}

** Non-academic Achievement
gen cadre = as216001 == 1
lab var cadre "Ever serve as class cadre"
gen competition = 0
forv i = 1(1)6{
	replace competition = 1 if as217a0`i' == 1
}
lab var competition "Ever participate in competition represented for class or school"

** Aspiration / Self-concept
recode as232000 (1 = 1 "attend senior high school") (2/4 = 2 "attend vocational school") (7 = 3 "study abord") (5/6 = 4 "not continue study") (8/9 = 5 "unsure/other"), gen(graduationgoal) label(graduationgoal)
lab var graduationgoal "Goal upon graduate from senior high school"

recode as233000 (1 = 1 "junior high school") (2 = 2 "senior high school") (3 = 3 "some college") (4 = 4 "undergraduate") (5 = 5 "master") (6 = 6 "doctoral") (7/9 = .), gen(expectedu) label(expectedu)
lab var expectedu "Expect highest education level given current ability and enviroment"

recode as234000 (1 = 1 "junior high school") (2 = 2 "senior high school") (3 = 3 "some college") (4 = 4 "undergraduate") (5 = 5 "master") (6 = 6 "doctoral") (7/9 = .), gen(hopeedu) label(hopeedu)
lab var hopeedu "Hope highest education level regardless current ability and enviroment"

gen attendhs = as104b00 == 4
lab var attendhs "Planning to attend highschool after graduation"

gen cantsolve = as301001
lab var cantsolve "I cannot solve my problem"
gen cantcontrol = as301002
lab var cantcontrol "I cannot control things happen on me"
gen powerless = as301003
lab var powerless "I feel powerless"

gen valuable = as301004
lab var valuable "I am aa valuable/useful person"
gen noproud = as301005
lab var noproud "I do not have things to be proud of"
gen optimal = as301006
lab var optimal "I take optimal attitude on myself"
gen satisfy = as301007
lab var satisfy "I am satisfy with myself"
gen useless = as301008
lab var useless "I feel I am useless"
gen nothing = as301009
lab var nothing "I feel I am nothing"

foreach x of varlist cantsolve-nothing{
	recode `x' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (9 = .)
	lab de `x' 4 "very agree" 3 "agree" 2 "disagree" 1 "very disagree"
	lab val `x' `x'

}

gen clasize = as323000
lab var clasize "Class size"

** Organize

drop id id1 school class as*

order wave year cohort location schid claid stuid

save "$wdata/J1_W1_Student.dta", replace

keep classno claid schid
duplicates drop
save "$wdata/J1_W1_Claid_Schid.dta", replace
