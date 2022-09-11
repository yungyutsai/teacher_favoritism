use "$wdata/J1_for_analysis.dta", clear

** Personality
factor 	tolerance responsibility selfcare friendly consideration harmony humble honest ///
		fun selfdecide share tradition anywhere spotlight freedom follower closefriend sociable joingroup consultelder appearance clever teamworker ownway ///
		filial clean polite obedience organized goodstudent goodbehave moderate frugal ///
		curious  imagination explorecause ///
		collegeimportant scoreimportant, factor(5)
rotate, blank(0.35)
matrix M = e(r_L)

alpha tolerance responsibility selfcare friendly consideration harmony humble honest
local alpha1 = r(alpha)
alpha fun selfdecide share tradition anywhere spotlight freedom follower closefriend sociable joingroup consultelder appearance clever teamworker ownway
local alpha2 = r(alpha)
alpha filial clean polite obedience organized goodstudent goodbehave moderate frugal
local alpha3 = r(alpha)
alpha curious  imagination explorecause
local alpha4 = r(alpha)
alpha collegeimportant scoreimportant
local alpha5 = r(alpha)

clear
set obs 43

gen item = ""
replace item = "Factor 1: Good Virtue" in 39
replace item = "Factor 2: Outgoing and Egocentric" in 40
replace item = "Factor 3: Obedience and Mannered" in 41
replace item = "Factor 4: Curious and Creative" in 42
replace item = "Factor 5: Motivated" in 43
replace item = "Be patient" in 1
replace item = "Responsible for self own work" in 2
replace item = "Able to take care of myself" in 3
replace item = "Be friendly to classmates, friends and other children" in 4
replace item = "Stand in other's shoes" in 5
replace item = "Get along in harmony with others" in 6
replace item = "Be humble" in 7
replace item = "Keep promises" in 8
replace item = "I like to tell jokes or funny stories" in 9
replace item = "I like to decide by myself what I want to do" in 10
replace item = "I like to share some things with my friends" in 11
replace item = "I am willing to do things in accordance with tradition, so that people I care about don’t think I’m unconventional" in 12
replace item = "I want to go wherever I love to go" in 13
replace item = "I like to be the spotlight of a group" in 14
replace item = "I like to be free, do whatever I like" in 15
replace item = "I like to follow instructions and do what others want me to do" in 16
replace item = "I like to be close with my friends" in 17
replace item = "I would rather do things with friends than do it alone" in 18
replace item = "I like to join a warm and friendly group" in 19
replace item = "When I make a plan, I hope to get some opinions from people I respect" in 20
replace item = "When I am in public, I like people to pay attention to my appearance" in 21
replace item = "I like to say things that others think are smart and witty" in 22
replace item = "When deciding on the actions of the group, I am willing to accept the leadership of others" in 23
replace item = "I like to do things my own way, regardless of what others think" in 24
replace item = "Respect and obey parents " in 25
replace item = "Keep clothes clean" in 26
replace item = "Be polite to adults" in 27
replace item = "Obey parents and teachers" in 28
replace item = "Keep things neat" in 29
replace item = "Be a good student" in 30
replace item = "Behave appropriately" in 31
replace item = "Do not be pushy" in 32
replace item = "Living frugal" in 33
replace item = "Curious about many things" in 34
replace item = "Imaginative" in 35
replace item = "Like to explore why things happen" in 36
replace item = "Attend college is important" in 37
replace item = "Work hard to get good grades is important" in 38

gen facload = .
forv i = 1(1)38{
	forv j = 1(1)5{
		replace facload = M[`i',`j'] if _n == `i' & abs(M[`i',`j']) > 0.3
	}
}

gen alpha = .
replace alpha = `alpha1' in 39
replace alpha = `alpha2' in 40
replace alpha = `alpha3' in 41
replace alpha = `alpha4' in 42
replace alpha = `alpha5' in 43

gen row = _n
recode row 39=0.5 40=8.5 41=24.5 42=33.5 43=36.5

sort row
drop row

format facload alpha %9.4f
export excel "$tables/TabA2.xlsx", replace
