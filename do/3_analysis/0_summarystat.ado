*! version 1.4 Yung-Yu Tsai (ytsai@mail.missouri.edu)

* v1.4 Allow for variable list
* v1.3 
*------ Allow for fast option (use gcollapse() function)
*------ Allow multiple and interaction by() option
*------ Calculate both raw sample size and population size for svy:, iweight, pweight, and fweight
* v1.2 Add panel option
* v1.1 Allow svy prefix and iweight/pweight for sd and se
* v1.0 Basic function

capture program drop summarystat
program define summarystat

	syntax anything(everything) [if] [in] [aweight fweight pweight iweight] ///
	[, by(string) all cw lw STats(string) obs(string) long wide Format(string) dec(integer -1) LABel(string) NOLabel PARen(string) NOPAren BRacket(string) NOBRacket TItle(string) PANel(string asis) note(string asis) NONote save(string) sheet(string asis) replace SHEETREPlace sep(string) SEEout NOREStore GCollapse]
	quiet {
	set more off
	if ("`norestore'"=="") preserve
	
	*** Set default values
	if ("`wide'"==""&"`by'"!="") loc long = 1 //default as long, when by is specified
	if ("`long'"==""&"`by'"=="") loc long = 0 //default as wide, when by is not specified
	if ("`wide'"=="wide") loc long = 0
	if ("`long'"=="long") loc long = 1
	if ("`format'"==""&`dec'==-1) loc format = "%9.3f" //default as %9.3f
	if ("`format'"==""&`dec'!=-1) loc format = "%9.`dec'f" //default as %9.#f
	if (strpos("`label'","var")!=0) loc labelvar = 1
	if (strpos("`label'","var")==0) loc labelvar = 0
	if (strpos("`label'","val")!=0) loc labelval = 1
	if (strpos("`label'","val")==0) loc labelval = 0
	if "`label'"=="on"|"`label'"=="" {
		loc labelvar = 1 //default = use variable label
		loc labelval = 1 //default = use value label
	} 
	if "`label'"=="off"|"`nolabel'"!="" {
		loc labelvar = 0
		loc labelval = 0
	}
	if "`lw'"=="lw" loc cw = "cw"
	loc numbys = 0
	
	*** Check for necessay package
	if "`gcollapse'"=="gcollapse" {
		cap which gcollapse
		if _rc!=0{
			di as error "the option {bf:gcollapse} required {search gcollapse} installed"
			error 133
			exit
		}
	}
	
	*** Check for svy prefix
	loc svy = 0
	if strpos("`anything'","svy:")!=0{
		loc svy = 1
		loc prefix = "svy: "
	}
	if `svy' == 1 {
		svyset
		if "`r(settings)'"==", clear"{
			di as error "data not set up for svy, use {help svyset}"
			error 119
			exit
		}
	}
	loc anything = subinstr("`anything'","svy:","",.)
	if (`svy' == 1 & "`weight'"!=""){
		di as error "weights not allowed with the {bf:svy} prefix;"
		di as error "the {bf:svy} prefix assumes survey weights were already specified using {bf:svyset}"
		error 101
		exit
	}
	if `svy' == 1 & strpos("`stats'","seb")!=0 {
		di as error "{bf:svy:} not allowed with {bf:sebinomial}"
		error 135
		exit
	}
	if `svy' == 1 & strpos("`stats'","sep")!=0 {
		di as error "{bf:svy:} not allowed with {bf:sepoisson}"
		error 135
		exit
	}
	
	*** Checke for error
	** Table shape
	if("`long'"=="long" & "`wide'"=="wide"){
		di as error "cannot specify both {bf:long} and {bf:wide}."
		error 198
		exit
	}
	** Label
	loc labinvalid = "`label'"
	foreach x in "on" "off" "varible" "varibl" "varib" "vari" "var" "value" "valu" "val" " "{
		loc labinvalid = subinstr("`labinvalid'","`x'","",.)
	}
	if("`labinvalid'"!=""){
		di as error "label() options only allows for {bf:on}, {bf:off}, {bf:variable}, and , {bf:value}."
		error 198
		exit
	}
	if(strpos("`label'","on")!=0 & "`nolabel'"!=""){
		di as error "cannot specify both {bf:label(on)} and {bf:nolabel}."
		error 198
		exit
	}
	if(strpos("`label'","on")!=0 & strpos("`label'","off")!=0){
		di as error "cannot specify both {bf:label(on)} and {bf:label(off)}."
		error 198
		exit
	}
	if(strpos("`label'","var")!=0 & strpos("`label'","off")!=0){
		di as error "cannot specify both {bf:label(varible)} and {bf:label(off)}."
		error 198
		exit
	}
	if(strpos("`label'","val")!=0 & strpos("`label'","off")!=0){
		di as error "cannot specify both {bf:label(value)} and {bf:label(off)}."
		error 198
		exit
	}
	** Note
	if(`"`note'"'!="" & "`nonote'"=="nonote"){
		di as error "WARNING: both {bf:note()} and {bf:nonote} are specified. {bf:nonote} suppressed {bf:note()}."
	}
	if(strrpos(`"`note'"',",")!=0){
		loc noteoption = substr(`"`note'"',strrpos(`"`note'"',",")+1,.)
		if strpos(`"`noteoption'"',`"""')==0{
			if (strpos(`"`noteoption'"',"add")!=0) loc addnote = 1
			if (strpos(`"`noteoption'"',"pre")!=0) loc prenote = 1
			if (strpos(`"`noteoption'"',"rep")!=0) loc repnote = 1
			
			if (strpos(`"`noteoption'"',"add")!=0) & (strpos(`"`noteoption'"',"pre")!=0){
				di as error "cannot sepcify both {bf:note(,add)} and {bf:note(,prefix)}"
				error 198
				exit
			}
			if (strpos(`"`noteoption'"',"add")!=0) & (strpos(`"`noteoption'"',"rep")!=0){
				di as error "Warning: both {bf:note(,add)} and {bf:note(,replace)} are specified. {bf:replace} surpressed {bf:add}."
			}
			if (strpos(`"`noteoption'"',"pre")!=0) & (strpos(`"`noteoption'"',"rep")!=0){
				di as error "Warning: both {bf:note(,prefix)} and {bf:note(,replace)} are specified. {bf:replace} surpressed {bf:add}."
			}
			
			loc note = substr(`"`note'"',1,strrpos(`"`note'"',",")-1)
			loc noteoption = subinstr(`"`noteoption'"',"replace","",.)
			loc noteoption = subinstr(`"`noteoption'"',"replac","",.)
			loc noteoption = subinstr(`"`noteoption'"',"repla","",.)
			loc noteoption = subinstr(`"`noteoption'"',"repl","",.)
			loc noteoption = subinstr(`"`noteoption'"',"rep","",.)
			loc noteoption = subinstr(`"`noteoption'"',"prefix","",.)
			loc noteoption = subinstr(`"`noteoption'"',"prefi","",.)
			loc noteoption = subinstr(`"`noteoption'"',"pref","",.)
			loc noteoption = subinstr(`"`noteoption'"',"pre","",.)
			loc noteoption = subinstr(`"`noteoption'"',"add","",.)
			loc noteoption = subinstr(`"`noteoption'"'," ","",.)
			if `"`noteoption'"'!="" {
				di as error "invalid {bf:note()} option"
				di as error "only allow for {bf:add}, {bf:prefix}, or {bf:replace}"
				error 198
				exit
			}
		}
	}
	** Obs.
	loc obsinvalid = "`obs'"
	foreach x in "top" "bottom" "title" "note" "nopop" "noraw" " " {
		loc obsinvalid = subinstr("`obsinvalid'","`x'","",.)
	}
	if ("`obsinvalid'"!=""){
		di as error "subcommand(s) in {bf:obs()} invalid, the allowed options are: {bf:top}, {bf:bottom}, {bf:title}, {bf:note}, {bf:nopop}, and {bf:noraw}."
		error 198
		exit
	}
	if (strpos("`obs'","title")!=0 & "`title'"==""){
		di as error "{bf:obs(title)} is only allowed when {bf:title()} is specified."
		error 198
		exit
	}
	if (strpos("`obs'","note")!=0 & "`nonote'"=="nonote"){
		di as error "WARNING: both {bf:obs(note)} and {bf:nonote} are specified. {bf:nonote} suppressed {bf:obs(note)}."
	}
	if (strpos("`obs'","nopop")!=0 & `svy'==0 & ("`weight'"=="aweight" | "`weight'"=="") ){
		di as error "WARNING: neither {bf:svy:}, {bf:iweight}, {bf:pweight}, nor {bf:fweight} specified. {bf:obs(nopop)} ignored."
	}
	** Weight
	if ("`weight'"=="iweight" | "`weight'"=="pweight" | "`weight'"=="aweight") & (strpos("`stats'","seb")!=0 | strpos("`stats'","sep")!=0){
		di as error "{bf:`weight'} not allowed with {bf:sebinomial} and {bf:sepoisson}"
		error 135
		exit
	}
	if ("`weight'"!=""){
		loc var = subinstr("`exp'","=","",.)
		cap confirm numeric variable `var'
		if _rc!=0 {
			cap confirm number `var'
			if _rc!=0 {
				di as error "`var' specified in weight is not a numeric variable or number."
				error 109
				exit
			}
		}
		cap sum `var'
		if r(min)<0 {
			error 402
			exit
		}
		cap confirm number `var'
		if _rc==0 {
			if `var' < 0 {
				error 402
				exit
			}
		}
	}
	** Variables
	loc vars = subinstr("`anything'","(","",.)
	loc vars = subinstr("`vars'",")","",.)
	tokenize "`vars'" //Break down variables in to tokens
	loc numvars = wordcount("`vars'")
	loc i = 1
	forv j = 1(1)`numvars'{
		if (strpos("``j''","-")!=0|strpos("``j''","*")!=0|strpos("``j''","?")!=0|strpos("``j''","~")!=0){
			foreach x of varlist ``j''{
				loc var`i' = "`x'"
				confirm variable `x'
				loc i = `i' + 1
			}
		}
		else{
			loc var`i' = "``j''"
			loc var = subinstr("`var`i''","i.","",.)
			confirm variable `var'
			loc i = `i' + 1
		}
	}
	loc numvars = `i' - 1
	if "`by'"!=""{
		if strpos("`by'","#")!=0{
			loc byinteract = 1
			loc numbys = 2
			loc by = subinstr("`by'","##","#",.)
			loc invalid = substr("`by'",strpos("`by'","#")+1,.)
			if strpos("`invalid'","#")!=0{
				di as error "{bf:by()} option only allows for at most one interaction term"
				error 198
				exit
			}
			else{
				loc by1 = substr("`by'",1,strpos("`by'","#")-1)
				loc by2 = substr("`by'",strpos("`by'","#")+1,.)
				forv i = 1(1)2{
					confirm variable `by`i''
				}
			}
		}
		if strpos("`by'","#")==0{
			tokenize "`by'" 
			loc numbys = wordcount("`by'")
			loc i = 1
			forv j = 1(1)`numbys'{
				if (strpos("``j''","-")!=0|strpos("``j''","*")!=0|strpos("``j''","?")!=0|strpos("``j''","~")!=0){
					foreach x of varlist ``j''{
						loc by`i' = "`x'"
						confirm variable `x'
						loc i = `i' + 1
					}
				}
				else{
					loc by`i' = "``j''"
					confirm variable `by`i''
					loc i = `i' + 1
				}
			}
			loc numbys = `i' - 1
		}
	}
	* Delete duplicated variables
	local warning = 0
	local nexttolast = `numvars' - 1
	forv i = 1(1)`nexttolast'{
		local j = `i' + 1
		forv k = `j'(1)`numvars'{
			if ("`var`k''"=="`var`i''"){
				loc var`k' = ""
				loc warning = 1
			} 
		}
	}
	if (`warning' == 1) dis in red "WARNING: repeated variables specified. Only use the first one."
	loc vars = ""
	
	forv i = 1(1)`numvars'{
		cap confirm str# variable `var`i'' //check whether is string variable
		if _rc==0 {
			dis in red "WARNING: `var`i'' is a string variable. Treated as a factor variable. If you want to use it as numeric variable, use {help destring} to transform it into numeric."
			local var`i' = "i.`var`i''"
		}
		if (strpos("`var`i''","i.")!=0) {
			loc var`i' = subinstr("`var`i''","i.","",.)
			loc varlab: variable label `var`i''
			if ("`varlab'"=="") loc varlab = "`var`i'': "
			else loc varlab = ""
			if (`labelval'== 0) cap lab val `var`i'' .
			tab `var`i'', gen(_`var`i''_) //create dummies for factor variable
			loc numcats = r(r) //number of categories
			forv j = 1(1)`numcats'{
				cap replace _`var`i''_`j' = . if `var`i'' == .
				cap replace _`var`i''_`j' = . if `var`i'' == ""
				local lab: variable label _`var`i''_`j'
				local lab = subinstr("`lab'","`var`i''==","",.) //simplize the label
				cap dis `lab'
				if (_rc == 0){ //adjust format for numeric label
					loc lab: dis %15.3g `lab' 
					loc lab = subinstr("`lab'"," ","",.)
				}
				if (`labelvar'== 1) lab var _`var`i''_`j' "`varlab'`lab'"
				if (`labelvar'== 0 | "`lab'"=="") lab var _`var`i''_`j' "`var`i'': `lab'"
			}
			loc dummylist = ""
			forv j = 1(1)`numcats'{ //use new generated dummies to replace original variable
				if ("`dummylist'"!="") loc dummylist = "`dummylist' _`var`i''_`j'"
				else if ("`dummylist'"=="") loc dummylist = "_`var`i''_`j'"
			}
			loc anything = subinstr("`anything'","i.`var`i'' ","`dummylist' ",.)
			loc anything = subinstr("`anything'","i.`var`i'')","`dummylist')",.)
			loc anything = subinstr("`anything'","i.`var`i'',","`dummylist',",.)
			loc anything = subinstr("`anything'","`var`i'' ","`dummylist' ",.)
			loc anything = subinstr("`anything'","`var`i'')","`dummylist')",.)
			loc anything = subinstr("`anything'","`var`i'',","`dummylist',",.)
			loc var`i' = "`dummylist'"
		}
		if ("`var`i''"!=""&"`vars'"=="") loc vars = "`var`i''"
		else if ("`var`i''"!=""&"`vars'"!="") loc vars = "`vars' `var`i''"
	}

	tokenize "`vars'" //Break down variables in to tokens again
	loc numvars = wordcount("`vars'")
	forv i = 1(1)`numvars'{
		loc var`i' = "``i''"
		if (`labelvar'==1) loc varlab`i': variable label `var`i'' //use label as default
		if (`labelvar'==0 | "`varlab`i''"=="") loc varlab`i' = "`var`i''" //use var name if specified varname option or if lable is missing
		if (substr("`var`i''",1,1)=="_") loc varlab`i': variable label `var`i'' //foreced using label for factor variables
	}
	** Panel
	loc noleftpar = subinstr("`anything'","(","",.)
	loc norightpar = subinstr("`anything'",")","",.)
	loc numleftpars = length("`anything'") - length("`noleftpar'")
	loc numrightpars = length("`anything'") - length("`norightpar'")
	if (`numleftpars'==`numrightpars') loc numpanels = `numleftpars'
	if `numpanels'!=0{
		loc panelstring = "`anything'"
		forv i = 1(1)`numpanels'{
			loc leftparpos = strpos("`panelstring'","(")
			loc rightparpos = strpos("`panelstring'",")")
			loc before = substr("`panelstring'",1,`leftparpos'-1) //variables before the panel
			loc middle = substr("`panelstring'",`leftparpos'+1,`rightparpos'-`leftparpos'-1) //variables within the panel
			loc after = substr("`panelstring'",`rightparpos'+1,.) //variables after the panel
			loc numvarsbefore = wordcount("`before'") //num of vars before the panel
			loc numvarsmiddle = wordcount("`middle'") //num of vars after the panel
			loc panel`i'start = `numvarsbefore' + 1
			loc panel`i'end = `numvarsbefore' + `numvarsmiddle'
			loc panelstring = "`before'" + "`middle'" + "`after'" //a new string that deletes the parentheses that have been addressed
		}
	}
	* Panel titles
	if `"`panel'"' != "" {
		if strpos(`"`panel'"',`"""')==0{
			if strrpos(`"`panel'"',",")!=0{
				loc paneloption = substr(`"`panel'"',strrpos(`"`panel'"',",")+1,.)
				loc panel = substr(`"`panel'"',1,strrpos(`"`panel'"',",")-1)
				if strpos("`paneloption'","noalp")==0 & strrpos("`paneloption'","alp")!=0 & strpos("`paneloption'","num")!=0{
					di as error "cannot specify both {bf:alphabet} and {bf:number} in {bf:panel()}."
					error 198
					exit
				}
				if strpos("`paneloption'","noalp")!=0{
					loc invalid = subinstr("`paneloption'","noalp","",.)	
					if strpos("`invalid'","alp")!=0 {
						di as error "cannot specify both {bf:alphabet} and {bf:noalphabet} in {bf:panel()}."
						error 198
						exit
					}
				}
				loc invalid = "`paneloption'"
				loc invalid = subinstr("`invalid'","noalphabet","",.)
				loc invalid = subinstr("`invalid'","noalphabe","",.)
				loc invalid = subinstr("`invalid'","noalphab","",.)
				loc invalid = subinstr("`invalid'","noalpha","",.)
				loc invalid = subinstr("`invalid'","noalph","",.)
				loc invalid = subinstr("`invalid'","noalp","",.)
				loc invalid = subinstr("`invalid'","alphabet","",.)
				loc invalid = subinstr("`invalid'","alphabe","",.)
				loc invalid = subinstr("`invalid'","alphab","",.)
				loc invalid = subinstr("`invalid'","alpha","",.)
				loc invalid = subinstr("`invalid'","alph","",.)
				loc invalid = subinstr("`invalid'","alp","",.)
				loc invalid = subinstr("`invalid'","number","",.)
				loc invalid = subinstr("`invalid'","numbe","",.)
				loc invalid = subinstr("`invalid'","numb","",.)
				loc invalid = subinstr("`invalid'","num","",.)
				loc invalid = subinstr("`invalid'"," ","",.)
				if ("`invalid'"!=""){
					di as error "subcommand(s) in {bf:panel()} invalid, the allowed options are: {bf:alphabet}, {bf:number}, and {bf:noalphabet}."
					error 198
					exit
				}
			}	
			tokenize "`panel'"
			loc numpaneltitles = wordcount("`panel'")
			forv i = 1(1)`numpaneltitles'{
				loc paneltitle`i' = "``i''"
			}
			if `numpaneltitles' > `numpanels'{
				di as error "WARNING: the number of titles listed in {bf:panel()} is more than the number of panels specified in the variables list. Extra title(s) ignored."
			}
			if `numpaneltitles' < `numpanels'{
				di as error "WARNING: the number of titles listed in {bf:panel()} is fewer than the number of panels specified in the variables list. Assumed non-specified panel title(s) as blank."
			}
		}
		loc warning = 0
		
		if strpos(`"`panel'"',`"""')!=0{
			if strrpos(`"`panel'"',",")!=0{
				loc paneloption = substr(`"`panel'"',strrpos(`"`panel'"',",")+1,.)
				if (strpos("`paneloption'",`"""')==0) loc paneloption = 1
			}
			if "`paneloption'" == "1"{
				loc paneloption = substr(`"`panel'"',strrpos(`"`panel'"',",")+1,.)
				loc panel = substr(`"`panel'"',1,strrpos(`"`panel'"',",")-1)
				if strpos("`paneloption'","noalp")==0 & strpos("`paneloption'","alp")!=0 & strpos("`paneloption'","num")!=0{
					di as error "cannot specify both {bf:alphabet} and {bf:number} in {bf:panel()}."
					error 198
					exit
				}
				if strpos("`paneloption'","noalp")!=0{
					loc invalid = subinstr("`paneloption'","noalp","",.)	
					if strpos("`invalid'","alp")!=0 {
						di as error "cannot specify both {bf:alphabet} and {bf:noalphabet} in {bf:panel()}."
						error 198
						exit
					}
				}
				loc invalid = "`paneloption'"
				loc invalid = subinstr("`invalid'","noalphabet","",.)
				loc invalid = subinstr("`invalid'","noalphabe","",.)
				loc invalid = subinstr("`invalid'","noalphab","",.)
				loc invalid = subinstr("`invalid'","noalpha","",.)
				loc invalid = subinstr("`invalid'","noalph","",.)
				loc invalid = subinstr("`invalid'","noalp","",.)
				loc invalid = subinstr("`invalid'","alphabet","",.)
				loc invalid = subinstr("`invalid'","alphabe","",.)
				loc invalid = subinstr("`invalid'","alphab","",.)
				loc invalid = subinstr("`invalid'","alpha","",.)
				loc invalid = subinstr("`invalid'","alph","",.)
				loc invalid = subinstr("`invalid'","alp","",.)
				loc invalid = subinstr("`invalid'","number","",.)
				loc invalid = subinstr("`invalid'","numbe","",.)
				loc invalid = subinstr("`invalid'","numb","",.)
				loc invalid = subinstr("`invalid'","num","",.)
				loc invalid = subinstr("`invalid'"," ","",.)
				if ("`invalid'"!=""){
					di as error "subcommand(s) in {bf:panel()} invalid, the allowed options are: {bf:alphabet}, {bf:number}, and {bf:noalphabet}."
					error 198
					exit
				}
			}
			
			loc anypaneltitle = 0
			forv i = 1(1)`numpanels'{
				loc stop = 0
				while `stop' == 0{
					loc firstcharc = substr(`"`panel'"',1,1)
					if `"`firstcharc'"' == "" & `warning' == 0{
						di as error "WARNING: the number of titles listed in {bf:panel()} is fewer than the number of panels specified in the variables list. Assumed non-specified panel title(s) as blank."
						loc warning = 1
					}
					if `"`firstcharc'"' == " "{
						loc panel = substr(`"`panel'"',2,.)
					}
					else if `"`firstcharc'"' == `"""'{
						loc panel = substr(`"`panel'"',2,.)
						loc paneltitle`i'end = strpos(`"`panel'"',`"""')
						loc paneltitle`i' = substr(`"`panel'"',1,`paneltitle`i'end'-1)
						loc panel = substr(`"`panel'"',`paneltitle`i'end'+1,.)
						loc stop = 1
						loc anypaneltitle = 1
					}
					else {
						loc paneltitle`i'end = strpos(`"`panel'"'," ")
						if (`paneltitle`i'end' != 0) loc paneltitle`i' = substr(`"`panel'"',1,`paneltitle`i'end'-1)
						else if (`paneltitle`i'end' == 0) loc paneltitle`i' = substr(`"`panel'"',1,.)
						loc panel = substr(`"`panel'"',`paneltitle`i'end'+1,.)
						if (`paneltitle`i'end' == 0) loc panel = ""
						loc stop = 1
						loc anypaneltitle = 1
					}
				}
			}
			loc panel = subinstr(`"`panel'"'," ","",.)
			if `"`panel'"' != ""{
						di as error "WARNING: the number of titles listed in {bf:panel()} is more than the number of panels specified in the variables list. Extra title(s) ignored."
			} 
		}
	}
	if ((`"`panel'"'=="" & "`anypaneltitle'"!="1") & strpos("`paneloption'","noalp")==0) loc panelalp = 1
	if "`paneloption'"!=""{
		if (strpos("`paneloption'","alp")!=0) loc panelalp = 1
		if (strpos("`paneloption'","num")!=0) loc panelnum = 1
		if (strpos("`paneloption'","noalp")!=0) loc panelalp = 0
	}
	
	
	** Statistics format
	if("`format'"!=""){
		tempvar tempvar //Create a temporary variable for testing
		gen `tempvar' = rnormal() in 1
		cap	format `tempvar' `format'
		if _rc!=0{
			di as error "the format specified in format(`format') is not valid. See {help format} for a list of valid Stata formats. This command only accept the f, fc, g, gc and e format."
			error _rc
			exit
		}
	}
	if("`format'"!=""&`dec'!=-1){
		local formatdec = substr("`format'",strpos("`format'",".")+1,floor(`dec'/10)+1)
		if "`formatdec'"!="`dec'"&`dec'!=-1{
			di as error "the decimal specified in {bf:format()} is inconsistent with the decimal specified in {bf:dec()}."
			error 198
			exit
		}
	}
	** Statistics
	if ("`stats'"=="") loc stats = "mean sd" //if Stats not specified, assumed as mean and standard deviation
	loc invalidlist = ""
	tokenize "`stats'" //Break down statistics specification into commands
	loc numstats = wordcount("`stats'")
	forv i = 1(1)`numstats'{
		loc stats`i' = "``i''"
		loc valid = 0
		foreach x in mean median sd se sem semean seb sebinomial sep sepoisson sum rawsum n obs count max min iqr first firstnm last lastnm percent{
			if ("`stats`i''"=="`x'") loc valid = 1
		}
		forv j = 1(1)99{
			if ("`stats`i''"=="p`j'") loc valid = 1
		}
		if (`valid' == 0 & "`invalidlist'"=="") loc invalidlist = "`stats`i''"
		else if (`valid' == 0 & "`invalidlist'"!="") loc invalidlist = "`invalidlist', `stats`i''"
		* Fix for abbreviation
		if ("`stats`i''"=="n") loc stats`i' = "count"
		if ("`stats`i''"=="obs") loc stats`i' = "count"
		if ("`stats`i''"=="se") loc stats`i' = "sem"
		if ("`stats`i''"=="semean") loc stats`i' = "sem"
		if ("`stats`i''"=="sebinomial") loc stats`i' = "seb"
		if ("`stats`i''"=="sepoisson") loc stats`i' = "sep"
	}
	if "`invalidlist'"!=""{
		di as error "the following statistic(s) are not valid: `invalidlist'"
		error 198
		exit
	}
	* Delete duplicated statistics
	local warning = 0
	local nexttolast = `numstats' - 1
	forv i = 1(1)`nexttolast'{
		local j = `i' + 1
		forv k = `j'(1)`numstats'{
			if ("`stats`k''"=="`stats`i''"){
				loc stats`k' = ""
				loc warning = 1
			} 
		}
	}
	if (`warning' == 1) dis in red "WARNING: repeated statistics specified. Only use the first one."
	loc stats = ""
	forv i = 1(1)`numstats'{
		if ("`stats`i''"!=""&"`stats'"=="") loc stats = "`stats`i''"
		else if ("`stats`i''"!=""&"`stats'"!="") loc stats = "`stats' `stats`i''"
	}
	tokenize "`stats'" //Break down statistics specification into commands again
	loc numstats = wordcount("`stats'")
	forv i = 1(1)`numstats'{
		loc stats`i' = "``i''"
	}
	** Brackets setting
	tokenize "`paren'"
	loc numparens = wordcount("`paren'")
	forv i = 1(1)`numparens'{
		loc oriparen`i' = "``i''"
		loc paren`i' = "``i''"		
		* Fix for abbreviation
		if ("`paren`i''"=="se") loc paren`i' = "sem"
		if ("`paren`i''"=="semean") loc paren`i' = "sem"
		if ("`paren`i''"=="sebinomial") loc paren`i' = "seb"
		if ("`paren`i''"=="sepoisson") loc paren`i' = "sep"
		
		if strpos("`stats'","`paren`i''")==0{
			di as error "statistics {bf:`oriparen`i''} specified in {bf:paren()} but not found in {bf:stats()}."
			error 198
			exit
		}
	}
	if ("`paren'"=="" & "`noparen'"=="" & `numstats' >= 2 & `long' == 1){
		loc parpos = "2"
		loc numparens = 1
	}
	else loc parpos = ""
	forv i = 1(1)`numparens'{
		forv j = 1(1)`numstats'{
			if("`paren`i''"=="`stats`j''") loc parpos = "`parpos' `j'"
		}
	}
	tokenize "`bracket'"
	loc numbrackets = wordcount("`bracket'")
	forv i = 1(1)`numbrackets'{
		loc oribracket`i' = "``i''"
		loc bracket`i' = "``i''"		
		* Fix for abbreviation
		if ("`bracket`i''"=="se") loc bracket`i' = "sem"
		if ("`bracket`i''"=="semean") loc bracket`i' = "sem"
		if ("`bracket`i''"=="sebinomial") loc bracket`i' = "seb"
		if ("`bracket`i''"=="sepoisson") loc bracket`i' = "sep"
		
		if strpos("`stats'","`bracket`i''")==0{
			di as error "statistics {bf:`oribracket`i''} specified in {bf:bracket()} but not found in {bf:stats()}."
			error 198
			exit
		}
	}
	forv i = 1(1)`numparens'{
		forv j = 1(1)`numbrackets'{
			if "`paren`i''"=="`bracket`j''"{
				di as error "cannot specify the same statistics in both {bf:paren()} and {bf:bracket()}."
				error 198
				exit
			}
		}
	}
	if ("`bracket'"=="" & "`nobracket'"=="" & `numstats' >= 3 & `long' == 1){
		loc brapos = "3"
		loc numbrackets = 1
	} 
	else loc brapos = ""
	forv i = 1(1)`numbrackets'{
		forv j = 1(1)`numstats'{
			if("`bracket`i''"=="`stats`j''") loc brapos = "`brapos' `j'"
		}
	}
	** Save
	if "`save'"!=""{
		if strrpos("`save'","/")!=0{
			loc filename = substr("`save'",strrpos("`save'","/")+1,.)
			loc path = substr("`save'",1,strrpos("`save'","/")-1)
		}
		else if strrpos("`save'","\")!=0{
			loc filename = substr("`save'",strrpos("`save'","\")+1,.)
			loc path = substr("`save'",1,strrpos("`save'","\")-1)
		}
		else loc filename = "`save'"
		if "`path'"!="" {
			cap confirm file "`path'"
			if _rc!=0 {
				di as error "directory of outfile not found."
				error 601
				exit
			}
		}
		if (strpos("`filename'",".")==0) loc save = "`save'.csv" //csv as default
		loc extension = substr("`save'",-4,4) // output type
		if ("`extension'"=="xlsx") local extension = substr("`save'",-5,5) //for xlsx
		if "`extension'"!=".csv"&"`extension'"!=".txt"&"`extension'"!=".xls"&"`extension'"!=".xlsx"&"`extension'"!=".dta"{
			di as error "saving file type not allowed. Only allow for .txt, .csv, .xls, .xlsx, and .dta files."
			error 198
			exit
		}
		
		cap confirm file "`save'"
		if _rc==0 & "`extension'"!=".xlsx" & "`extension'"!=".xls" & "`replace'"==""{
			di as error "file {bf:`save'} already exists, must specify {bf:replace}."
			error 602
			exit
		}
		
		if _rc==0 & ("`extension'"==".xlsx" | "`extension'"==".xls") & "`replace'"=="" & `"`sheet'"'=="" {
			di as error "file {bf:`save'} already exists, must specify {bf:replace} or {bf:sheet()}."
			error 602
			exit
		}
		if substr(`"`sheet'"',1,1)==`"""'&substr(`"`sheet'"',-1,1)==`"""'{
			loc sheet = substr(`"`sheet'"',2,length(`"`sheet'"')-2)
		}
		if _rc==0 & ("`extension'"==".xlsx" | "`extension'"==".xls") ///
			& "`replace'"=="" & "`sheetreplace'"=="" & `"`sheet'"'!="" ///
			& strpos(`"`sheet'"',"rep")==0 & strpos(`"`sheet'"',"mod")==0 {
			import excel "`save'", describe
			loc sheetexist=0
			forv i = 1(1)`r(N_worksheet)'{
				if (`"`sheet'"'==`"`r(worksheet_`i')'"') loc sheetexist=1
			}
			if `sheetexist'==1{
				di as error "worksheet {bf:`sheet'} already exists, must specify sheet(..., modify), sheet(..., replace), or {bf:sheetreplace}."
				error 602
				exit
			}
		}
		
	}

	if ("`extension'"!=".xls" & "`extension'"!=".xlsx" & "`sheet'"!=""){
		di as error "option {bf:sheet()} is only allowed when the format of saving file is .xls or .xlsx."
		error 198
		exit
	}
	 
	if `"`sheet'"'!="" & strpos(`"`sheet'"',",")!=0{
		loc sheetopt = substr(`"`sheet'"',strrpos(`"`sheet'"',",")+1,.)
		if strpos(`"`sheetopt'"',`"""')==0{ 
			if (strpos("`sheetopt'","rep")!=0 | strpos("`sheetopt'","mod")!=0) loc sheetreplace = "sheetreplace"
			loc sheet = substr(`"`sheet'"',1,strrpos(`"`sheet'"',",")-1)
			loc sheetopt = subinstr("`sheetopt'","replace","",.)
			loc sheetopt = subinstr("`sheetopt'","replac","",.)
			loc sheetopt = subinstr("`sheetopt'","repla","",.)
			loc sheetopt = subinstr("`sheetopt'","repl","",.)
			loc sheetopt = subinstr("`sheetopt'","rep","",.)
			loc sheetopt = subinstr("`sheetopt'","modify","",.)
			loc sheetopt = subinstr("`sheetopt'","modif","",.)
			loc sheetopt = subinstr("`sheetopt'","modi","",.)
			loc sheetopt = subinstr("`sheetopt'","mod","",.)
			loc sheetopt = subinstr("`sheetopt'"," ","",.)
			if "`sheetopt'"!="" {
				di as error "invalid {bf:sheet()} option"
				di as error "only allow for {bf:replace} or {bf:modify}"
				error 198
				exit
			}
		}
	}
	** recode by(s): deal with string variable and missing value
	forv i = 1(1)`numbys'{
		cap confirm str# variable `by`i'' //check whether is string variable
		if _rc==0 { //encode to factor variable
			encode `by`i'', gen(`by`i''cd)
			drop `by`i''
			rename `by`i''cd `by`i''
		}
		cap assert !missing(`by`i'')
		if _rc!=0{
			sum `by`i''
			loc misscd = 10^(strlen(string(ceil(r(max))))+1) - 1
			recode `by`i'' . = `misscd'
			if (`labelval' == 0) lab val `by`i'' .
			local vallab: value label `by`i''
			if "`vallab'"!=""{
				lab de `vallab' `misscd' "Missing", add
			}
			if "`vallab'"==""{
				lab de `by`i'' `misscd' "Missing", add
				lab val `by`i'' `by`i''
			}
			cap assert !missing(`by`i'')
			if _rc!=0{
				loc a = 1
				foreach x in `c(alpha)'{
					loc misscd2 = `misscd' * 100 + `a'
					recode `by`i'' .`x' = `misscd2'
					local vallab: value label `by`i''
					lab de `vallab' `misscd2' "Missing (.`x')", add
					loc a = `a' + 1
				}
			}
		}
		if (`labelvar'== 1) local labby`i': variable label `by`i''
		if (`labelvar'== 0|"`labby`i''"=="") local labby`i' = "`by`i''"
		levelsof `by`i'', local(by`i'levels)
		tab `by`i'', gen(_by`i'_) //create dummies for factor variable
		loc numcats`i' = r(r) //number of categories
		forv j = 1(1)`numcats`i''{
			local by`i'lab`j': variable label _by`i'_`j'
			local by`i'lab`j' = subinstr("`by`i'lab`j''","`by`i''==","",.) //simplize the label
			cap dis `by`i'lab`j''
			if (_rc == 0){ //adjust format for numeric label
				loc by`i'lab`j': dis %15.3g `by`i'lab`j'' 
				loc by`i'lab`j' = subinstr("`by`i'lab`j''"," ","",.)
			}
			
			if (`numbys' > 1 & "`byinteract'"!="1") local by`i'lab`j' = "`labby`i'': `by`i'lab`j''"
		}
	}
	** multiple or interaction bys
	if "`byinteract'"=="1" & "`by'"!=""{
		gen _by = .
		loc i = 1
		forv j = 1(1)`numcats1'{
			forv k = 1(1)`numcats2'{
				replace _by = `i' if _by1_`j' == 1 & _by2_`k' == 1
				lab de _by `i' "`by1lab`j'', `by2lab`k''", add
				loc i = `i' + 1
			}
		}
		
		gen _expandid = _n
		if ("`all'" == "all"){
			expand 2
			bysort _expandid: replace _expandid = _n - 1
			replace _by = 0 if _expandid == 0
			lab de _by 0 "All", add
		}
		if ("`all'" == ""){
			bysort _expandid: replace _expandid = 1
		}
		lab val _by _by
		loc by = "_by"
	}
	if "`byinteract'"!="1" & "`by'"!=""{
		loc expand = `numbys'
		if ("`all'" == "all") loc expand = `expand' + 1
		gen _expandid = _n
		expand `expand'
		if ("`all'" == "all") bysort _expandid: replace _expandid = _n - 1
		if ("`all'" == "") bysort _expandid: replace _expandid = _n
		gen _by = .
		if "`all'" == "all" {
			replace _by = 0 if _expandid == 0
			lab de _by 0 "All", add
		}
		loc i = 1
		forv j = 1(1)`numbys'{
			forv k = 1(1)`numcats`j''{
				replace _by = `i' if _expandid == `j' & _by`j'_`k' == 1
				lab de _by `i' "`by`j'lab`k''", add
				loc i = `i' + 1
			}
		}
		lab val _by _by
		loc by = "_by"
	}
	
	marksample touse

	*** Create convenient local
	if ("`weight'"!="") loc wt [`weight'`exp']
	if (`svy'==1){
		svyset
		loc wexp = subinstr("`r(wexp)'","=","",.)
	}
	if ("`by'"!="") loc bycommand = "by(`by')"
	
	*** svy prefix and some of pweight/iweight commands
	if (`svy'==1 | "`weight'"=="pweight" | "`weight'"=="iweight") & (strpos("`stats'","mean")!=0 | strpos("`stats'","sd")!=0 | strpos("`stats'","sem")!=0 | strpos("`stats'","sum")!=0){
		if "`cw'"=="cw" { //casewise
			if "`by'"==""{
				if ("`prefix'" != "") `prefix' mean `vars'
				else mean `vars' `wt'
				mat M=r(table)
				if (strpos("`stats'","mean")!=0){
					forv i = 1(1)`numvars'{
						loc mean`i' = M[1,`i']
					}
				}
				if (strpos("`stats'","sem")!=0){
					forv i = 1(1)`numvars'{
						loc se`i' = M[2,`i']
					}
				}
				if (strpos("`stats'","sum")!=0){
					forv i = 1(1)`numvars'{
						loc mean`i' = M[1,`i']
						loc sum`i' = mean`i' * e(N_pop)
					}
				}
				if (strpos("`stats'","sd")!=0){
					estat sd
					mat M=r(sd)
					forv i = 1(1)`numvars'{
						loc sd`i' = M[1,`i']
					}
				}
			}
			if "`by'"!=""{
				levelsof `by', local(bylevels)
				foreach l of local bylevels{
					if ("`prefix'" != "") `prefix' mean `vars' if `by' == `l'
					else mean `vars' `wt' if `by' == `l'
					mat M=r(table)
					if (strpos("`stats'","mean")!=0){
						forv i = 1(1)`numvars'{
							loc mean`i'_by`l' = M[1,`i']
						}
					}
					if (strpos("`stats'","sem")!=0){
						forv i = 1(1)`numvars'{
							loc se`i'_by`l' = M[2,`i']
						}
					}
					if (strpos("`stats'","sum")!=0){
						forv i = 1(1)`numvars'{
							loc mean`i'_by`l' = M[1,`i']
							loc sum`i'_by`l' = mean`i'_by`l' * e(N_pop)
						}
					}
					if (strpos("`stats'","sd")!=0){
						estat sd
						mat M=r(sd)
						forv i = 1(1)`numvars'{
							loc sd`i'_by`l' = M[1,`i']
						}
					}
				}
			}
		}
		if "`cw'"=="" { //pairwise
			if "`by'"==""{
				forv i = 1(1)`numvars'{
					if ("`prefix'" != "") `prefix' mean `var`i''
					else mean `var`i'' `wt'
					mat M=r(table)
					if (strpos("`stats'","mean")!=0){
						loc mean`i' = M[1,1]
					}
					if (strpos("`stats'","sem")!=0){
						loc se`i' = M[2,1]
					}
					if (strpos("`stats'","sum")!=0){
						loc mean`i' = M[1,1]
						loc sum`i' = mean`i' * e(N_pop)
					}
					if (strpos("`stats'","sd")!=0){
						estat sd
						mat M=r(sd)
						loc sd`i' = M[1,1]
					}
				}
			}
			if "`by'"!=""{
				levelsof `by', local(bylevels)
				forv i = 1(1)`numvars'{
					foreach l of local bylevels{
						if ("`prefix'" != "") `prefix' mean `var`i'' if `by' == `l'
						else mean `var`i'' `wt' if `by' == `l'
						mat M=r(table)
						if (strpos("`stats'","mean")!=0){
							loc mean`i'_by`l' = M[1,1]
						}
						if (strpos("`stats'","sem")!=0){
							loc se`i'_by`l' = M[2,1]
						}
						if (strpos("`stats'","sum")!=0){
							loc mean`i'_by`l' = M[1,1]
							loc sum`i'_by`l' = mean`i'_by`l' * e(N_pop)
						}
						if (strpos("`stats'","sd")!=0){
							estat sd
							mat M=r(sd)
							loc sd`i'_by`l' = M[1,1]
						}
					}
				}
			}
		}
	}
	
	*** Collapse command
	local command = ""
	forv i = 1(1)`numstats'{
		if "`stats`i''" == "mean" & `svy'==1{
			loc meanpos = `i'
			loc command`i' = "(mean)"
			if "`by'"==""{
				forv j = 1(1)`numvars'{
					gen var`j'mean = `mean`j''
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'mean"
				}
			}
			if "`by'"!=""{
				forv j = 1(1)`numvars'{
					gen var`j'mean = .
					foreach l of local bylevels{
						replace var`j'mean = `mean`j'_by`l'' if `by' == `l'
					}
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'mean"
				}
			}
		}
		else if "`stats`i''" == "sd" & (`svy'==1 | "`weight'"=="pweight" | "`weight'"=="iweight"){
			loc sdpos = `i'
			loc command`i' = "(mean)"
			if "`by'"==""{
				forv j = 1(1)`numvars'{
					gen var`j'sd = `sd`j''
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'sd"
				}
			}
			if "`by'"!=""{
				forv j = 1(1)`numvars'{
					gen var`j'sd = .
					foreach l of local bylevels{
						replace var`j'sd = `sd`j'_by`l'' if `by' == `l'
					}
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'sd"
				}
			}
		}
		else if "`stats`i''" == "sem" & (`svy'==1 | "`weight'"=="pweight" | "`weight'"=="iweight"){
			loc sepos = `i'
			loc command`i' = "(mean)"
			if "`by'"==""{
				forv j = 1(1)`numvars'{
					gen var`j'se = `se`j''
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'se"
				}
			}
			if "`by'"!=""{
				forv j = 1(1)`numvars'{
					gen var`j'se = .
					foreach l of local bylevels{
						replace var`j'se = `se`j'_by`l'' if `by' == `l'
					}
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'se"
				}
			}
		}
		else if "`stats`i''" == "sum" & `svy'==1{
			loc sumpos = `i'
			loc command`i' = "(mean)"
			if "`by'"==""{
				forv j = 1(1)`numvars'{
					gen var`j'sum = `sum`j''
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'sum"
				}
			}
			if "`by'"!=""{
				forv j = 1(1)`numvars'{
					gen var`j'sum = .
					foreach l of local bylevels{
						replace var`j'sum = `sum`j'_by`l'' if `by' == `l'
					}
					loc command`i' = "`command`i'' val`i'_var`j'=var`j'sum"
				}
			}
		}
		else{
			loc command`i' = "(`stats`i'')"
			forv j = 1(1)`numvars'{
				loc command`i' = "`command`i'' val`i'_var`j'=`var`j''"
			}
		}
		loc command = "`command' `command`i''"
	}
	
	
	*** Calculate # of observations
	if "`by'"==""{
		count
		loc rawobserv = r(N)
	}
	if "`by'"!=""{
		count if _expandid == 1
		loc rawobserv = r(N)
		levelsof `by', local(bylevels) 
		foreach l of local bylevels{
			count if `by' == `l'
			loc rawobserv`l' = r(N)
		}
	}
	loc rawobserv: dis %15.0fc `rawobserv'
	loc rawobserv = subinstr("`rawobserv'"," ","",.)
	if "`by'"!=""{
		levelsof `by', local(bylevels)
		foreach l of local bylevels{
			loc rawobserv`l': dis %15.0fc `rawobserv`l''
			loc rawobserv`l' = subinstr("`rawobserv`l''"," ","",.)
		}
	}
	
	gen _obs = 1 //count number of obs.
	if (`svy' == 1) replace _obs = `wexp'
	if (`svy' == 0) loc command = "`command' (count)_obs"
	if (`svy' == 1) loc command = "`command' (sum)_obs"
	if ("`gcollapse'" == "") collapse `command' `wt', `cw' `bycommand' fast
	if ("`gcollapse'" == "gcollapse") cap gcollapse `command' `wt', `cw' `bycommand' fast
	if _rc == 9999 {
		loc link = "gtools.readthedocs.io/en/latest/compiling/index.html"
		which gcollapse		
		dis as error "(error occurred while loading _gtools_internal.ado)"
		dis as error "see {browse `link'} for more information"
		dis as error "otherwise, remove the {bf:gcollapse} option"
		exit
		
	}

	*** Calculate number of observations
	if "`by'"==""{
		sum _obs
		local observ = r(mean)
	}
	if "`by'"!=""{
		loc loopend = _N
		forv i = 1(1)`loopend'{
			sum _obs in `i'
			loc observ`i' = r(mean)
		}
	}
	loc observ: dis %15.0fc `observ'
	loc observ = subinstr("`observ'"," ","",.)
	if "`by'"!=""{
		forv i = 1(1)`loopend'{
			loc observ`i': dis %15.0fc `observ`i''
			loc observ`i' = subinstr("`observ`i''"," ","",.)
		}
	}
	drop _obs
	
	*** Organize table
	gen id = 1
	loc stub = ""
	forv i = 1(1)`numstats'{
		loc stub = "`stub' val`i'"
	}
	reshape long `stub', i(id `by') j(var) string
	** generate variables order
	gen varorder = subinstr(var,"_var","",.)
	destring varorder, replace
	
	forv i = 1(1)`numvars'{
		replace var = "`varlab`i''" if var == "_var`i'" 
	}
	tostring val*, format(`format') replace force
	sort varorder
	
	
	if `long' == 1 {
		reshape long val, i(`by' id var varorder) j(stat)
		replace var = "" if stat!=1
		sort varorder stat
	}
	
	** Deal with by command
	if "`by'"!=""{	
		sum `by'
		if r(min) < 0 { //if by is negaive, the variable name would have problems
			tostring `by', gen(by_tostr)
			decode `by', gen(by_decode)
			order by_tostr by_decode, a(`by')
			drop `by'
			rename by_tostr `by'
			if (`labelval' == 1 & by_decode != "") replace `by' = by_decode
			drop by_decode
		}
		
		loc bystr = 0
		cap confirm str# variable `by' //check whether is string variable
		if _rc==0 { //encode to factor variable
			loc bystr = 1
			encode `by', gen(`by'cd)
			drop `by'
			rename `by'cd `by'
		}
		
		else { //check whether all values are integer
			levelsof `by', local(bylevels)
			loc anynonint = 0
			foreach l of local bylevels{
				cap confirm integer n `l'
				if _rc!=0{
					loc anynonint = 1
				}
			}
			if `anynonint' == 1 { //if by has noninteger, the variable name would have problems
				tostring `by', gen(by_tostr)
				decode `by', gen(by_decode)
				order by_tostr by_decode, a(`by')
				drop `by'
				rename by_tostr `by'
				if (`labelval' == 1 & by_decode != "") replace `by' = by_decode
				drop by_decode
				loc bystr = 1
				encode `by', gen(`by'cd)
				drop `by'
				rename `by'cd `by'
			}
			
		}
		levelsof `by', local(bylevels) //save the by level in local
		tab `by', gen(`by')
		loc numcats = r(r) //number of categories
		forv i = 1(1)`numcats'{
			local bylab`i': variable label `by'`i'
			local bylab`i' = subinstr("`bylab`i''","`by'==","",.) //simplize the label
			drop `by'`i'
		}
		if (`long' == 0) reshape wide val*, i(id varorder var) j(`by')
		if (`long' == 1) reshape wide val*, i(id varorder var stat) j(`by')
	}

	** Sorting
	if (`long' == 1) sort varorder stat
	if (`long' == 0) sort varorder
	
	** Panel
	tokenize `"`c(ALPHA)'"'
	if `numpanels'!=0{
		local N0 = _N
		local N = _N + `numpanels'
		set obs `N'
		forv i = 1(1)`numpanels'{
			replace varorder = `panel`i'start'-0.5 if _n == `N0' + `i'
			replace var = "`paneltitle`i''" if _n == `N0' + `i'
			if ("`panelalp'"=="1" & "`paneltitle`i''"=="") replace var = "Panel ``i''" if _n == `N0' + `i'
			if ("`panelalp'"=="1" & "`paneltitle`i''"!="") replace var = "Panel ``i'': `paneltitle`i''" if _n == `N0' + `i'
			if ("`panelnum'"=="1" & "`paneltitle`i''"!="") replace var = "Panel `i': `paneltitle`i''" if _n == `N0' + `i'
			replace var = "   " + var if inrange(varorder,`panel`i'start',`panel`i'end')
		}
		if (`long' == 1) sort varorder stat
		if (`long' == 0) sort varorder
	}
	
	** Add top/bottom line for observations
	if (strpos("`obs'","top")!=0){
		if strpos("`obs'","nopop")==0 & (`svy'==1 | "`weight'"=="iweight" | "`weight'"=="pweight" | "`weight'"=="fweight") {
			local N = _N + 1
			set obs `N'
			gen row = _n
			replace row = 0 if row == `N'
			sort row
			drop row
			replace var = "Number of Population" in 1
			if "`by'"==""{
				if (`long'==1) replace val = "`observ'" in 1
				if (`long'==0) replace val1 = "`observ'" in 1
			}
			if "`by'"!=""{
				loc i = 1
				foreach l of local bylevels{
					if (`long'==1) replace val`l' = "`observ`i''" in 1
					if (`long'==0) replace val1`l' = "`observ`i''" in 1
					loc i = `i' + 1
				}
			}
			
		}
		if strpos("`obs'","noraw")==0{
			local N = _N + 1
			set obs `N'
			gen row = _n
			replace row = 0 if row == `N'
			sort row
			drop row
			replace var = "Number of Observations" in 1
			if "`by'"==""{
				if (`long'==1) replace val = "`rawobserv'" in 1
				if (`long'==0) replace val1 = "`rawobserv'" in 1
			}
			if "`by'"!=""{
				foreach l of local bylevels{
					if (`long'==1) replace val`l' = "`rawobserv`l''" in 1
					if (`long'==0) replace val1`l' = "`rawobserv`l''" in 1
				}
			}
		}
	}
	if (strpos("`obs'","bottom")!=0){
		if strpos("`obs'","noraw")==0{
			local N = _N + 1
			set obs `N'
			replace var = "Number of Observations" in `N'
			if "`by'"==""{
				if (`long'==1) replace val = "`rawobserv'" in `N'
				if (`long'==0) replace val1 = "`rawobserv'" in `N'
			}
			if "`by'"!=""{
				foreach l of local bylevels{
					if (`long'==1) replace val`l' = "`rawobserv`l''" in `N'
					if (`long'==0) replace val1`l' = "`rawobserv`l''" in `N'
				}
			}
		}
		if strpos("`obs'","nopop")==0 & (`svy'==1 | "`weight'"=="iweight" | "`weight'"=="pweight" | "`weight'"=="fweight") {
			local N = _N + 1
			set obs `N'
			replace var = "Number of Population" in `N'
			if "`by'"==""{
				if (`long'==1) replace val = "`observ'" in `N'
				if (`long'==0) replace val1 = "`observ'" in `N'
			}
			if "`by'"!=""{
				loc i = 1
				foreach l of local bylevels{
					if (`long'==1) replace val`l' = "`observ`i''" in `N'
					if (`long'==0) replace val1`l' = "`observ`i''" in `N'
					loc i = `i' + 1
				}
			}
		}
	}
	
	** Add one line for name of statistics (for wide table)
	if `long' == 0 { 
		local N = _N + 1
		set obs `N'
		gen row = _n
		replace row = 0 if row == `N'
		sort row
		drop row
		replace var = "Variables" in 1
		if "`by'"==""{
			forv i = 1(1)`numstats'{
				replace val`i' = proper("`stats`i''") in 1
				replace val`i' = "SD" if val`i' == "Sd"
				replace val`i' = "SE" if val`i' == "Sem"
				replace val`i' = "SE (binomial)" if val`i' == "Seb"
				replace val`i' = "SE (Poisson)" if val`i' == "Sep"
				replace val`i' = "N" if val`i' == "Count"
				replace val`i' = "Raw Sum" if val`i' == "Rawsum"
				replace val`i' = "IQR" if val`i' == "Iqr"
				replace val`i' = "1st Val." if val`i' == "First"
				replace val`i' = "Last Val." if val`i' == "Last"
				replace val`i' = "1st Nonmiss. Val." if val`i' == "Firstnm"
				replace val`i' = "Last Nonmiss. Val." if val`i' == "Lastnm"
			}
		}
		else if "`by'"!=""{
			foreach l of local bylevels{
				forv i = 1(1)`numstats'{
					replace val`i'`l' = proper("`stats`i''") in 1
					replace val`i'`l' = "SD" if val`i'`l' == "Sd"
					replace val`i'`l' = "SE" if val`i'`l' == "Sem"
					replace val`i'`l' = "SE (binomial)" if val`i'`l' == "Seb"
					replace val`i'`l' = "SE (Poisson)" if val`i'`l' == "Sep"
					replace val`i'`l' = "N" if val`i'`l' == "Count"
					replace val`i'`l' = "Raw Sum" if val`i'`l' == "Rawsum"
					replace val`i'`l' = "IQR" if val`i'`l' == "Iqr"
					replace val`i'`l' = "1st Val." if val`i'`l' == "First"
					replace val`i'`l' = "Last Val." if val`i'`l' == "Last"
					replace val`i'`l' = "1st Nonmiss. Val." if val`i'`l' == "Firstnm"
					replace val`i'`l' = "Last Nonmiss. Val." if val`i'`l' == "Lastnm"
				}
			}
		}
	}
	** Add one line for group name (for by command)
	if "`by'"!="" & "`numbys'"=="1"{
		local N = _N + 1
		set obs `N'
		gen row = _n
		replace row = 0 if row == `N'
		sort row
		drop row
		
		loc i = 1
		foreach l of local bylevels{
			if `long'==1{
				replace val`l' = "`bylab`i''" in 1
				loc i = `i' + 1
 			}
			if `long'==0{
				replace val1`l' = "`bylab`i''" in 1
				loc i = `i' + 1
			}
		}
		
	}
	if "`by'"!="" & "`numbys'"!="1" & "`byinteract'"!="1"{
		local N = _N + 2
		set obs `N'
		gen row = _n
		replace row = 0 if row >= `N' - 1
		sort row
		drop row
		
		loc i = 1
		foreach l of local bylevels{
			if `long'==1{
				replace val`l' = substr("`bylab`i''",1,strpos("`bylab`i''",":")-1) in 1
				replace val`l' = substr("`bylab`i''",strpos("`bylab`i''",":")+1,.) in 2
				loc i = `i' + 1
 			}
			if `long'==0{
				replace val1`l' = substr("`bylab`i''",1,strpos("`bylab`i''",":")-1) in 1
				replace val1`l' = substr("`bylab`i''",strpos("`bylab`i''",":")+1,.) in 2
				loc i = `i' + 1
			}
			loc k = `l'
		}
		
	}
	if "`by'"!="" & "`byinteract'"=="1"{
		local N = _N + 2
		set obs `N'
		gen row = _n
		replace row = 0 if row >= `N' - 1
		sort row
		drop row
		
		loc i = 1
		foreach l of local bylevels{
			if `long'==1{
				replace val`l' = substr("`bylab`i''",1,strpos("`bylab`i''",",")-1) in 1
				replace val`l' = substr("`bylab`i''",strpos("`bylab`i''",",")+1,.) in 2
				loc i = `i' + 1
 			}
			if `long'==0{
				replace val1`l' = "`bylab`i''" in 1
				loc i = `i' + 1
			}
		}
		
	}
	
	** Put brackets
	if "`by'"==""{
		if `long'==1 {
			foreach x in `parpos' {
				replace val = "(" + val + ")" if stat == `x'
			}
			foreach x in `brapos' {
				replace val = "[" + val + "]" if stat == `x'
			}
		}
		if `long'==0 {
			foreach x in `parpos' {
				replace val`x' = "(" + val`x' + ")" if id !=.
			}
			foreach x in `brapos' {
				replace val`x' = "[" + val`x' + "]" if id !=.
			}
		}
	}
	if "`by'"!=""{
		if `long'==1 {
			foreach l of local bylevels {
				foreach x in `parpos' {
					replace val`l' = "(" + val`l' + ")" if stat == `x'
				}
				foreach x in `brapos' {
					replace val`l' = "[" + val`l' + "]" if stat == `x'
				}
			}
		}
		if `long'==0 {
			foreach l of local bylevels {
				foreach x in `parpos' {
					replace val`x'`l' = "(" + val`x'`l' + ")" if id !=.
				}
				foreach x in `brapos' {
					replace val`x'`l' = "[" + val`x'`l' + "]" if id !=.
				}
			}
		}
	}
	** Clean table
	cap drop id
	cap drop stat
	cap drop varorder
	local i = 1
	foreach var of varlist _all{
		rename `var' v`i'
		lab var v`i' ""
		loc i = `i'+1
	}
	loc i = `i' - 1
	forv j = 3(1)`i'{
		loc k = `j' - 1
		forv l = 2(1)`k'{
			replace v`j' = "" if v`j' == v`l' & _n == 1
		}
	}
	
	*** Additional information
	
	** Create Title
	if "`title'"!=""{
		
		if (strpos("`obs'","title")!=0){
			local title = "`title' (N = `rawobserv')"
		}
		
		
		loc N = _N+1
		set obs `N'
		gen row = _n
		replace row = 0 in `N'
		sort row
		drop row
		replace v1 = "`title'" in 1
	}
	** Create Note
	if "`nonote'"=="" & "`repnote'"==""{
		loc defnote = ""
		if `numparens' != 0{
			loc i = 0
			foreach x in `parpos' {
				loc i = `i' + 1
				if (`i'==1) loc defnote = "`defnote' `stats`x''"
				else if (`i'==`numparens') loc defnote = "`defnote' and `stats`x''"
				else loc defnote = "`defnote', `stats`x''"
			}
			loc defnote = "`defnote' in parentheses."
		}
		if `numbrackets' != 0{
			loc i = 0
			foreach x in `brapos' {
				dis "`x'"
				loc i = `i' + 1
				if (`i'==1) loc defnote = "`defnote' `stats`x''"
				else if (`i'==`numbrackets') loc defnote = "`defnote' and `stats`x''"
				else loc defnote = "`defnote', `stats`x''"
			}
			loc defnote = "`defnote' in squared brackets."
		}
		
		loc defnote = subinstr("`defnote'","sd","standard deviation",.)
		loc defnote = subinstr("`defnote'","sem","standard error",.)
		loc defnote = subinstr("`defnote'","seb","standard error (binomial)",.)
		loc defnote = subinstr("`defnote'","sep","standard error (Poisson)",.)
		loc defnote = subinstr("`defnote'","count","number of nonmissing observations",.)
		loc defnote = subinstr("`defnote'","percent","percent of nonmissing observations",.)
		loc defnote = subinstr("`defnote'","rawsum","raw sum",.)
		loc defnote = subinstr("`defnote'","max","Max.",.)
		loc defnote = subinstr("`defnote'","min","Min.",.)
		loc defnote = subinstr("`defnote'","iqr","interquartile range (IQR)",.)
		loc defnote = subinstr("`defnote'","first","first value",.)
		loc defnote = subinstr("`defnote'","last","last value",.)
		loc defnote = subinstr("`defnote'","firstnm","first nonmissing value",.)
		loc defnote = subinstr("`defnote'","lastnm","last nonmissing value",.)
		forv i = 99(-1)1{
			if (mod(`i',10)==1) loc defnote = subinstr("`defnote'","p`i'","`i'st percentile",.)
			else if (mod(`i',10)==2) loc defnote = subinstr("`defnote'","p`i'","`i'nd percentile",.)
			else if (mod(`i',10)==3) loc defnote = subinstr("`defnote'","p`i'","`i'rd percentile",.)
			else loc defnote = subinstr("`defnote'","p`i'","`i'th percentile",.)
		}
		if (strpos("`obs'","note")!=0){
			loc defnote = "`defnote' Total sample size is `rawobserv'."
			if "`by'"!=""{
				loc i = 1
				foreach l of local bylevels {
					if (`l'==0) loc i = `i' + 1
					else{
						if (`labelval'==1|`bystr'==1){
							loc defnote = "`defnote' Sample size for `bylab`i'' is `rawobserv`l''."
							local i = `i' + 1
						}
						else if (`labelval'==0){
							loc defnote = "`defnote' Sample size for group `bylab`i'' is `rawobserv`l''."
							loc i = `i' + 1
						}
					}
				}
			}
		}
	}
	
	if "`nonote'"==""{
		if (substr(`"`note'"',1,1) == `"""' & substr(`"`note'"',-1,1) == `"""') loc note = substr(`"`note'"',2,length(`"`note'"')-2)		
		if (`"`note'"'!=""|"`defnote'"!=""){ //Only create note, when there are at least someting
			if ("`prenote'" == "1") loc note = `"Note: `note'`defnote'"'
			else if ("`repnote'" == "1") loc note = `"Note: `note'"'
			else if ("`defnote'" != "") loc note = `"Note:`defnote' `note'"' 
			else loc note = `"Note: `note'"' 
			
			loc N = _N+1
			set obs `N'
				
			replace v1 = `"`note'"' in `N'
		}
	}
	
	format v1 %-25s
	
	*** Saving File
	if `"`sheet'"'!="" & strpos(`"`sheet'"',`"""')!=0 loc sheet sheet(`sheet')	
	else if `"`sheet'"'!="" & strpos(`"`sheet'"',`"""')==0 loc sheet sheet(`"`sheet'"')	
	if "`extension'"==".xls" | "`extension'"==".xlsx"{
		export excel using "`save'", `replace' `sheet' `sheetreplace'
	}
	if "`extension'"==".csv" | "`extension'"==".txt"{
		if ("`sep'"!="") loc delim = "delim(`sep')"
		export delim using "`save'", `replace' novar `delim'
	}
	if "`extension'"==".dta"{
		cap labe data .
		cap notes drop _all
		save "`save'", `replace'
	}
	if "`save'"!=""{
		noi di as txt `"(output written to {browse `save'})"'
	}
	
	if "`seeout'"=="seeout"{
		version 7.0

		local version ""
		cap local version `c(stata_version)'

		if "`version'"=="" {
		}
		else if `version'>=8.2 {
			version 8.2
		}
		
		browse
		
		if "`version'"=="" {
		}
		else if `version'>=11.0 {
			noi di in yel "Hit Enter to continue" _request(junk)
		}
	}
	
	if ("`norestore'"=="") restore
	
	}
end
