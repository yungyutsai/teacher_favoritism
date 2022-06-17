global do = "/Users/yungyu/Dropbox/02 Research/education/teacher_favoritism/do"
global rdata = "/Users/yungyu/Dropbox/02 Research/education/teacher_favoritism/rdata"
global wdata = "/Users/yungyu/Dropbox/02 Research/education/teacher_favoritism/wdata"
global tables = "/Users/yungyu/Dropbox/02 Research/education/teacher_favoritism/tables"
global figures = "/Users/yungyu/Dropbox/02 Research/education/teacher_favoritism/figures"

/***** Section 1: Clean raw data *****/

** Student questionnaire
do "$do/1_clean_raw_data/1_1_clean_J1_W1_Student.do" //Studnet demographic
do "$do/1_clean_raw_data/1_1_clean_J1_W3_Student.do" //Student 9th grade outcomes
do "$do/1_clean_raw_data/1_1_clean_J1_W6_Student.do" //Student 12th grade outcomes
do "$do/1_clean_raw_data/1_1_clean_J1_W7_Student.do" //Student freshman grade outcomes
do "$do/1_clean_raw_data/1_1_clean_J1_W10_Student.do" //Student outcomes at age 25
do "$do/1_clean_raw_data/1_1_clean_J1_W12_Student.do" //Student outcomes at age 27

** Parent questionnaire
do "$do/1_clean_raw_data/1_2_clean_J1_W1_Parent.do" //Family background

** Homeroom teacher questionnaire
do "$do/1_clean_raw_data/1_3_clean_J1_W1_Teacher_a.do" //Teacher evaluation on students
do "$do/1_clean_raw_data/1_3_clean_J1_W1_Teacher_b.do" //Teacher individual information
do "$do/1_clean_raw_data/1_3_clean_J1_W2W3Teacher_b.do" //Does grade 8 & 9 change teacher?
do "$do/1_clean_raw_data/1_3_clean_J1_W3_Teacher_a.do" //Students 12th grade test score

/***** Section 2: Build data *****/

do "$do/2_build_data/2_1_merge_W1.do" //Merge W1 student, parent, and teacher questionnaire
do "$do/2_build_data/2_1_measure_selfconcept_W3.do" //Factor analysis for W3 self concept
do "$do/2_build_data/2_2_measure_teacher_favoritism.do" //Measure teacher favoritism
do "$do/2_build_data/2_3_teacher_measurement.do" //Factor analysis for teacher variable
do "$do/2_build_data/2_4_merge_all_waves.do" //Merge data of all waves

/***** Section 3: Analysis *****/

do "$do/3_analysis/0_MainEstimation_for_all.do"
do "$do/3_analysis/0_Bootstrap_for_all.do"
do "$do/3_analysis/0_summarystat.ado"

do "$do/3_analysis/Fig1.do"
do "$do/3_analysis/Fig2.do"
do "$do/3_analysis/Tab1.do"

do "$do/3_analysis/Tab234.do"
do "$do/3_analysis/Tab5.do"
do "$do/3_analysis/Tab6.do"

do "$do/3_analysis/Fig3.do"

do "$do/3_analysis/TabA2.do"

do "$do/3_analysis/FigB1_estimate.do"
do "$do/3_analysis/FigB1_graphing.do"
do "$do/3_analysis/FigB2.do"
