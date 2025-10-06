*import
import excel "C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Experiment\fairness_2023-04-07_allsessions.xlsx", sheet("fairness_2023-04-07_allsessions") firstrow clear

*drop participant who left session
drop if participant_id==44 //left session due to medical issue
*generate a dummy for effort task
gen effort_task=1 if current_task == "Effort"
label variable effort_task "dummy=1 if slider round, 0 for redistribution round"
replace effort_task=0 if current_task == "Redistribute"

*create a dummy variable for stage 1 rounds where inference were made
gen belief_elicitation=1 if round_number==round_firstHL|round_number==round_firstLL|round_number==round_firstLH
replace belief_elicitation=0 if belief_elicitation==.
label variable belief_elicitation "dummy=1 if beliefs were asked in stage 1"

*generate categorical variable for treatment
gen treatment=0 if current_treatment=="Low-High"
replace treatment=1 if current_treatment=="Low-Low"
replace treatment=2 if current_treatment=="High-Low"
label variable treatment "0:Identical-High, 1:Identical-Low, 2:Heterogeneous"

*copy the demographic and survey questions
qui bysort participant_id (round_number): replace gender=gender[1] if round_number>1
qui bysort participant_id (round_number): replace politics_GSS=politics_GSS[10] if round_number<12
qui bysort participant_id (round_number): replace escape_poverty_WVS=escape_poverty_WVS[10] if round_number<12
qui bysort participant_id (round_number): replace inequality_Stan=inequality_Stan[10] if round_number<12
qui bysort participant_id (round_number): replace luck_vs_effort=luck_vs_effort[10] if round_number<12
qui bysort participant_id (round_number): replace inequality_perception=inequality_perception[10] if round_number<12
qui bysort participant_id (round_number): replace rich_merit=rich_merit[10] if round_number<12
qui bysort participant_id (round_number): replace poor_lazy=poor_lazy[10] if round_number<12
qui bysort participant_id (round_number): replace inequality_useful=inequality_useful[10] if round_number<12
qui bysort participant_id (round_number): replace social_mobility2=social_mobility2[10] if round_number<12
qui bysort participant_id (round_number): replace social_class=social_class[10] if round_number<12
qui bysort participant_id (round_number): replace send_lazy=send_lazy[6] if round_number!=6
qui bysort participant_id (round_number): replace give_merit=give_merit[6] if round_number!=6
qui bysort participant_id (round_number): replace give_lucky=give_lucky[6] if round_number!=6
qui bysort participant_id (round_number): replace send_unlucky=send_unlucky[6] if round_number!=6

*generate a dummy to capture the previous round outcome
gen previous_outcome=. if effort_task==1
qui bysort participant_id (round_number): replace previous_outcome=target_is_reached[_n-1] if effort_task==1 & _n>1
qui bysort participant_id (round_number): replace previous_outcome=target_is_reached[5] if effort_task==1 & round_number==9 //replace last round by rd 5
qui bysort participant_id (round_number): replace previous_outcome=target_is_reached[9] if round_number>=10 //

*generate a variable to capture time spent per slider => check that there isn't much unobservable skill heterogeneity
gen efficiency=elapsed_time/num_correct if effort_task==1
label variable efficiency "Time per slider (seconds)"
su(efficiency), detail
mean efficiency if effort_task==1, over(participant_id)
egen mean_efficiency=mean(efficiency) if effort_task==1, by(participant_id)
egen best_efficiency=min(efficiency) if effort_task==1, by(participant_id)
su(best_efficiency), detail
egen mean_efficiency_by_round=mean(efficiency) if effort_task==1, by(round_number)
label variable mean_efficiency_by_round "Average time spent per slider (seconds)"
replace mean_efficiency_by_round=round(mean_efficiency_by_round,0.01)
hist efficiency if effort_task==1, percent xlabel(1(1)10) width(0.25) lcolor(gs12) graphregion(color(white)) title(Time per slider distribution) xtitle("Average time spent per slider (in seconds)") xline(2.5, lcolor(red)) scheme(white_tableau)
graph export "Time per slider distribution.eps", as(eps) preview(off) replace
!epstopdf "Time per slider distribution.eps"

hist mean_efficiency if effort_task==1, percent xlabel(1(1)10) width(0.25) lcolor(gs12) graphregion(color(white)) title(Average time per slider distribution) xtitle("Average time spent per slider for each participant (in seconds)") xline(2.5, lcolor(red)) scheme(white_tableau)
graph export "Time per slider distribution by participant.eps", as(eps) preview(off) replace
!epstopdf "Time per slider distribution by participant.eps"

hist best_efficiency if effort_task==1, percent xlabel(1(1)5) width(0.2) lcolor(gs12) graphregion(color(white)) title(Best time per slider distribution) xtitle("Best time spent per slider for each participant (in seconds)") xline(2.2, lcolor(red)) scheme(white_tableau)
graph export "Best time per slider distribution by participant.eps", as(eps) preview(off) replace
!epstopdf "Best time per slider distribution by participant.eps"

*Total number of sliders and time spent on first 5 rounds for each participant
total num_correct if effort_task==1 & round_number!=9, over(participant_id) //total number of sliders
total elapsed_time if effort_task==1 & round_number!=9, over(participant_id)
mean num_correct if effort_task==1 & round_number!=9, over(participant_id) //avg number of sliders
egen mean_correct_by_round=mean(num_correct) if effort_task==1, by(round_number)
label variable mean_correct_by_round "Average number of sliders correctly positioned"
replace mean_correct_by_round=round(mean_correct_by_round,1)

gen roundnew=round_number
replace roundnew=16 if roundnew==6
replace roundnew=6 if roundnew==9
sort effort_task roundnew
graph twoway connected mean_efficiency_by_round roundnew if effort_task==1 & inlist(round_number,1,2,3,4,5,9), mlabsize(small) mlabel(mean_efficiency_by_round) mlabposition(6) mlabgap(*1) lwidth(thin) mlabcolor(green) lcolor(green) mcolor(green) ///
|| connected mean_correct_by_round roundnew if effort_task==1 & inlist(round_number,1,2,3,4,5,9), mlabsize(small) mlabel(mean_correct_by_round) mlabposition(12) mlabgap(*1) mlabcolor(maroon) lwidth(thin) lcolor(maroon) mcolor(maroon) yaxis(2) ///
title(Effort and Efficiency by Round) ytitle(Average time per slider) ylabel(2(0.5)4) ytitle(# sliders correctly positioned, axis(2)) ylabel(100(50)300, axis(2)) xtitle(Round number) xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6") ///
plotregion(margin(large)) scheme(cblind1)
graph export "Efficiency by round.eps", as(eps) preview(off) replace
!epstopdf "Efficiency by round.eps"

*Is there a round effect? Like decreasing effort or times spent? Want to make sure time is not binding
total elapsed_time if effort_task==1 & round_number==5, over(participant_id) //check if time is binding in last round, but carefull because elapsed time=0 means maybe they gave up
total elapsed_time if effort_task==1 & inlist(round_number, 1,2,3,4), over(participant_id) //check how much time they spent on previous rounds
*time binding for participant 22, 31, 66, 83-> generate dummy to indicate that time is binding for them in last round of stage 1
gen time_binding=0 if effort_task==1 & round_number!=9
replace time_binding=1 if round_number==5 & inlist(participant_id, 22, 31, 66, 83)
mean elapsed_time if effort_task==1, over(round_number)
mean num_correct if effort_task==1, over(round_number)
mean efficiency if effort_task==1, over(round_number)

******************************************************
*Descriptive variables
******************************************************
su(num_correct) if effort_task==1 //average effort
*Avg effort by treatment for effort tasks + pairwise ttest
tab current_treatment if effort_task==1, su( num_correct )
ttest num_correct if treatment!=0 & effort_task==1, by(treatment)
ttest num_correct if treatment!=1 & effort_task==1, by(treatment)
ttest num_correct if treatment!=2 & effort_task==1, by(treatment)
*distribution of effort with and without round one
twoway (hist num_correct if effort_task==1, width(10) percent lcolor(white) fintensity(20) legend(off)) ///
(hist num_correct if effort_task==1 & round_number!=1, width(10) percent fcolor(none) lcolor(maroon) legend(off)), ///
legend(off) xtitle("# sliders correctly positioned (red: excluding round one)") xline(194, lcolor(red))  xlabel(0(50)300) scheme(white_tableau)
graph export "Effort distribution overlayed.eps", as(eps) preview(off) replace
!epstopdf "Effort distribution overlayed.eps"

twoway (hist num_correct if effort_task==1, width(10) by(treatment) percent lcolor(gs12) fintensity(25) legend(off)) ///
(hist num_correct if effort_task==1 & round_number!=1, width(10)  by(treatment) percent fcolor(none) lcolor(maroon) legend(off)), ///
legend(off) xtitle("# sliders correctly positioned (red: excluding round one)")  xlabel(0(50)300) scheme(white_tableau)
graph export "Effort distribution by treatment.eps", as(eps) preview(off) replace
!epstopdf "Effort distribution by treatment.eps"

*calculate avg effort conditional on task and reaching target
egen mean_effort = mean(num_correct) if effort_task==1, by(treatment target_is_reached)
egen effort_se = semean(num_correct) if effort_task==1, by(treatment target_is_reached)
gen mean_effort_lb = mean_effort - 1.96*effort_se
gen mean_effort_ub = mean_effort + 1.96*effort_se
replace mean_effort=round(mean_effort,1)
label variable mean_effort "Average effort by treatment and outcome"

egen mean_effort2 = mean(num_correct) if effort_task==1, by(treatment)
replace mean_effort2=round(mean_effort2,1)
label variable mean_effort2 "Average effort by treatment"

egen mean_skill = mean(skill_draw) if effort_task==1, by(treatment target_is_reached)
egen skill_se = semean(skill_draw) if effort_task==1, by(treatment target_is_reached)
gen mean_skill_lb = mean_skill - 1.96*skill_se
gen mean_skill_ub = mean_skill + 1.96*skill_se
replace mean_skill=round(mean_skill,0.1)
label variable mean_skill "Average skill by treatment and outcome"

egen mean_capital = mean(capital_draw) if effort_task==1, by(treatment target_is_reached)
egen capital_se = semean(capital_draw) if effort_task==1, by(treatment target_is_reached)
gen mean_capital_lb = mean_capital - 1.96*capital_se
gen mean_capital_ub = mean_capital + 1.96*capital_se
replace mean_capital=round(mean_capital,1)
label variable mean_capital "Average capital by treatment and outcome"

egen belief_mean_effort_reach = mean(belief_avg_effort_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_effort_reach_se = semean(belief_avg_effort_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_effort_reach_lb = belief_mean_effort_reach - 1.96*belief_mean_effort_reach_se
gen belief_mean_effort_reach_ub = belief_mean_effort_reach + 1.96*belief_mean_effort_reach_se
replace belief_mean_effort_reach=round(belief_mean_effort_reach,1)
label variable belief_mean_effort_reach "By treatment, average belief about effort if reach"

egen belief_mean_effort_miss = mean(belief_avg_effort_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_effort_miss_se = semean(belief_avg_effort_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_effort_miss_lb = belief_mean_effort_miss - 1.96*belief_mean_effort_miss_se
gen belief_mean_effort_miss_ub = belief_mean_effort_miss + 1.96*belief_mean_effort_miss_se
replace belief_mean_effort_miss=round(belief_mean_effort_miss,1)
label variable belief_mean_effort_miss "By treatment, average belief about effort if miss"

egen belief_mean_skill_reach = mean(belief_avg_skill_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_skill_reach_se = semean(belief_avg_skill_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_skill_reach_lb = belief_mean_skill_reach - 1.96*belief_mean_skill_reach_se
gen belief_mean_skill_reach_ub = belief_mean_skill_reach + 1.96*belief_mean_skill_reach_se
replace belief_mean_skill_reach=round(belief_mean_skill_reach,0.1)
label variable belief_mean_skill_reach "By treatment, average belief about skill if reach"

egen belief_mean_skill_miss = mean(belief_avg_skill_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_skill_miss_se = semean(belief_avg_skill_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_skill_miss_lb = belief_mean_skill_miss - 1.96*belief_mean_skill_miss_se
gen belief_mean_skill_miss_ub = belief_mean_skill_miss + 1.96*belief_mean_skill_miss_se
replace belief_mean_skill_miss=round(belief_mean_skill_miss,0.1)
label variable belief_mean_skill_miss "By treatment, average belief about skill if miss"

egen belief_mean_capital_reach = mean(belief_avg_capital_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_capital_reach_se = semean(belief_avg_capital_reach) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_capital_reach_lb = belief_mean_capital_reach - 1.96*belief_mean_capital_reach_se
gen belief_mean_capital_reach_ub = belief_mean_capital_reach + 1.96*belief_mean_capital_reach_se
replace belief_mean_capital_reach=round(belief_mean_capital_reach,1)
label variable belief_mean_capital_reach "By treatment, average belief about capital if reach"

egen belief_mean_capital_miss = mean(belief_avg_capital_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
egen belief_mean_capital_miss_se = semean(belief_avg_capital_miss) if effort_task==1 & belief_elicitation==1, by(treatment)
gen belief_mean_capital_miss_lb = belief_mean_capital_miss - 1.96*belief_mean_capital_miss_se
gen belief_mean_capital_miss_ub = belief_mean_capital_miss + 1.96*belief_mean_capital_miss_se
replace belief_mean_capital_miss=round(belief_mean_capital_miss,1)
label variable belief_mean_capital_miss "By treatment, average belief about capital if miss"

*difference in beliefs about capital and effort between those who reach and those who miss for each participant
gen diff_capital= belief_avg_capital_reach- belief_avg_capital_miss
label variable diff_capital "Capital reach - capital miss (belief)"
gen diff_effort= belief_avg_effort_reach- belief_avg_effort_miss
label variable diff_effort "Effort reach - Effort miss (belief)"
egen diff_belief_effort_for_graph=mean(diff_effort) if treatment==2 & belief_elicitation==1
egen diff_belief_capital_for_graph=mean(diff_capital) if treatment==2 & belief_elicitation==1

scatter diff_effort diff_capital if treatment==2 & belief_elicitation==1, mlabsize(small) msymbol(circle) ///
|| scatter diff_belief_effort_for_graph diff_belief_capital_for_graph, mlabsize(small) mcolor(red) msymbol(T) ///
|| scatter difference_effort_for_graph difference_capital_for_graph, mlabsize(small) mcolor(orange) msymbol(D) ///
title(Beliefs Conditional on Outcome) subtitle(Belief that workers who succeed have on average:) ylabel(-150(50)150) ///
ytitle(E[Effort|Success] - E[Effort|Failure]) yline(0, lcolor(red)) xline(0, lcolor(red)) xtitle(E[Circumstances|Success] - E[Circumstances|Failure]) xlabel(-1500(500)1500) plotregion(margin(large)) scheme(cblind1) legend(label (1 "Individual beliefs") label (2 "Average belief") label (3 "Truth")) ///
text(245 100 "Better circumst. and exert more effort", place(se) box bcolor(gs15) just(left) margin(l+2 t+1 b+1) width(58)) ///
text(-150 100 "Better circumst. and exert less effort", place(se) box bcolor(gs15) just(left) margin(l+2 t+1 b+1) width(58)) ///
text(245 -1650 "Worse circumst. and exert more effort", place(se) box bcolor(gs15) just(left) margin(l+2 t+1 b+1) width(58)) ///
text(-150 -1650 "Worse circumst. and exert less effort", place(se) box bcolor(gs15) just(left) margin(l+2 t+1 b+1) width(58))
graph export "Difference in beliefs reach vs miss.eps", as(eps) preview(off) replace
!epstopdf "Difference in beliefs reach vs miss.eps"

*graph of effort only
sort treatment
graph twoway connected mean_effort2 treatment, mlabsize(small) mlabel(mean_effort2) mlabposition(12) mlabcolor(navy) lcolor(navy) lwidth(thin) mcolor(navy) ///
||connected mean_effort treatment if target_is_reached==1, mlabsize(small) mlabel(mean_effort) mlabposition(12) mlabcolor(green) lwidth(thin) lcolor(green) mcolor(green) ///
||connected mean_effort treatment if target_is_reached==0, mlabsize(small) mlabel(mean_effort) mlabposition(6) mlabcolor(maroon) lwidth(thin) lcolor(maroon) mcolor(maroon) ///
 title(Average effort by treatment) subtitle() ytitle(Effort) ylabel(150(50)250) xtitle("") xlabel(0 "Identical capital - High skill" 1 "Identical - Low" 2 "Hetero - Low") ///
 graphregion(color(white)) legend(label (1 "All participants") label (2 "Reach") label (3 "Miss")) plotregion(margin(large)) scheme(cblind1)
graph export "Average effort by treatment_no belief.eps", as(eps) preview(off) replace
!epstopdf "Average effort by treatment_no belief.eps"

*graph of effort and effort beliefs
sort treatment
graph twoway connected mean_effort treatment if target_is_reached==1, mlabsize(small) mlabel(mean_effort) mlabposition(12) mlabcolor(green) lcolor(green) lwidth(thin) mcolor(green) ///
||connected mean_effort treatment if target_is_reached==0, mlabsize(small) mlabel(mean_effort) mlabposition(12) mlabgap(*1) mlabcolor(maroon) lcolor(maroon) lwidth(thin) mcolor(maroon) ///
||connected belief_mean_effort_reach treatment if target_is_reached==1, mlabsize(small) mlabel(belief_mean_effort_reach) msymbol(D) mlabposition(12) mlabgap(*1) lwidth(thin) mlabcolor(green) lpattern(dash) lcolor(green) mcolor(green) ///
||connected belief_mean_effort_miss treatment if target_is_reached==0, mlabsize(small) mlabel(belief_mean_effort_miss)  msymbol(D) mlabposition(12) mlabgap(*1) mlabcolor(maroon) lwidth(thin) lpattern(dash) lcolor(maroon) mcolor(maroon) ///
 title(Average effort and expected effort) subtitle(by treament) ytitle(Effort) ylabel(150(50)250) xtitle(" ") xlabel(0 "Identical capital - High skill" 1 "Identical - Low" 2 "Hetero - Low") ///
 graphregion(color(white)) legend(label (1 "Reach") label (2 "Miss") label (3 "Belief about effort: reach") label (4 "Belief about effort: miss")) legend(symxsize(*3)) plotregion(margin(large)) scheme(cblind1)
graph export "Average effort by treatment.eps", as(eps) preview(off) replace
!epstopdf "Average effort by treatment.eps"

*graph of skill and skill beliefs
sort treatment
graph twoway connected mean_skill treatment if target_is_reached==1, mlabsize(small) mlabel(mean_skill) mlabposition(12) mlabgap(*2) lwidth(thin) mlabcolor(green) lcolor(green) mcolor(green) ///
||connected mean_skill treatment if target_is_reached==0,mlabsize(small) mlabel(mean_skill) mlabposition(6) mlabgap(*1) mlabcolor(maroon) lwidth(thin) lcolor(maroon) mcolor(maroon) ///
||connected belief_mean_skill_reach treatment if target_is_reached==1,mlabsize(small) mlabel(belief_mean_skill_reach) msymbol(d) mlabposition(6) mlabgap(*1) lwidth(thin) mlabcolor(green) lpattern(dash) lcolor(green) mcolor(green) ///
||connected belief_mean_skill_miss treatment if target_is_reached==0,mlabsize(small) mlabel(belief_mean_skill_miss) msymbol(d) mlabposition(12) mlabgap(*1) lwidth(thin) mlabcolor(maroon) lpattern(dash) lcolor(maroon) mcolor(maroon) ///
 title(Average skill and expected skill) subtitle(by treament) ytitle(Skill) ylabel(4(2)12) xtitle("") xlabel(0 "Identical capital - High skill" 1 "Identical - Low" 2 "Hetero - Low") ///
 graphregion(color(white)) legend(label (1 "Reach") label (2 "Miss") label (3 "Belief about skill: reach") label (4 "Belief about skill: miss")) legend(symxsize(*3)) plotregion(margin(large)) scheme(cblind1)
 graph export "Average skill by treatment.eps", as(eps) preview(off) replace
!epstopdf "Average skill by treatment.eps"
 
*graph of capital and capital beliefs
scatter mean_capital treatment if target_is_reached==1 & treatment==2, mlabsize(small) msymbol(O) mlabel(mean_capital) mlabposition(12) mlabcolor(green) lcolor(green) mcolor(green) ///
||scatter mean_capital treatment if target_is_reached==0 & treatment==2, mlabsize(small) msymbol(Oh) mlabel(mean_capital) mlabposition(6) mlabcolor(maroon) lcolor(maroon) mcolor(maroon) ///
||scatter belief_mean_capital_reach treatment if target_is_reached==1 & treatment==2,mlabsize(small) msymbol(X) mlabel(belief_mean_capital_reach) mlabposition(6) mlabcolor(navy) lpattern(dash) lcolor(navy) mcolor(navy) ///
||scatter belief_mean_capital_miss treatment if target_is_reached==0 & treatment==2,mlabsize(small) msymbol(X) mlabel(belief_mean_capital_miss) mlabposition(12) mlabgap(*2) mlabcolor(black) lpattern(dash) lcolor(black) mcolor(black) ///
 title(Average capital and expected capital) subtitle() ytitle(Capital) ylabel(500(500)2000) xtitle("") xlabel(2 "Heterogeneous capital - Low skill", tlength(0)) ///
 graphregion(color(white)) legend(label (1 "Reach") label (2 "Miss") label (3 "Belief about capital: reach") label (4 "Belief about capital: miss")) plotregion(margin(large)) scheme(cblind1)
graph export "Average capital by treatment.eps", as(eps) preview(off) replace
!epstopdf "Average capital by treatment.eps"

*avg effort conditional on reaching/missing target  => //more effort for those who reach for all treatments
//206 vs 165
tab target_is_reached if effort_task==1 & current_treatment=="High-Low", su( num_correct )
//262 vs 158
tab target_is_reached if effort_task==1 & current_treatment=="Low-Low", su( num_correct )
 // 239 vs 167
tab target_is_reached if effort_task==1 & current_treatment=="Low-High", su( num_correct )
//test if people who reach do significanty more effort than people who miss
ttest num_correct if treatment==0 & effort_task==1, by(target_is_reached)
ttest num_correct if treatment==1 & effort_task==1, by(target_is_reached)
ttest num_correct if treatment==2 & effort_task==1, by(target_is_reached)
//ttest if among people who reach there is an significant effort difference across treatments
ttest num_correct if treatment!=0 & effort_task==1 & target_is_reached==1, by(treatment)
ttest num_correct if treatment!=1 & effort_task==1 & target_is_reached==1, by(treatment)
ttest num_correct if treatment!=2 & effort_task==1 & target_is_reached==1, by(treatment)
//ttest if among people who miss there is an significant effort difference across treatments
ttest num_correct if treatment!=0 & effort_task==1 & target_is_reached==0, by(treatment)
ttest num_correct if treatment!=1 & effort_task==1 & target_is_reached==0, by(treatment)
ttest num_correct if treatment!=2 & effort_task==1 & target_is_reached==0, by(treatment)

*avg skill conditional on reaching/missing target  => higher skill for those who reach for all treatments
//6.5 vs 3.8
tab target_is_reached if effort_task==1 & current_treatment=="High-Low", su( skill_draw )
//7.1 vs 2.6
tab target_is_reached if effort_task==1 & current_treatment=="Low-Low", su( skill_draw )
 //11.9 vs 6
tab target_is_reached if effort_task==1 & current_treatment=="Low-High", su( skill_draw )

//test if people who reach get higher skill than people who miss
ttest skill_draw if treatment==0 & effort_task==1, by(target_is_reached)
ttest skill_draw if treatment==1 & effort_task==1, by(target_is_reached)
ttest skill_draw if treatment==2 & effort_task==1, by(target_is_reached)
//ttest if among people who reach there is an significant skill difference across treatments
ttest skill_draw if treatment!=0 & effort_task==1 & target_is_reached==1, by(treatment)
ttest skill_draw if treatment!=1 & effort_task==1 & target_is_reached==1, by(treatment)
ttest skill_draw if treatment!=2 & effort_task==1 & target_is_reached==1, by(treatment)
//ttest if among people who miss there is an significant skill difference across treatments
ttest skill_draw if treatment!=0 & effort_task==1 & target_is_reached==0, by(treatment)
ttest skill_draw if treatment!=1 & effort_task==1 & target_is_reached==0, by(treatment)
ttest skill_draw if treatment!=2 & effort_task==1 & target_is_reached==0, by(treatment)

*avg capital draw conditional on reaching/missing target  => //higher capital for those who reach in variable capital treatment
//1683 vs 739
tab target_is_reached if effort_task==1 & current_treatment=="High-Low", su( capital_draw )

*******************************************************
*H1: Optimal effort comparative statics prediction i.e. decreasing in k_i and skill upper bound 
******************************************************
*H1a Drawing a higher capital decreases effort => seems true
// effort is slightly increasing in capital
corr capital_draw num_correct if effort_task==1 & treatment==2
corr capital_draw num_correct if effort_task==1 & treatment==2 & num_correct>0
corr capital_draw num_correct if effort_task==1 & treatment==2 & capital_draw>=2000
corr capital_draw num_correct if effort_task==1 & treatment==2 & capital_draw>=1250

//highest vs lowest quintile (i.e. 20%) 151 vs 183
su(num_correct) if capital_draw>=2000 & effort_task==1
su(num_correct) if capital_draw<=500 & effort_task==1

//let's plot effort conditional on capital_draw by quintile
egen effort_quintile=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500
egen effort_quintile2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>500
egen effort_quintile3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1000
egen effort_quintile4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1500
egen effort_quintile5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2000
gen quintile=effort_quintile if effort_task==1 & treatment==2 & capital_draw<=500
label variable quintile "Average effort"
replace quintile=effort_quintile2 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>500
replace quintile=effort_quintile3 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1000
replace quintile=effort_quintile4 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1500
replace quintile=effort_quintile5 if effort_task==1 & treatment==2 & capital_draw>2000
replace quintile=round(quintile,1)
gen quintile_categ=500 if effort_task==1 & treatment==2 & capital_draw<=500
replace quintile_categ=1000 if effort_task==1 & treatment==2 & capital_draw>500 & capital_draw<=1000
replace quintile_categ=1500 if effort_task==1 & treatment==2 & capital_draw>1000 & capital_draw<=1500
replace quintile_categ=2000 if effort_task==1 & treatment==2 & capital_draw>1500 & capital_draw<=2000
replace quintile_categ=2500 if effort_task==1 & treatment==2 & capital_draw>2000
//What is the %age of people who reach in each quintile?
tab quintile_categ if effort_task==1 & treatment==2, su(target_is_reached)
egen successrate_quintile = mean(target_is_reached) if effort_task==1 & treatment==2, by(quintile_categ)
replace successrate_quintile=round(successrate_quintile*100,.1)
label variable successrate_quintile "Success rate"

sort quintile_categ
graph twoway connected quintile quintile_categ,mlabel(quintile) mlabsize(small) mlabposition(6) mlabgap(*1) ///
|| connected successrate_quintile quintile_categ,mlabel(successrate_quintile) mlabsize(small) yaxis(2) mlabposition(6) ///
|| connected pos_quintile quintile_categ, lpattern(dash) ///
 title(Average Effort Conditional on Circumstances) subtitle(heterogeneous treatment) ylabel(100(50)250)  ytitle(Effort) ytitle(Success rate, axis(2)) ylabel(0(50)100, axis(2)) xtitle(Circumstances (by decile group)) xlabel(500 "Bottom 20%" 1000 " " 1500 "3rd quintile" 2000 " " 2500 "Top 20%") ///
 plotregion(margin(large)) scheme(cblind1)
graph export "Effort by quintile.eps", as(eps) preview(off) replace
!epstopdf "Effort by quintile.eps"

//let's plot effort conditional on capital_draw by quintile if effort is non zero

egen pos_effort_quintile=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & num_correct>0
egen pos_effort_quintile2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>500 & num_correct>0
egen pos_effort_quintile3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1000 & num_correct>0
egen pos_effort_quintile4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1500 & num_correct>0
egen pos_effort_quintile5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2000 & num_correct>0
gen pos_quintile=pos_effort_quintile if effort_task==1 & treatment==2 & capital_draw<=500 & num_correct>0
label variable pos_quintile "Average effort if effort non zero"
replace pos_quintile=pos_effort_quintile2 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>500  & num_correct>0
replace pos_quintile=pos_effort_quintile3 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1000  & num_correct>0
replace pos_quintile=pos_effort_quintile4 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1500  & num_correct>0
replace pos_quintile=pos_effort_quintile5 if effort_task==1 & treatment==2 & capital_draw>2000  & num_correct>0
replace pos_quintile=round(pos_quintile,1)
egen successrate_pos_quintile = mean(target_is_reached) if effort_task==1 & treatment==2 & num_correct>0, by(quintile_categ)
replace successrate_pos_quintile=round(successrate_pos_quintile*100,.1)
label variable successrate_pos_quintile "Success rate if effort non zero"

sort quintile_categ
graph twoway connected pos_quintile quintile_categ,mlabel(pos_quintile) mlabsize(small) mlabposition(12) mlabgap(*1.5) ///
|| connected successrate_pos_quintile quintile_categ,mlabel(successrate_pos_quintile) mlabsize(small) yaxis(2) mlabposition(6) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment - if Effort Different From 0) ylabel(100(50)250)  ytitle(Effort) ytitle(Success rate, axis(2)) ylabel(0(50)100, axis(2)) xtitle(Circumstances (by decile group)) xlabel(500 "Bottom 20% (-15)" 1000 "(-10)" 1500 "3rd quintile (-3)" 2000 " (-1) " 2500 "Top 20% (-1)") ///
 plotregion(margin(large)) scheme(cblind1)
graph export "Effort by quintile if effort non zero.eps", as(eps) preview(off) replace
!epstopdf "Effort by quintile if effort non zero.eps"
 
///let's plot by quartile
egen effort_quartile=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=(2500/4)
egen effort_quartile2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=(2500/2) & capital_draw>(2500/4)
egen effort_quartile3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=(3*2500/4) & capital_draw>(2500/2)
egen effort_quartile4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=(2500) & capital_draw>(3*2500/4)
gen quartile=effort_quartile if effort_task==1 & treatment==2 & capital_draw<=2500/4
label variable quartile "Average effort"
replace quartile=effort_quartile2 if effort_task==1 & treatment==2 & capital_draw<=(2*2500/4) & capital_draw>2500/4
replace quartile=effort_quartile3 if effort_task==1 & treatment==2 & capital_draw<=(3*2500/4) & capital_draw>2500/2
replace quartile=effort_quartile4 if effort_task==1 & treatment==2 & capital_draw<=(4*2500/4) & capital_draw>(3*2500/4)
replace quartile=round(quartile,1)
gen quartile_categ=625 if effort_task==1 & treatment==2 & capital_draw<=625
replace quartile_categ=1250 if effort_task==1 & treatment==2 & capital_draw>625 & capital_draw<=1250
replace quartile_categ=1875 if effort_task==1 & treatment==2 & capital_draw>1250 & capital_draw<=1875
replace quartile_categ=2500 if effort_task==1 & treatment==2 & capital_draw>1875 & capital_draw<=2500

egen successrate_quartile = mean(target_is_reached) if effort_task==1 & treatment==2, by(quartile_categ)
replace successrate_quartile=round(successrate_quartile*100,.1)
label variable successrate_quartile "Success rate"

sort quartile_categ
graph twoway connected quartile quartile_categ,mlabel(quartile) mlabsize(small) mlabposition(12) ///
|| connected successrate_quartile quartile_categ,mlabel(successrate_quartile) mlabsize(small) yaxis(2) mlabposition(6) ///
title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment) ytitle(Effort) ylabel(100(50)250) ytitle(Success rate, axis(2)) ylabel(0(50)100, axis(2)) xtitle(Circumstances range) xlabel(625 "Bottom 25%" 1250 "2d quartile" 1875 "3rd quartile" 2500 "Top 25%") ///
plotregion(margin(large)) scheme(cblind1)
graph export "Effort by quartile.eps", as(eps) preview(off) replace
!epstopdf "Effort by quartile.eps"

//What is the %age of people who reach in each quartile?
tab quartile_categ if effort_task==1 & treatment==2, su(target_is_reached)

///by decile
**********************************************************************************************
egen effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250
egen effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
egen effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
egen effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
egen effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
egen effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
egen effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
egen effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
egen effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
egen effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

egen effort_dec_sd=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250
egen effort_dec_sd2=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
egen effort_dec_sd3=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
egen effort_dec_sd4=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
egen effort_dec_sd5=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
egen effort_dec_sd6=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
egen effort_dec_sd7=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
egen effort_dec_sd8=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
egen effort_dec_sd9=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
egen effort_dec_sd10=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

egen effort_dec_n=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250
egen effort_dec_n2=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
egen effort_dec_n3=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
egen effort_dec_n4=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
egen effort_dec_n5=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
egen effort_dec_n6=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
egen effort_dec_n7=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
egen effort_dec_n8=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
egen effort_dec_n9=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
egen effort_dec_n10=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

gen effort_dec_lb = effort_dec - invttail(effort_dec_n-1,0.05)*(effort_dec_sd / sqrt(effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen effort_dec_lb2 = effort_dec2 - invttail(effort_dec_n2-1,0.05)*(effort_dec_sd2 / sqrt(effort_dec_n2))
gen effort_dec_lb3 = effort_dec3 - invttail(effort_dec_n3-1,0.05)*(effort_dec_sd3 / sqrt(effort_dec_n3))
gen effort_dec_lb4 = effort_dec4 - invttail(effort_dec_n4-1,0.05)*(effort_dec_sd4 / sqrt(effort_dec_n4))
gen effort_dec_lb5 = effort_dec5 - invttail(effort_dec_n5-1,0.05)*(effort_dec_sd5 / sqrt(effort_dec_n5))
gen effort_dec_lb6 = effort_dec6 - invttail(effort_dec_n6-1,0.05)*(effort_dec_sd6 / sqrt(effort_dec_n6))
gen effort_dec_lb7 = effort_dec7 - invttail(effort_dec_n7-1,0.05)*(effort_dec_sd7 / sqrt(effort_dec_n7))
gen effort_dec_lb8 = effort_dec8 - invttail(effort_dec_n8-1,0.05)*(effort_dec_sd8 / sqrt(effort_dec_n8))
gen effort_dec_lb9 = effort_dec9 - invttail(effort_dec_n9-1,0.05)*(effort_dec_sd9 / sqrt(effort_dec_n9))
gen effort_dec_lb10 = effort_dec10 - invttail(effort_dec_n10-1,0.05)*(effort_dec_sd10 / sqrt(effort_dec_n10))

gen effort_dec_ub = effort_dec + invttail(effort_dec_n-1,0.05)*(effort_dec_sd / sqrt(effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen effort_dec_ub2 = effort_dec2 + invttail(effort_dec_n2-1,0.05)*(effort_dec_sd2 / sqrt(effort_dec_n2))
gen effort_dec_ub3 = effort_dec3 + invttail(effort_dec_n3-1,0.05)*(effort_dec_sd3 / sqrt(effort_dec_n3))
gen effort_dec_ub4 = effort_dec4 + invttail(effort_dec_n4-1,0.05)*(effort_dec_sd4 / sqrt(effort_dec_n4))
gen effort_dec_ub5 = effort_dec5 + invttail(effort_dec_n5-1,0.05)*(effort_dec_sd5 / sqrt(effort_dec_n5))
gen effort_dec_ub6 = effort_dec6 + invttail(effort_dec_n6-1,0.05)*(effort_dec_sd6 / sqrt(effort_dec_n6))
gen effort_dec_ub7 = effort_dec7 + invttail(effort_dec_n7-1,0.05)*(effort_dec_sd7 / sqrt(effort_dec_n7))
gen effort_dec_ub8 = effort_dec8 + invttail(effort_dec_n8-1,0.05)*(effort_dec_sd8 / sqrt(effort_dec_n8))
gen effort_dec_ub9 = effort_dec9 + invttail(effort_dec_n9-1,0.05)*(effort_dec_sd9 / sqrt(effort_dec_n9))
gen effort_dec_ub10 = effort_dec10 + invttail(effort_dec_n10-1,0.05)*(effort_dec_sd10 / sqrt(effort_dec_n10))

gen dec=effort_dec if effort_task==1 & treatment==2 & capital_draw<=250
label variable dec "Average effort"
replace dec=effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace dec=effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace dec=effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace dec=effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace dec=effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace dec=effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace dec=effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace dec=effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace dec=effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250
replace dec=round(dec,1)

gen dec_ci_lb=effort_dec_lb if effort_task==1 & treatment==2 & capital_draw<=250
label variable dec_ci_lb "bounds"
replace dec_ci_lb=effort_dec_lb2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace dec_ci_lb=effort_dec_lb3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace dec_ci_lb=effort_dec_lb4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace dec_ci_lb=effort_dec_lb5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace dec_ci_lb=effort_dec_lb6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace dec_ci_lb=effort_dec_lb7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace dec_ci_lb=effort_dec_lb8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace dec_ci_lb=effort_dec_lb9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace dec_ci_lb=effort_dec_lb10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250
replace dec_ci_lb=round(dec_ci_lb,1)

gen dec_ci_ub=effort_dec_ub if effort_task==1 & treatment==2 & capital_draw<=250
label variable dec_ci_ub "90% confidence"
replace dec_ci_ub=effort_dec_ub2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace dec_ci_ub=effort_dec_ub3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace dec_ci_ub=effort_dec_ub4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace dec_ci_ub=effort_dec_ub5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace dec_ci_ub=effort_dec_ub6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace dec_ci_ub=effort_dec_ub7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace dec_ci_ub=effort_dec_ub8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace dec_ci_ub=effort_dec_ub9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace dec_ci_ub=effort_dec_ub10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250
replace dec_ci_ub=round(dec_ci_ub,1)

///check productivity (efficiency) and time spent (diligence) by decile
************************************
///note: efficiency measure already discard those with effort=0
egen efficiency_dec=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=250
egen efficiency_dec2=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
egen efficiency_dec3=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
egen efficiency_dec4=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
egen efficiency_dec5=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
egen efficiency_dec6=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
egen efficiency_dec7=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
egen efficiency_dec8=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
egen efficiency_dec9=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
egen efficiency_dec10=mean(efficiency) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

gen effic_dec=efficiency_dec if effort_task==1 & treatment==2 & capital_draw<=250
label variable efficiency_dec "Average efficiency"
replace effic_dec=efficiency_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace effic_dec=efficiency_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace effic_dec=efficiency_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace effic_dec=efficiency_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace effic_dec=efficiency_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace effic_dec=efficiency_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace effic_dec=efficiency_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace effic_dec=efficiency_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace effic_dec=efficiency_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250
replace effic_dec=round(effic_dec,0.01)

egen elapsed_dec=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=250
egen elapsed_dec2=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
egen elapsed_dec3=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
egen elapsed_dec4=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
egen elapsed_dec5=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
egen elapsed_dec6=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
egen elapsed_dec7=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
egen elapsed_dec8=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
egen elapsed_dec9=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
egen elapsed_dec10=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

gen timespent_dec=elapsed_dec if effort_task==1 & treatment==2 & capital_draw<=250
label variable timespent_dec "Average time spent per round"
replace timespent_dec=elapsed_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace timespent_dec=elapsed_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace timespent_dec=elapsed_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace timespent_dec=elapsed_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace timespent_dec=elapsed_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace timespent_dec=elapsed_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace timespent_dec=elapsed_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace timespent_dec=elapsed_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace timespent_dec=elapsed_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250
replace timespent_dec=round(timespent_dec,1)

egen pos_elapsed_dec=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
egen pos_elapsed_dec2=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
egen pos_elapsed_dec3=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
egen pos_elapsed_dec4=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
egen pos_elapsed_dec5=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
egen pos_elapsed_dec6=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
egen pos_elapsed_dec7=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
egen pos_elapsed_dec8=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
egen pos_elapsed_dec9=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
egen pos_elapsed_dec10=mean(elapsed_time) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0

gen pos_timespent_dec=pos_elapsed_dec if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
label variable pos_timespent_dec "Average time spent per round if effort non zero"
replace pos_timespent_dec=pos_elapsed_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
replace pos_timespent_dec=pos_elapsed_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0
replace pos_timespent_dec=round(pos_timespent_dec,1)

///Same thing but just if effort is positive
********************************************
egen pos_effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
egen pos_effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
egen pos_effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
egen pos_effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
egen pos_effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
egen pos_effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
egen pos_effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
egen pos_effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
egen pos_effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
egen pos_effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0

egen pos_effort_dec_sd=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
egen pos_effort_dec_sd2=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
egen pos_effort_dec_sd3=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
egen pos_effort_dec_sd4=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
egen pos_effort_dec_sd5=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
egen pos_effort_dec_sd6=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
egen pos_effort_dec_sd7=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
egen pos_effort_dec_sd8=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
egen pos_effort_dec_sd9=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
egen pos_effort_dec_sd10=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0

egen pos_effort_dec_n=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
egen pos_effort_dec_n2=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
egen pos_effort_dec_n3=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
egen pos_effort_dec_n4=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
egen pos_effort_dec_n5=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
egen pos_effort_dec_n6=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
egen pos_effort_dec_n7=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
egen pos_effort_dec_n8=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
egen pos_effort_dec_n9=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
egen pos_effort_dec_n10=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0

gen pos_effort_dec_lb = pos_effort_dec - invttail(pos_effort_dec_n-1,0.05)*(pos_effort_dec_sd / sqrt(pos_effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen pos_effort_dec_lb2 = pos_effort_dec2 - invttail(pos_effort_dec_n2-1,0.05)*(pos_effort_dec_sd2 / sqrt(pos_effort_dec_n2))
gen pos_effort_dec_lb3 = pos_effort_dec3 - invttail(pos_effort_dec_n3-1,0.05)*(pos_effort_dec_sd3 / sqrt(pos_effort_dec_n3))
gen pos_effort_dec_lb4 = pos_effort_dec4 - invttail(pos_effort_dec_n4-1,0.05)*(pos_effort_dec_sd4 / sqrt(pos_effort_dec_n4))
gen pos_effort_dec_lb5 = pos_effort_dec5 - invttail(pos_effort_dec_n5-1,0.05)*(pos_effort_dec_sd5 / sqrt(pos_effort_dec_n5))
gen pos_effort_dec_lb6 = pos_effort_dec6 - invttail(pos_effort_dec_n6-1,0.05)*(pos_effort_dec_sd6 / sqrt(pos_effort_dec_n6))
gen pos_effort_dec_lb7 = pos_effort_dec7 - invttail(pos_effort_dec_n7-1,0.05)*(pos_effort_dec_sd7 / sqrt(pos_effort_dec_n7))
gen pos_effort_dec_lb8 = pos_effort_dec8 - invttail(pos_effort_dec_n8-1,0.05)*(pos_effort_dec_sd8 / sqrt(pos_effort_dec_n8))
gen pos_effort_dec_lb9 = pos_effort_dec9 - invttail(pos_effort_dec_n9-1,0.05)*(pos_effort_dec_sd9 / sqrt(pos_effort_dec_n9))
gen pos_effort_dec_lb10 = pos_effort_dec10 - invttail(pos_effort_dec_n10-1,0.05)*(pos_effort_dec_sd10 / sqrt(pos_effort_dec_n10))

gen pos_effort_dec_ub = pos_effort_dec + invttail(pos_effort_dec_n-1,0.05)*(pos_effort_dec_sd / sqrt(pos_effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen pos_effort_dec_ub2 = pos_effort_dec2 + invttail(pos_effort_dec_n2-1,0.05)*(pos_effort_dec_sd2 / sqrt(pos_effort_dec_n2))
gen pos_effort_dec_ub3 = pos_effort_dec3 + invttail(pos_effort_dec_n3-1,0.05)*(pos_effort_dec_sd3 / sqrt(pos_effort_dec_n3))
gen pos_effort_dec_ub4 = pos_effort_dec4 + invttail(pos_effort_dec_n4-1,0.05)*(pos_effort_dec_sd4 / sqrt(pos_effort_dec_n4))
gen pos_effort_dec_ub5 = pos_effort_dec5 + invttail(pos_effort_dec_n5-1,0.05)*(pos_effort_dec_sd5 / sqrt(pos_effort_dec_n5))
gen pos_effort_dec_ub6 = pos_effort_dec6 + invttail(pos_effort_dec_n6-1,0.05)*(pos_effort_dec_sd6 / sqrt(pos_effort_dec_n6))
gen pos_effort_dec_ub7 = pos_effort_dec7 + invttail(pos_effort_dec_n7-1,0.05)*(pos_effort_dec_sd7 / sqrt(pos_effort_dec_n7))
gen pos_effort_dec_ub8 = pos_effort_dec8 + invttail(pos_effort_dec_n8-1,0.05)*(pos_effort_dec_sd8 / sqrt(pos_effort_dec_n8))
gen pos_effort_dec_ub9 = pos_effort_dec9 + invttail(pos_effort_dec_n9-1,0.05)*(pos_effort_dec_sd9 / sqrt(pos_effort_dec_n9))
gen pos_effort_dec_ub10 = pos_effort_dec10 + invttail(pos_effort_dec_n10-1,0.05)*(pos_effort_dec_sd10 / sqrt(pos_effort_dec_n10))

gen pos_dec=pos_effort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
label variable pos_dec "Average effort if effort non zero"
replace pos_dec=pos_effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
replace pos_dec=pos_effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
replace pos_dec=pos_effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
replace pos_dec=pos_effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
replace pos_dec=pos_effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
replace pos_dec=pos_effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
replace pos_dec=pos_effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
replace pos_dec=pos_effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
replace pos_dec=pos_effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0
replace pos_dec=round(pos_dec,1)

gen pos_dec_ci_lb=pos_effort_dec_lb if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
label variable pos_dec_ci_lb "bounds"
replace pos_dec_ci_lb=pos_effort_dec_lb2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
replace pos_dec_ci_lb=pos_effort_dec_lb10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0
replace pos_dec_ci_lb=round(pos_dec_ci_lb,1)

gen pos_dec_ci_ub=pos_effort_dec_ub if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>0
label variable pos_dec_ci_ub "90% confidence"
replace pos_dec_ci_ub=pos_effort_dec_ub2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>0
replace pos_dec_ci_ub=pos_effort_dec_ub10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>0
replace pos_dec_ci_ub=round(pos_dec_ci_ub,1)

gen dec_categ=250 if effort_task==1 & treatment==2 & capital_draw<=250
replace dec_categ=500 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250
replace dec_categ=750 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500
replace dec_categ=1000 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750
replace dec_categ=1250 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000
replace dec_categ=1500 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250
replace dec_categ=1750 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500
replace dec_categ=2000 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750
replace dec_categ=2250 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000
replace dec_categ=2500 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250

//if effort >5 or >10
****************************

egen postwo_effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>5
egen postwo_effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>5
egen postwo_effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>5
egen postwo_effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>5
egen postwo_effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>5
egen postwo_effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>5
egen postwo_effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>5
egen postwo_effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>5
egen postwo_effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>5
egen postwo_effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>5

gen postwo_dec=postwo_effort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>5
label variable postwo_dec "Average effort if effort >5"
replace postwo_dec=postwo_effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>5
replace postwo_dec=postwo_effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>5
replace postwo_dec=postwo_effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>5
replace postwo_dec=postwo_effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>5
replace postwo_dec=postwo_effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>5
replace postwo_dec=postwo_effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>5
replace postwo_dec=postwo_effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>5
replace postwo_dec=postwo_effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>5
replace postwo_dec=postwo_effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>5
replace postwo_dec=round(postwo_dec,1)

egen posthree_effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>10
egen posthree_effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>10
egen posthree_effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>10
egen posthree_effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>10
egen posthree_effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>10
egen posthree_effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>10
egen posthree_effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>10
egen posthree_effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>10
egen posthree_effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>10
egen posthree_effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>10

gen posthree_dec=posthree_effort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & num_correct>10
label variable posthree_dec "Average effort if effort >10"
replace posthree_dec=posthree_effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & num_correct>10
replace posthree_dec=posthree_effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & num_correct>10
replace posthree_dec=posthree_effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & num_correct>10
replace posthree_dec=posthree_effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & num_correct>10
replace posthree_dec=posthree_effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & num_correct>10
replace posthree_dec=posthree_effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & num_correct>10
replace posthree_dec=posthree_effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & num_correct>10
replace posthree_dec=posthree_effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & num_correct>10
replace posthree_dec=posthree_effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & num_correct>10
replace posthree_dec=round(posthree_dec,1)

//if pba success>0
*********************

egen pospba_effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & pba_success>0
egen pospba_effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & pba_success>0
egen pospba_effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & pba_success>0
egen pospba_effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & pba_success>0
egen pospba_effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & pba_success>0
egen pospba_effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & pba_success>0
egen pospba_effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & pba_success>0
egen pospba_effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & pba_success>0
egen pospba_effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & pba_success>0
egen pospba_effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & pba_success>0


gen pospba_dec=pospba_effort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & pba_success>0
label variable pospba_dec "Average effort if positive probability of success"
replace pospba_dec=pospba_effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & pba_success>0
replace pospba_dec=pospba_effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & pba_success>0
replace pospba_dec=pospba_effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & pba_success>0
replace pospba_dec=pospba_effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & pba_success>0
replace pospba_dec=pospba_effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & pba_success>0
replace pospba_dec=pospba_effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & pba_success>0
replace pospba_dec=pospba_effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & pba_success>0
replace pospba_dec=pospba_effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & pba_success>0
replace pospba_dec=pospba_effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & pba_success>0
replace pospba_dec=round(pospba_dec,1)

//if effort is rational
************************

egen rational_effort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
egen rational_effort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
egen rational_effort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
egen rational_effort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
egen rational_effort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
egen rational_effort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
egen rational_effort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
egen rational_effort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
egen rational_effort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
egen rational_effort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1

egen rational_effort_dec_sd=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
egen rational_effort_dec_sd2=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
egen rational_effort_dec_sd3=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
egen rational_effort_dec_sd4=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
egen rational_effort_dec_sd5=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
egen rational_effort_dec_sd6=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
egen rational_effort_dec_sd7=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
egen rational_effort_dec_sd8=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
egen rational_effort_dec_sd9=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
egen rational_effort_dec_sd10=sd(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1

egen rational_effort_dec_n=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
egen rational_effort_dec_n2=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
egen rational_effort_dec_n3=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
egen rational_effort_dec_n4=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
egen rational_effort_dec_n5=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
egen rational_effort_dec_n6=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
egen rational_effort_dec_n7=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
egen rational_effort_dec_n8=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
egen rational_effort_dec_n9=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
egen rational_effort_dec_n10=count(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1

gen rational_effort_dec_lb = rational_effort_dec - invttail(rational_effort_dec_n-1,0.05)*(rational_effort_dec_sd / sqrt(rational_effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen rational_effort_dec_lb2 = rational_effort_dec2 - invttail(rational_effort_dec_n2-1,0.05)*(rational_effort_dec_sd2 / sqrt(rational_effort_dec_n2))
gen rational_effort_dec_lb3 = rational_effort_dec3 - invttail(rational_effort_dec_n3-1,0.05)*(rational_effort_dec_sd3 / sqrt(rational_effort_dec_n3))
gen rational_effort_dec_lb4 = rational_effort_dec4 - invttail(rational_effort_dec_n4-1,0.05)*(rational_effort_dec_sd4 / sqrt(rational_effort_dec_n4))
gen rational_effort_dec_lb5 = rational_effort_dec5 - invttail(rational_effort_dec_n5-1,0.05)*(rational_effort_dec_sd5 / sqrt(rational_effort_dec_n5))
gen rational_effort_dec_lb6 = rational_effort_dec6 - invttail(rational_effort_dec_n6-1,0.05)*(rational_effort_dec_sd6 / sqrt(rational_effort_dec_n6))
gen rational_effort_dec_lb7 = rational_effort_dec7 - invttail(rational_effort_dec_n7-1,0.05)*(rational_effort_dec_sd7 / sqrt(rational_effort_dec_n7))
gen rational_effort_dec_lb8 = rational_effort_dec8 - invttail(rational_effort_dec_n8-1,0.05)*(rational_effort_dec_sd8 / sqrt(rational_effort_dec_n8))
gen rational_effort_dec_lb9 = rational_effort_dec9 - invttail(rational_effort_dec_n9-1,0.05)*(rational_effort_dec_sd9 / sqrt(rational_effort_dec_n9))
gen rational_effort_dec_lb10 = rational_effort_dec10 - invttail(rational_effort_dec_n10-1,0.05)*(rational_effort_dec_sd10 / sqrt(rational_effort_dec_n10))

gen rational_effort_dec_ub = rational_effort_dec + invttail(rational_effort_dec_n-1,0.05)*(rational_effort_dec_sd / sqrt(rational_effort_dec_n)) //90%CI because 0.05 (put 0.025 if want 95% CI)
gen rational_effort_dec_ub2 = rational_effort_dec2 + invttail(rational_effort_dec_n2-1,0.05)*(rational_effort_dec_sd2 / sqrt(rational_effort_dec_n2))
gen rational_effort_dec_ub3 = rational_effort_dec3 + invttail(rational_effort_dec_n3-1,0.05)*(rational_effort_dec_sd3 / sqrt(rational_effort_dec_n3))
gen rational_effort_dec_ub4 = rational_effort_dec4 + invttail(rational_effort_dec_n4-1,0.05)*(rational_effort_dec_sd4 / sqrt(rational_effort_dec_n4))
gen rational_effort_dec_ub5 = rational_effort_dec5 + invttail(rational_effort_dec_n5-1,0.05)*(rational_effort_dec_sd5 / sqrt(rational_effort_dec_n5))
gen rational_effort_dec_ub6 = rational_effort_dec6 + invttail(rational_effort_dec_n6-1,0.05)*(rational_effort_dec_sd6 / sqrt(rational_effort_dec_n6))
gen rational_effort_dec_ub7 = rational_effort_dec7 + invttail(rational_effort_dec_n7-1,0.05)*(rational_effort_dec_sd7 / sqrt(rational_effort_dec_n7))
gen rational_effort_dec_ub8 = rational_effort_dec8 + invttail(rational_effort_dec_n8-1,0.05)*(rational_effort_dec_sd8 / sqrt(rational_effort_dec_n8))
gen rational_effort_dec_ub9 = rational_effort_dec9 + invttail(rational_effort_dec_n9-1,0.05)*(rational_effort_dec_sd9 / sqrt(rational_effort_dec_n9))
gen rational_effort_dec_ub10 = rational_effort_dec10 + invttail(rational_effort_dec_n10-1,0.05)*(rational_effort_dec_sd10 / sqrt(rational_effort_dec_n10))

gen rational_dec=rational_effort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
label variable rational_dec "Average effort if rational"
replace rational_dec=rational_effort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
replace rational_dec=rational_effort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
replace rational_dec=rational_effort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
replace rational_dec=rational_effort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
replace rational_dec=rational_effort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
replace rational_dec=rational_effort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
replace rational_dec=rational_effort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
replace rational_dec=rational_effort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
replace rational_dec=rational_effort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1
replace rational_dec=round(rational_dec,1)

gen rational_dec_ci_lb=rational_effort_dec_lb if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
label variable rational_dec_ci_lb "bounds"
replace rational_dec_ci_lb=rational_effort_dec_lb2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
replace rational_dec_ci_lb=rational_effort_dec_lb10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1
replace rational_dec_ci_lb=round(rational_dec_ci_lb,1)

gen rational_dec_ci_ub=rational_effort_dec_ub if effort_task==1 & treatment==2 & capital_draw<=250 & rational==1
label variable rational_dec_ci_ub "90% confidence"
replace rational_dec_ci_ub=rational_effort_dec_ub2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & rational==1
replace rational_dec_ci_ub=rational_effort_dec_ub10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & rational==1
replace rational_dec_ci_ub=round(rational_dec_ci_ub,1)

***graph with all efforts
sort dec_categ
graph twoway connected dec dec_categ, mlabel(dec) mlabposition(7) mlabgap(*0.3) ///
|| connected pos_dec dec_categ, mlabel(pos_dec) lpattern(dash) ///
|| connected postwo_dec dec_categ, mlabel(postwo_dec) lpattern(dash) ///
|| connected posthree_dec dec_categ, mlabel(posthree_dec) lpattern(dash) ///
|| connected pospba_dec dec_categ, mlabel(pospba_dec) lpattern(dash) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment) ytitle(Success rate) ytitle(Effort) ylabel(100(50)250) xtitle(Circumstances (by decile group)) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
 plotregion(margin(large)) scheme(cblind1)
 
 ***graph with all effort>0 (not demotivated) and pba success>0 (i.e. rational)
sort dec_categ
graph twoway connected dec dec_categ, mlabel(dec) mlabposition(6) mlabgap(*0.3) ///
|| connected pos_dec dec_categ, mlabel(pos_dec) lpattern(dash) ///
|| connected rational_dec dec_categ, mlabel(rational_dec) mlabposition(12) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment) ytitle(Success rate) ytitle(Effort) ylabel(100(50)250) xtitle(Circumstances (by decile group)) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
 plotregion(margin(large)) scheme(cblind1)
 
sort dec_categ
graph twoway rarea rational_dec_ci_ub rational_dec_ci_lb dec_categ, sort fcolor(lavender) fintensity(15) lcolor(lavender) lwidth(thin) lpattern(shortdash) ///
|| connected rational_dec dec_categ, mlabel(rational_dec) mlabsize(2.35) mlabposition(1) mlabgap(*1.2) mcolor(lavender) lcolor(lavender) ///
|| connected pos_dec dec_categ, mlabposition(12) lcolor(gs10) mcolor(gs10) lpattern(dash) ///
|| connected dec dec_categ, lcolor(orange) mcolor(orange) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment) legend(order(2 3 4) label (4 "Average effort") label(2 "Average effort if effort rational (90% confidence bounds)") label (3 "Average effort if effort non zero")) ytitle(Effort) ylabel(100(100)300) xtitle(Circumstances (by decile group)) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
 plotregion(margin(large)) scheme(cblind1)
 graph export "Average effort if effort rational.eps", as(eps) preview(off) replace
!epstopdf "Average effort if effort rational.eps"

*******************************************************

tab dec_categ, su(dec) //Average effort by decile
tab dec_categ, su(pos_dec) // average effort by decile only if effort was positive

//What is the %age of people who reach in each decile?
tab dec_categ if effort_task==1 & treatment==2, su(target_is_reached)
tab dec_categ if effort_task==1 & treatment==2, su(skill_draw) // check the effect of skill draw on success rate

egen successrate_dec = mean(target_is_reached) if effort_task==1 & treatment==2, by(dec_categ)
replace successrate_dec=round(successrate_dec*100,.1)
tab successrate_dec
label variable successrate_dec "Success rate"

egen successrate_posdec = mean(target_is_reached) if effort_task==1 & treatment==2 & num_correct!=0, by(dec_categ)
replace successrate_posdec=round(successrate_posdec*100,.1)
tab successrate_posdec
label variable successrate_posdec "Success rate if effort non zero"

egen successrate_rationaldec = mean(target_is_reached) if effort_task==1 & treatment==2 & rational==1, by(dec_categ)
replace successrate_rationaldec=round(successrate_rationaldec*100,.1)
tab successrate_rationaldec
label variable successrate_rationaldec "Success rate if effort rational"

sort dec_categ
graph twoway connected dec dec_categ, mlabel(dec) mlabposition(7) mlabgap(*0.3) ///
|| connected successrate_dec dec_categ,mlabel(successrate_dec) yaxis(2) mlabposition(6) ///
|| connected pos_dec dec_categ, lpattern(dash) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment) ytitle(Effort) ylabel(50(50)250) ytitle(Success rate, axis(2)) ylabel(0 50 100, axis(2)) xtitle(Circumstances range) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
 plotregion(margin(large)) scheme(cblind1)
 graph export "Effort by decile.eps", as(eps) preview(off) replace
!epstopdf "Effort by decile.eps"

sort dec_categ
graph twoway connected pos_dec dec_categ, mlabel(pos_dec) mlabposition(12) mlabgap(*1.5) ///
|| connected successrate_posdec dec_categ, mlabel(successrate_posdec) yaxis(2) mlabposition(6) ///
 title(Average Effort Conditional on Circumstances) subtitle(Heterogeneous Treatment - If Effort Different From 0) ytitle(Effort) ylabel(50(50)250) ytitle(Success rate, axis(2)) ylabel(0 50 100, axis(2)) xtitle(Circumstances range) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
 plotregion(margin(large)) scheme(cblind1)
 graph export "Effort by decile if effort non zero.eps", as(eps) preview(off) replace
!epstopdf "Effort by decile if effort non zero.eps"

//Do people who succeed to less effort than those who fail?
egen wineffort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==1 & num_correct>0
egen wineffort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==1 & num_correct>0
egen wineffort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==1 & num_correct>0
egen wineffort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==1 & num_correct>0
egen wineffort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==1 & num_correct>0
egen wineffort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==1 & num_correct>0
egen wineffort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==1 & num_correct>0
egen wineffort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==1 & num_correct>0
egen wineffort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==1 & num_correct>0
egen wineffort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==1 & num_correct>0

gen windec=wineffort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==1 & num_correct>0
label variable windec "Avg positive effort if reach"
replace windec=wineffort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==1 & num_correct>0
replace windec=wineffort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==1 & num_correct>0
replace windec=round(windec,1)

egen loseffort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==0 & num_correct>0
egen loseffort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==0 & num_correct>0
egen loseffort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==0 & num_correct>0
egen loseffort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==0 & num_correct>0
egen loseffort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==0 & num_correct>0
egen loseffort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==0 & num_correct>0
egen loseffort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==0 & num_correct>0
egen loseffort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==0 & num_correct>0
egen loseffort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==0 & num_correct>0
egen loseffort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==0 & num_correct>0

gen losdec=loseffort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==0 & num_correct>0
label variable losdec "Avg positive effort if miss"
replace losdec=loseffort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==0 & num_correct>0
replace losdec=loseffort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==0 & num_correct>0
replace losdec=round(losdec,1)

egen rationalwineffort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==1 & rational==1
egen rationalwineffort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==1 & rational==1
egen rationalwineffort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==1 & rational==1
egen rationalwineffort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==1 & rational==1
egen rationalwineffort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==1 & rational==1
egen rationalwineffort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==1 & rational==1
egen rationalwineffort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==1 & rational==1
egen rationalwineffort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==1 & rational==1
egen rationalwineffort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==1 & rational==1
egen rationalwineffort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==1 & rational==1

gen rationalwindec=rationalwineffort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==1 & rational==1
label variable rationalwindec "Avg rational effort if reach"
replace rationalwindec=rationalwineffort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==1 & rational==1
replace rationalwindec=rationalwineffort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==1 & rational==1
replace rationalwindec=round(rationalwindec,1)

egen rationalloseffort_dec=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==0 & rational==1
egen rationalloseffort_dec2=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==0 & rational==1
egen rationalloseffort_dec3=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==0 & rational==1
egen rationalloseffort_dec4=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==0 & rational==1
egen rationalloseffort_dec5=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==0 & rational==1
egen rationalloseffort_dec6=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==0 & rational==1
egen rationalloseffort_dec7=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==0 & rational==1
egen rationalloseffort_dec8=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==0 & rational==1
egen rationalloseffort_dec9=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==0 & rational==1
egen rationalloseffort_dec10=mean(num_correct) if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==0 & rational==1

gen rationallosdec=rationalloseffort_dec if effort_task==1 & treatment==2 & capital_draw<=250 & target_is_reached==0 & rational==1
label variable rationallosdec "Avg rational effort if reach"
replace rationallosdec=rationalloseffort_dec2 if effort_task==1 & treatment==2 & capital_draw<=500 & capital_draw>250 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec3 if effort_task==1 & treatment==2 & capital_draw<=750 & capital_draw>500 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec4 if effort_task==1 & treatment==2 & capital_draw<=1000 & capital_draw>750 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec5 if effort_task==1 & treatment==2 & capital_draw<=1250 & capital_draw>1000 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec6 if effort_task==1 & treatment==2 & capital_draw<=1500 & capital_draw>1250 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec7 if effort_task==1 & treatment==2 & capital_draw<=1750 & capital_draw>1500 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec8 if effort_task==1 & treatment==2 & capital_draw<=2000 & capital_draw>1750 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec9 if effort_task==1 & treatment==2 & capital_draw<=2250 & capital_draw>2000 & target_is_reached==0 & rational==1
replace rationallosdec=rationalloseffort_dec10 if effort_task==1 & treatment==2 & capital_draw<=2500 & capital_draw>2250 & target_is_reached==0 & rational==1
replace rationallosdec=round(rationallosdec,1)

sort dec_categ
graph twoway connected windec dec_categ,mlabel(windec) mlabposition(12) lcolor(green) mcolor(green) ///
|| connected losdec dec_categ,mlabel(losdec) mlabposition(6) lcolor(maroon) mcolor(maroon) ///
|| connected rationalwindec dec_categ,mlabel(rationalwindec) mlabposition(12) lcolor(green) mcolor(green) lpattern(dash) ///
|| connected rationallosdec dec_categ,mlabel(rationallosdec) mlabposition(6) lcolor(maroon) mcolor(maroon) lpattern(dash) ///
title(Average Effort Conditional on Outcome) subtitle(If Effort is Non Zero) ytitle(Effort) ylabel(50(50)250) xtitle(Circumstances range) xlabel(250 "Bottom 10%" 500 " " 750 " " 1000 " " 1250 " " 1500 " " 1750" " 2000 " " 2250 " " 2500 "Top 10%") ///
plotregion(margin(large)) scheme(cblind1)
graph export "Effort by decile conditional on outcome if effort non zero.eps", as(eps) preview(off) replace
!epstopdf "Effort by decile conditional on outcome if effort non zero.eps"

//What is the capital draw of people who do 0 effort in the Hetero treatment?
tab capital_draw if num_correct==0 & effort_task==1 & treatment==2

*****************************************************************************

////highest vs lowest decile (i.e. 10%)  101 vs 187
su(num_correct) if capital_draw>=2250 & effort_task==1
su(num_correct) if capital_draw<=250 & effort_task==1

 //highest vs lowest half
su(num_correct) if capital_draw>1250
su(num_correct) if capital_draw>1250

*H1b: Effort should be **lower** in High skill treatment compared to low skill => not true
//effort seem significantly lower in variable capital treatment + it seems like the opposite i.e avg effort is higher in Low-High vs Low-Low treatment
tab current_treatment if effort_task==1, su( num_correct )

***************************************************
*H2: Inferences
*In variable capital treatment, expected capital conditional on success increases and the expected effort decreases. 
*When capital is fixed, success is attributed to effort in Low skill treatment, and to skill in High skill
******************************************************
*In variable treatment, expected capital conditional on success is much higher (1454) than conditional on failure (770) 
ttest belief_avg_capital_miss == belief_avg_capital_reach if belief_elicitation==1 & current_treatment=="High-Low"

*But expected effort conditional on failure is lower than conditional on reaching
tab current_treatment if belief_elicitation==1, su(belief_avg_effort_reach)
tab current_treatment if belief_elicitation==1, su(belief_avg_effort_miss)
//True in general 
ttest belief_avg_effort_miss == belief_avg_effort_reach if belief_elicitation==1
//and for each treatment separately
ttest belief_avg_effort_miss == belief_avg_effort_reach if belief_elicitation==1 & current_treatment=="High-Low"
ttest belief_avg_effort_miss == belief_avg_effort_reach if belief_elicitation==1 & current_treatment=="Low-Low" 
ttest belief_avg_effort_miss == belief_avg_effort_reach if belief_elicitation==1 & current_treatment=="Low-High"

//ttest if there is a significant difference in beliefs about effort levels of people who reach/miss across treatments
ttest belief_avg_effort_reach if treatment!=0 & belief_elicitation==1, by(treatment)
ttest belief_avg_effort_reach if treatment!=1 & belief_elicitation==1, by(treatment)
ttest belief_avg_effort_reach if treatment!=2 & belief_elicitation==1, by(treatment)
ttest belief_avg_effort_miss if treatment!=0 & belief_elicitation==1, by(treatment)
ttest belief_avg_effort_miss if treatment!=1 & belief_elicitation==1, by(treatment)
ttest belief_avg_effort_miss if treatment!=2 & belief_elicitation==1, by(treatment)

*Expected skill conditional on failure is lower than conditional on reaching. True in general and for each treatment separately
tab current_treatment if belief_elicitation==1, su(belief_avg_skill_reach)
tab current_treatment if belief_elicitation==1, su(belief_avg_skill_miss)
ttest belief_avg_skill_miss == belief_avg_skill_reach if belief_elicitation==1
ttest belief_avg_skill_miss == belief_avg_skill_reach if belief_elicitation==1 & current_treatment=="High-Low"
ttest belief_avg_skill_miss == belief_avg_skill_reach if belief_elicitation==1 & current_treatment=="Low-Low" 
ttest belief_avg_skill_miss == belief_avg_skill_reach if belief_elicitation==1 & current_treatment=="Low-High"

//ttest if there is a significant difference in beliefs about effort levels of people who reach/miss across treatments
ttest belief_avg_skill_reach if treatment!=0 & belief_elicitation==1, by(treatment)
ttest belief_avg_skill_reach if treatment!=1 & belief_elicitation==1, by(treatment)
ttest belief_avg_skill_reach if treatment!=2 & belief_elicitation==1, by(treatment)
ttest belief_avg_skill_miss if treatment!=0 & belief_elicitation==1, by(treatment)
ttest belief_avg_skill_miss if treatment!=1 & belief_elicitation==1, by(treatment)
ttest belief_avg_skill_miss if treatment!=2 & belief_elicitation==1, by(treatment)

//ttest if among people who reach there is an significant effort difference across treatments
ttest num_correct if treatment!=0 & effort_task==1 & target_is_reached==1, by(treatment)
ttest num_correct if treatment!=1 & effort_task==1 & target_is_reached==1, by(treatment)
ttest num_correct if treatment!=2 & effort_task==1 & target_is_reached==1, by(treatment)

//ttest if people's outcome affect their beliefs
ttest belief_avg_effort_miss if treatment==0 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_effort_reach if treatment==0 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_effort_miss if treatment==1 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_effort_reach if treatment==1 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_effort_miss if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_effort_reach if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_miss if treatment==0 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_reach if treatment==0 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_miss if treatment==1 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_reach if treatment==1 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_miss if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_skill_reach if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_capital_miss if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)
ttest belief_avg_capital_reach if treatment==2 & effort_task==1 & belief_elicitation==1 , by(target_is_reached)

//Let's look at effort belief conditional on belief about capital draw
egen belief_effort_reach_quintile=mean(belief_avg_effort_reach) if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=500
egen belief_effort_reach_quintile2=mean(belief_avg_effort_reach) if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1000 & belief_avg_capital_reach>500
egen belief_effort_reach_quintile3=mean(belief_avg_effort_reach) if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1500 & belief_avg_capital_reach>1000
egen belief_effort_reach_quintile4=mean(belief_avg_effort_reach) if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=2000 & belief_avg_capital_reach>1500
egen belief_effort_reach_quintile5=mean(belief_avg_effort_reach) if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=2500 & belief_avg_capital_reach>2000

gen belief_reach_quintile=belief_effort_reach_quintile if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=500
label variable belief_reach_quintile "Average belief about effort of those who reach"
replace belief_reach_quintile=belief_effort_reach_quintile2 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1000 & belief_avg_capital_reach>500
replace belief_reach_quintile=belief_effort_reach_quintile3 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1500 & belief_avg_capital_reach>1000
replace belief_reach_quintile=belief_effort_reach_quintile4 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=2000 & belief_avg_capital_reach>1500
replace belief_reach_quintile=belief_effort_reach_quintile5 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach>2000
replace belief_reach_quintile=round(belief_reach_quintile,1)

gen belief_reach_quintile_categ=500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=500
replace belief_reach_quintile_categ=1000 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1000 & belief_avg_capital_reach>500
replace belief_reach_quintile_categ=1500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=1500 & belief_avg_capital_reach>1000
replace belief_reach_quintile_categ=2000 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach<=2000 & belief_avg_capital_reach>1500
replace belief_reach_quintile_categ=2500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_reach>2000
 
egen belief_effort_miss_quintile=mean(belief_avg_effort_miss) if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=500
egen belief_effort_miss_quintile2=mean(belief_avg_effort_miss) if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1000 & belief_avg_capital_miss>500
egen belief_effort_miss_quintile3=mean(belief_avg_effort_miss) if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1500 & belief_avg_capital_miss>1000
egen belief_effort_miss_quintile4=mean(belief_avg_effort_miss) if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=2000 & belief_avg_capital_miss>1500
egen belief_effort_miss_quintile5=mean(belief_avg_effort_miss) if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=2500 & belief_avg_capital_miss>2000

gen belief_miss_quintile=belief_effort_miss_quintile if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=500
label variable belief_miss_quintile "Average belief about effort of those who miss"
replace belief_miss_quintile=belief_effort_miss_quintile2 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1000 & belief_avg_capital_miss>500
replace belief_miss_quintile=belief_effort_miss_quintile3 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1500 & belief_avg_capital_miss>1000
replace belief_miss_quintile=belief_effort_miss_quintile4 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=2000 & belief_avg_capital_miss>1500
replace belief_miss_quintile=belief_effort_miss_quintile5 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss>2000
replace belief_miss_quintile=round(belief_miss_quintile,1)

gen belief_miss_quintile_categ=500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=500
replace belief_miss_quintile_categ=1000 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1000 & belief_avg_capital_miss>500
replace belief_miss_quintile_categ=1500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=1500 & belief_avg_capital_miss>1000
replace belief_miss_quintile_categ=2000 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss<=2000 & belief_avg_capital_miss>1500
replace belief_miss_quintile_categ=2500 if belief_elicitation==1 & treatment==2 & belief_avg_capital_miss>2000

scatter belief_miss_quintile belief_miss_quintile_categ,mlabel(belief_miss_quintile) mlabsize(small) msize(medlarge) ///
|| scatter belief_reach_quintile belief_reach_quintile_categ,mlabel(belief_reach_quintile) mlabsize(small) msize(medlarge) ///
 title(Expected effort conditional on expected capital) subtitle(heterogeneous treatment) ylabel(100(50)250)  ytitle(Belief about effort) xtitle(Belief about Circumstances range) xlabel(500 "Bottom 20%" 1000 " " 1500 "3rd quintile" 2000 " " 2500 "Top 20%") ///
 plotregion(margin(large)) scheme(cblind1)
 graph export "Effort belief conditional on capital belief by quintile.eps", as(eps) preview(off) replace
!epstopdf "Effort belief conditional on capital belief by quintile.eps"

//MORE IMPORTANT LET'S LOOK AT THE REDISTRIBUTION when people know the starting line
egen bel_effort_reach_pair_quintile=mean(effort_reach_pair1) if inlist(round_number,10,11) & capital_reach_pair1<=500
egen bel_effort_reach_pair_quintile2=mean(effort_reach_pair1) if inlist(round_number,10,11)  & capital_reach_pair1<=1000 & capital_reach_pair1>500
egen bel_effort_reach_pair_quintile3=mean(effort_reach_pair1) if inlist(round_number,10,11)  & capital_reach_pair1<=1500 & capital_reach_pair1>1000
egen bel_effort_reach_pair_quintile4=mean(effort_reach_pair1) if inlist(round_number,10,11) & capital_reach_pair1<=2000 & capital_reach_pair1>1500
egen bel_effort_reach_pair_quintile5=mean(effort_reach_pair1) if inlist(round_number,10,11)  & capital_reach_pair1<=2500 & capital_reach_pair1>2000

gen bel_reach_pair_quintile=bel_effort_reach_pair_quintile if inlist(round_number,10,11) & capital_reach_pair1<=500
label variable bel_reach_pair_quintile "Expected effort of winner in pair"
replace bel_reach_pair_quintile=bel_effort_reach_pair_quintile2 if inlist(round_number,10,11) & capital_reach_pair1<=1000 & capital_reach_pair1>500
replace bel_reach_pair_quintile=bel_effort_reach_pair_quintile3 if inlist(round_number,10,11) & capital_reach_pair1<=1500 & capital_reach_pair1>1000
replace bel_reach_pair_quintile=bel_effort_reach_pair_quintile4 if inlist(round_number,10,11) & capital_reach_pair1<=2000 & capital_reach_pair1>1500
replace bel_reach_pair_quintile=bel_effort_reach_pair_quintile5 if inlist(round_number,10,11) & capital_reach_pair1>2000
replace bel_reach_pair_quintile=round(bel_reach_pair_quintile,1)

gen bel_reach_pair_quintile_categ=500 if inlist(round_number,10,11) & capital_reach_pair1<=500
replace bel_reach_pair_quintile_categ=1000 if inlist(round_number,10,11) & capital_reach_pair1<=1000 & capital_reach_pair1>500
replace bel_reach_pair_quintile_categ=1500 if inlist(round_number,10,11) & capital_reach_pair1<=1500 & capital_reach_pair1>1000
replace bel_reach_pair_quintile_categ=2000 if inlist(round_number,10,11) & capital_reach_pair1<=2000 & capital_reach_pair1>1500
replace bel_reach_pair_quintile_categ=2500 if inlist(round_number,10,11) & capital_reach_pair1>2000
 
egen bel_effort_miss_pair_quintile=mean(effort_miss_pair1) if inlist(round_number,10,11) & capital_miss_pair1<=500
egen bel_effort_miss_pair_quintile2=mean(effort_miss_pair1) if inlist(round_number,10,11)  & capital_miss_pair1<=1000 & capital_miss_pair1>500
egen bel_effort_miss_pair_quintile3=mean(effort_miss_pair1) if inlist(round_number,10,11)  & capital_miss_pair1<=1500 & capital_miss_pair1>1000
egen bel_effort_miss_pair_quintile4=mean(effort_miss_pair1) if inlist(round_number,10,11) & capital_miss_pair1<=2000 & capital_miss_pair1>1500
egen bel_effort_miss_pair_quintile5=mean(effort_miss_pair1) if inlist(round_number,10,11)  & capital_miss_pair1<=2500 & capital_miss_pair1>2000

gen bel_miss_pair_quintile=bel_effort_miss_pair_quintile if inlist(round_number,10,11) & capital_miss_pair1<=500
label variable bel_miss_pair_quintile "Expected effort of loser in pair"
replace bel_miss_pair_quintile=bel_effort_miss_pair_quintile2 if inlist(round_number,10,11) & capital_miss_pair1<=1000 & capital_miss_pair1>500
replace bel_miss_pair_quintile=bel_effort_miss_pair_quintile3 if inlist(round_number,10,11) & capital_miss_pair1<=1500 & capital_miss_pair1>1000
replace bel_miss_pair_quintile=bel_effort_miss_pair_quintile4 if inlist(round_number,10,11) & capital_miss_pair1<=2000 & capital_miss_pair1>1500
replace bel_miss_pair_quintile=bel_effort_miss_pair_quintile5 if inlist(round_number,10,11) & capital_miss_pair1>2000
replace bel_miss_pair_quintile=round(bel_miss_pair_quintile,1)

gen bel_miss_pair_quintile_categ=500 if inlist(round_number,10,11) & capital_miss_pair1<=500
replace bel_miss_pair_quintile_categ=1000 if inlist(round_number,10,11) & capital_miss_pair1<=1000 & capital_miss_pair1>500
replace bel_miss_pair_quintile_categ=1500 if inlist(round_number,10,11) & capital_miss_pair1<=1500 & capital_miss_pair1>1000
replace bel_miss_pair_quintile_categ=2000 if inlist(round_number,10,11) & capital_miss_pair1<=2000 & capital_miss_pair1>1500
replace bel_miss_pair_quintile_categ=2500 if inlist(round_number,10,11) & capital_miss_pair1>2000

scatter bel_miss_pair_quintile bel_miss_pair_quintile_categ,mlabel(bel_miss_pair_quintile) mlabsize(small) mlabposition(6) msize(medlarge) ///
|| scatter bel_reach_pair_quintile bel_reach_pair_quintile_categ,mlabel(bel_reach_pair_quintile) mlabsize(small) mlabposition(12) msize(medlarge) ///
 title(Expected effort conditional on circumstances) subtitle(heterogeneous treatment) ylabel(100(50)250)  ytitle(Belief about effort) xtitle(Circumstances range) xlabel(500 "Bottom 20%" 1000 " " 1500 "3rd quintile" 2000 " " 2500 "Top 20%") ///
 plotregion(margin(large)) scheme(cblind1)
 graph export "Expected effort conditional on capital by quintile.eps", as(eps) preview(off) replace
!epstopdf "Expected effort conditional on capital by quintile.eps"

******************************************************
*Redistribution behavior stage 2
******************************************************
*Classify people by fairness pref
gen fairness_pref=1 if send_unlucky==0 & round_number==6 //libertarian
replace fairness_pref=2 if send_lazy==50 & send_unlucky==50 & round_number==6 //egalitarian
replace fairness_pref=3 if send_lazy<=49 & send_unlucky==50 & round_number==6 //merito
replace fairness_pref=4 if !inlist(fairness_pref,1,2,3) & round_number==6 
label variable fairness_pref "1:lib, 2:egal, 3:merit, 4:other"
qui bysort participant_id (round_number): replace fairness_pref=fairness_pref[6] if round_number>6

*Classify people by fairness pref Using Almas/Cappelen classification
gen fairness_pref_Alm=1 if send_unlucky==0 & round_number==6 //libertarian => same as me
replace fairness_pref_Alm=2 if send_lazy==50 & round_number==6 //egalitarian => split equally in effort
replace fairness_pref_Alm=3 if send_lazy<=49 & send_unlucky>=50 & round_number==6 //merito => more to best performer and at least as much to unlucky
replace fairness_pref_Alm=4 if !inlist(fairness_pref_Alm,1,2,3) & round_number==6 
label variable fairness_pref_Alm "1:lib, 2:egal, 3:merit, 4:other"
qui bysort participant_id (round_number): replace fairness_pref_Alm=fairness_pref_Alm[6] if round_number>6

//around 2/3rd of people split in half
tab(send_unlucky) if round_number==6
su(send_unlucky) if round_number==6, detail
 // half give more to best performer, around 1/3rd split equally.
tab(send_lazy) if round_number==6
su(send_lazy) if round_number==6, detail
*difference is significant i.e. people send more to unlucky, and also more to unlucky vs opportunity case
ttest send_lazy==send_unlucky if round_number==6
ttest send_unlucky==send_loser if inlist(round_number, 6,7,8)
//two together
twoway (hist send_unlucky if round_number==6, discrete width(10) percent lcolor(gs12)) ///
(hist send_lazy if round_number==6, discrete width(10) percent fcolor(none) lcolor(maroon)), ///
legend(off) xtitle("Share redistributed if income inequality due to luck (red: due to performance)") xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") ylabel(0(25)75) scheme(white_tableau)
graph export "Fairness pref stage2.eps", as(eps) preview(off) replace
!epstopdf "Fairness pref stage2.eps"

*Average redistribution when there inequality of opportunities
su send_loser if inlist(round_number, 6, 7, 8), detail
tab send_loser if inlist(round_number, 6, 7, 8)
su send_loser if inlist(round_number, 6, 7, 8) & treatment==0, detail
tab send_loser if inlist(round_number, 6, 7, 8) & treatment==0
su send_loser if inlist(round_number, 6, 7, 8) & treatment==1, detail
tab send_loser if inlist(round_number, 6, 7, 8) & treatment==1
su send_loser if inlist(round_number, 6, 7, 8) & treatment==2, detail
tab send_loser if inlist(round_number, 6, 7, 8) & treatment==2

*Let's look at redistribution by treatment => no difference
tab current_treatment if inlist(round_number, 6, 7, 8), su( send_loser )
ttest send_loser if inlist(round_number, 6, 7, 8) & treatment!=0, by(treatment)
ttest send_loser if inlist(round_number, 6, 7, 8) & treatment!=1, by(treatment)
ttest send_loser if inlist(round_number, 6, 7, 8) & treatment!=2, by(treatment)

hist send_loser if inlist(round_number, 6, 7, 8), discrete width(10) percent lcolor(gs12) legend(off) xtitle("Share redistributed") xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") ylabel(0(5)30) scheme(white_tableau)
graph export "Redist stage2.eps", as(eps) preview(off) replace
!epstopdf "Redist stage2.eps"

hist send_loser if inlist(round_number, 6, 7, 8) & treatment==0, discrete width(10) percent lcolor(gs12) subtitle(Identical-High) legend(off) xtitle("Share redistributed") xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") ylabel(0(5)30) scheme(white_tableau)
graph export "Redist stage2 IH.eps", as(eps) preview(off) replace
!epstopdf "Redist stage2 IH.eps"

hist send_loser if inlist(round_number, 6, 7, 8) & treatment==1, discrete width(10) percent lcolor(gs12) subtitle(Identical-Low) legend(off) xtitle("Share redistributed") xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") ylabel(0(5)30) scheme(white_tableau)
graph export "Redist stage2 IL.eps", as(eps) preview(off) replace
!epstopdf "Redist stage2 IL.eps"

hist send_loser if inlist(round_number, 6, 7, 8) & treatment==2, discrete width(10) percent lcolor(gs12) subtitle(Heterogenous-Low) legend(off) xtitle("Share redistributed") xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") ylabel(0(5)30) scheme(white_tableau)
graph export "Redist stage2 HL.eps", as(eps) preview(off) replace
!epstopdf "Redist stage2 HL.eps"

gen belief_ratio_capital= belief_avg_capital_reach/belief_avg_capital_miss if inlist(round_number, 6, 7, 8) & current_treatment=="High-Low"
gen belief_ratio_effort= belief_avg_effort_reach/belief_avg_effort_miss if inlist(round_number, 6, 7, 8)
gen belief_ratio_skill= belief_avg_skill_reach/belief_avg_skill_miss if inlist(round_number, 6, 7, 8)
label variable belief_ratio_capital "belief about avg capital reach/miss"
label variable belief_ratio_effort "belief about avg effort reach/miss"
label variable belief_ratio_skill "belief about avg skill reach/miss"
gen belief_diff_capital= (belief_avg_capital_reach-belief_avg_capital_miss)/100 if inlist(round_number, 6, 7, 8) & current_treatment=="High-Low"
gen belief_diff_effort= belief_avg_effort_reach-belief_avg_effort_miss if inlist(round_number, 6, 7, 8)
gen belief_diff_skill= belief_avg_skill_reach-belief_avg_skill_miss if inlist(round_number, 6, 7, 8)
label variable belief_diff_capital "belief about avg capital reach-miss"
label variable belief_diff_effort "belief about avg effort reach-miss"
label variable belief_diff_skill "belief about avg skill reach-miss"

*Generate a dummy=1 if redistribute to investigate extensive vs intensive margins
gen redistribute=1 if inlist(round_number,6,7,8)
replace redistribute=0 if inlist(round_number,6,7,8) & send_loser==0
label variable redistribute "dummy=1 if redistribute in stage 2"

*declare participant fixed effect and add rational belief for IH and IL treatment 
xtset participant_id
replace belief_avg_capital_reach=1250 if inlist(round_number, 6, 7 , 8) & treatment!=2
replace belief_avg_capital_miss=1250 if inlist(round_number, 6, 7 , 8) & treatment!=2
replace belief_diff_capital=0 if inlist(round_number, 6, 7 , 8) & treatment!=2
gen belief_avg_capital_reach2 = belief_avg_capital_reach/100
gen belief_avg_capital_miss2 = belief_avg_capital_miss/100
*Include a treatment dummy
xtreg send_loser belief_avg_skill_miss belief_avg_effort_miss belief_avg_skill_reach belief_avg_effort_reach belief_avg_capital_miss2 belief_avg_capital_reach2 send_lazy send_unlucky i.treatment if inlist(round_number, 6, 7 , 8), re vce(cluster participant_id )
xtreg send_loser belief_diff_effort belief_diff_skill belief_diff_capital send_lazy send_unlucky i.treatment if inlist(round_number, 6, 7 , 8), re vce(cluster participant_id )
xtreg send_loser belief_diff_effort belief_diff_skill belief_diff_capital send_lazy send_unlucky i.treatment if inlist(round_number, 6, 7 , 8) & !inlist(fairness_pref,1,2,4), re vce(cluster participant_id) //meritocrats only
xtreg send_loser belief_diff_effort belief_diff_skill belief_diff_capital send_lazy send_unlucky i.treatment if inlist(round_number, 6, 7 , 8) & !inlist(fairness_pref,1,2), re vce(cluster participant_id) // beliefs matters for non libertarians and non egalitarians
xtreg send_loser belief_diff_effort belief_diff_skill belief_diff_capital send_lazy send_unlucky i.treatment if inlist(round_number, 6, 7 , 8) & !inlist(fairness_pref,3,4), re vce(cluster participant_id) // beliefs don't matter for non meritocrats
*same without participant FE, with robust SE
reg send_loser belief_avg_skill_miss belief_avg_effort_miss belief_avg_capital_miss2 belief_avg_skill_reach belief_avg_effort_reach belief_avg_capital_reach2 send_lazy send_unlucky if inlist(round_number, 6, 7 , 8), robust
reg send_loser belief_diff_effort belief_diff_skill i.fairness_pref i.treatment if inlist(round_number,6,7,8), robust
//IH treatment
reg send_loser belief_diff_effort belief_diff_skill send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==0, robust
hettest //no heteroskedasticity
reg send_loser belief_avg_effort_reach belief_avg_effort_miss belief_avg_skill_reach belief_avg_skill_miss send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==0, robust
//IL treatment
reg send_loser belief_diff_effort belief_diff_skill send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==1, robust
reg send_loser belief_avg_effort_reach belief_avg_effort_miss belief_avg_skill_reach belief_avg_skill_miss send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==1, robust
//Hetero
reg send_loser belief_diff_effort belief_diff_skill belief_diff_capital send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==2, robust
reg send_loser belief_avg_effort_reach belief_avg_effort_miss belief_avg_skill_reach belief_avg_skill_miss belief_avg_capital_reach2 belief_avg_capital_miss2 send_unlucky send_lazy if inlist(round_number,6,7,8) & treatment==2, robust




************************************************************
*Redistribution behavior stage 3
************************************************************
*variables distance between capital reach and miss   + generate diff in beliefs also
gen diff_capital_pair1= capital_reach_pair1- capital_miss_pair1 if round_number==10|round_number==11
gen diff_capital_pair1_hundreds= (capital_reach_pair1- capital_miss_pair1)/100 if round_number==10|round_number==11
label variable diff_capital_pair1 "Distance capital reach - miss"
label variable diff_capital_pair1_hundreds "Distance capital reach - miss in hundreds"
gen diff_belief_effort_pair1= belief_effort_reach_pair1 - belief_effort_miss_pair1 if round_number==10|round_number==11
label variable diff_belief_effort_pair1 "Difference belief effort reach - miss"
gen diff_belief_skill_pair1= belief_skill_reach_pair1 - belief_skill_miss_pair1 if round_number==10|round_number==11
label variable diff_belief_skill_pair1 "Difference belief skill reach - miss"

*variables ratio between capital reach and miss - warning: ratio can have a lot of variance
gen ratio_capital_pair1= capital_reach_pair1/capital_miss_pair1 if round_number==10|round_number==11
label variable ratio_capital_pair1 "capital reach/miss"
*dummy if starting line of member who reach > miss
gen higher_capital_reach_pair1=1 if capital_reach_pair1>capital_miss_pair1
replace higher_capital_reach_pair1=0 if capital_reach_pair1< capital_miss_pair1
label variable higher_capital_reach_pair1 "dummy=1 if starting line reach > miss, 0 if SL miss>reach"
*distance target - warning: ratios can have a lot of variance
gen ratio_distance_to_target= (2500-capital_miss_pair1)/(2500-capital_reach_pair1)
gen ratio_distance_to_target2= (2500-capital_reach_pair1)/(2500-capital_miss_pair1)
label variable ratio_distance_to_target " T-capital miss / T-capital reach"
label variable ratio_distance_to_target2 " T-capital reach / T-capital miss"

*descriptive variables
//check that avg starting line reach>miss
su( capital_reach_pair1) if round_number==10|round_number==11
su( capital_miss_pair1) if round_number==10|round_number==11
su( effort_reach_pair1) if round_number==10|round_number==11
su( effort_miss_pair1) if round_number==10|round_number==11
su( skill_reach_pair1) if round_number==10|round_number==11
su( skill_miss_pair1) if round_number==10|round_number==11
su send_loser_pair1 if inlist(round_number, 10, 11), detail
tab(send_loser_pair1) if round_number==10|round_number==11
*beliefs about effort and skill
su( belief_effort_reach_pair1) if round_number==10|round_number==11
su( belief_effort_miss_pair1) if round_number==10|round_number==11
su( belief_skill_reach_pair1) if round_number==10|round_number==11
su( belief_skill_miss_pair1) if round_number==10|round_number==11

histogram send_loser_pair1 if round_number==10|round_number==11, discrete width(10) percent xlabel(0 "0" 20 "0.2" 40 "0.4" 60 "0.6" 80 "0.8" 100"1") lcolor(gs12) graphregion(color(white)) title(Redistribution) subtitle(Stage 3) xtitle("Share redistributed to member who missed") scheme(white_tableau)
graph export "Stage 3 histo.eps", as(eps) preview(off) replace
!epstopdf "Stage 3 histo.eps"

*Redistrib and beliefs in case where capital reach>capital miss
su send_loser_pair1 if higher_capital_reach_pair1==1, detail
tab send_loser_pair1 if higher_capital_reach_pair1==1
su( capital_reach_pair1) if higher_capital_reach_pair1==1
su( capital_miss_pair1) if higher_capital_reach_pair1==1
su( skill_reach_pair1) if higher_capital_reach_pair1==1
su( skill_miss_pair1) if higher_capital_reach_pair1==1
su( effort_reach_pair1) if higher_capital_reach_pair1==1
su( effort_miss_pair1) if higher_capital_reach_pair1==1
su( belief_effort_reach_pair1) if higher_capital_reach_pair1==1
su( belief_effort_miss_pair1) if higher_capital_reach_pair1==1
su( belief_skill_reach_pair1) if higher_capital_reach_pair1==1
su( belief_skill_miss_pair1) if higher_capital_reach_pair1==1

*Redistrib and beliefs in case where capital reach<capital miss
su send_loser_pair1 if higher_capital_reach_pair1==0, detail
tab send_loser_pair1 if higher_capital_reach_pair1==0 
su( capital_reach_pair1) if higher_capital_reach_pair1==0
su( capital_miss_pair1) if higher_capital_miss_pair1==0
su( skill_reach_pair1) if higher_capital_reach_pair1==0
su( skill_miss_pair1) if higher_capital_reach_pair1==0
su( belief_effort_reach_pair1) if higher_capital_reach_pair1==0
su( belief_effort_miss_pair1) if higher_capital_reach_pair1==0
su( belief_skill_reach_pair1) if higher_capital_reach_pair1==0
su( belief_skill_miss_pair1) if higher_capital_reach_pair1==0

*check if difference in beliefs are significant => yes
ttest belief_effort_miss_pair1=belief_effort_reach_pair1 if round_number==10|round_number==11
ttest belief_effort_miss_pair1=belief_effort_reach_pair1 if higher_capital_reach_pair1==1
ttest belief_effort_miss_pair1=belief_effort_reach_pair1 if higher_capital_reach_pair1==0

*Avg redistribution is much lower when winner started with worse circusmtances (highly significant)
ttest send_loser_pair1 if inlist(round_number,10,11), by(higher_capital_reach_pair1)

*beliefs about effort conditional on starting line and outcome
tab capital_reach_pair1 if round_number==10|round_number==11, su(belief_effort_reach_pair1)
tab capital_miss_pair1 if round_number==10|round_number==11, su(belief_effort_miss_pair1)

*compute pba success given belief about effort level and capital_draw
gen pba_success_reach_stg3=(10+1 - ceil((2500-capital_reach_pair1)/belief_effort_reach_pair1))/(10+1) if round_number==10|round_number==11
gen pba_success_miss_stg3=(10+1 - ceil((2500-capital_miss_pair1)/belief_effort_miss_pair1))/(10+1) if round_number==10|round_number==11
replace pba_success_miss_stg3=0 if belief_effort_miss_pair1==0 & round_number==10|round_number==11
scatter capital_reach_pair1 belief_effort_reach_pair1 if inlist(round_number,10,11), mlabsize(small)
scatter capital_miss_pair1 belief_effort_miss_pair1 if inlist(round_number,10,11), mlabsize(small)

*Regressions
xtset participant_id
xtreg send_loser_pair1 capital_reach_pair1 capital_miss_pair1 belief_skill_miss_pair1 belief_effort_miss_pair1 belief_skill_reach_pair1 belief_effort_reach_pair1 if round_number==10|round_number==11, re vce(cluster participant_id)
xtreg send_loser_pair1 ratio_capital_pair1 belief_skill_miss_pair1 belief_effort_miss_pair1 belief_skill_reach_pair1 belief_effort_reach_pair1 if round_number==10|round_number==11, re vce(cluster participant_id)
xtreg send_loser_pair1 ratio_distance_to_target belief_skill_miss_pair1 belief_effort_miss_pair1 belief_skill_reach_pair1 belief_effort_reach_pair1 if round_number==10|round_number==11, re vce(cluster participant_id)
*With difference in capital as DV => prefered specif
xtreg send_loser_pair1 diff_capital_pair1_hundreds belief_skill_miss_pair1 belief_effort_miss_pair1 belief_skill_reach_pair1 belief_effort_reach_pair1 send_lazy send_unlucky previous_outcome if round_number==10|round_number==11, re vce(cluster participant_id)
xtreg send_loser_pair1 diff_capital_pair1_hundreds send_lazy send_unlucky previous_outcome diff_belief_effort_pair1 diff_belief_skill_pair1 if inlist(round_number,10,11), re vce(cluster participant_id)
xtreg send_loser_pair1 diff_capital_pair1_hundreds send_lazy send_unlucky previous_outcome diff_belief_effort_pair1 diff_belief_skill_pair1 if inlist(round_number,10,11) & !inlist(fairness_pref,1,2), re vce(cluster participant_id) //excluding libertarians and egalitarians
*Looking at people's belief conditional on outcome AND circmstances
graph twoway (scatter belief_effort_reach_pair1 capital_reach_pair1)(lfit belief_effort_reach_pair1 capital_reach_pair1) if inlist(round_number,10,11)
graph twoway (scatter belief_effort_miss_pair1 capital_miss_pair1)(lfit belief_effort_miss_pair1 capital_miss_pair1) if inlist(round_number,10,11)


****************************************
*Find cost function
****************************************
gen optimal_effort=(2500- capital_draw)/20 if inlist(round_number, 1, 2, 3, 4, 5, 9) & treatment==0
replace optimal_effort=(2500- capital_draw)/10 if inlist(round_number, 1, 2, 3, 4, 5, 9) & treatment!=0

set trace on
forval i = 0(1000)10000	{
	display `i'
	gen effort`i'=(optimal_effort*`i')^(1/3)
	label var effort`i' "(optimal_effort*`i')^(1/3)"
	tab effort`i'
}
set trace off
forval i = 0(1000)10000	{
	drop effort`i'
}

gen indiv_cost=(100*1250)/((num_correct^3)*10) if effort_task==1 & treatment==1
// using IH treatment to estimate cost for subjects 31 & 83 who run out of time in their round 5 which was IL
replace indiv_cost=(100*1250)/((num_correct^3)*20) if effort_task==1 & treatment==0 & inlist(participant_id, 31, 83)
label var indiv_cost "Effort cost estimation based on IL treatment"
qui bysort participant_id (indiv_cost): replace indiv_cost=indiv_cost[1] if effort_task==1
tab participant_id if effort_task==1, su( indiv_cost )
gen effort_cutoff_prediction=(100*(2500-capital_draw)/(indiv_cost*10))^(1/3) if effort_task==1 & treatment==2
label var effort_cutoff_prediction "Predicted effort in Heterogenous treatment based on estimated cost"
tab effort_cutoff_prediction if effort_task==1 & treatment==2 & num_correct==0 //
gen pba_at_predicted_effort=(10+1 - ceil((2500-capital_draw)/effort_cutoff_prediction))/(10+1) if effort_task==1 & treatment==2 & effort_cutoff_prediction<=300
replace pba_at_predicted_effort=(10+1 - ceil((2500-capital_draw)/300))/(10+1) if effort_task==1 & treatment==2 & effort_cutoff_prediction>300

//Same but this time using the IH treatment as benchmark to estimate effort cost
gen indiv_cost2=(100*1250)/((num_correct^3)*20) if effort_task==1 & treatment==2
replace indiv_cost2=(100*1250)/((num_correct^3)*10) if effort_task==1 & treatment==0 & inlist(participant_id, 22, 66)
label var indiv_cost2 "Effort cost estimation based on IH treatment"
qui bysort participant_id (indiv_cost2): replace indiv_cost2=indiv_cost2[1] if effort_task==1
gen effort_cutoff_prediction2=(100*(2500-capital_draw)/(indiv_cost2*10))^(1/3) if effort_task==1 & treatment==2
gen pba_at_predicted_effort2=(10+1 - ceil((2500-capital_draw)/effort_cutoff_prediction2))/(10+1) if effort_task==1 & treatment==2 & effort_cutoff_prediction2<=300
replace pba_at_predicted_effort2=(10+1 - ceil((2500-capital_draw)/300))/(10+1) if effort_task==1 & treatment==2 & effort_cutoff_prediction2>300
************************************
*Analysis of demotivation
************************************
gen demotivated=1 if effort_task==1 & num_correct==0
label var demotivated "dummy=1 if zero effort"
replace demotivated=0 if effort_task==1 & num_correct!=0

gen capital_draw_rescaled = capital_draw/250 //gives us capital draw by decile
label var capital_draw_rescaled "circumstances: 1 unit=1 decile"
//logit with participant FE + clustered se
xtlogit demotivated capital_draw_rescaled i.round_number i.treatment previous_outcome if effort_task==1,re vce(cluster participant_id)
margins, dydx(capital_draw_rescaled)// Moving up one decile in the circumstances distribution decrease proba of no effort by -.0283159 

***********************************
* are people rational i.e. do they do effort to at least have a chance of success
**********************************
gen pba_success = (10+1 - ceil((2500-capital_draw)/num_correct))/(10+1) if effort_task==1 & treatment!=0 //using survivor function+ceil because discrete uniform
replace pba_success = (20+1 - ceil((2500-capital_draw)/num_correct))/(20+1) if effort_task==1 & treatment==0
replace pba_success = 0 if effort_task==1 & num_correct==0
*Do people who have 0% chance given effort level do it just once (mistake) or is it systematic (dynamic inconsistency)?
tab participant_id if pba_success<=0 & num_correct!=0 & time_binding!=1
tab pba_success if effort_task==1 & time_binding!=1 & num_correct!=0

*Classify as irrational: (positive effort but proba of success<=0) AND (demotivated but should have done positive effort)
gen rational=1 if effort_task==1
label var rational "dummy=1 if effort level is rational, 0 otherwise"
replace rational=0 if effort_task==1 & num_correct==0 & pba_at_predicted_effort>0
replace rational=0 if effort_task==1 & pba_success<=0 & num_correct!=0 & time_binding!=1

***********************************
* Investigating within subject effort level
sort capital_draw
graph twoway connected num_correct capital_draw if treatment!=0 & effort_task==1 & time_binding==0, mlabsize(small) by(participant_id)
*Just those who exert zero effort at some point:
graph twoway connected num_correct capital_draw if treatment!=0 & effort_task==1 & time_binding==0 & inlist(participant_id,2,5,13,30,31,39,42,45,46,59,60,64,65,69,71,75,79,82), mlabsize(small) by(participant_id)
*Just partcipants with decreasing effort profile
graph twoway connected num_correct capital_draw if treatment!=0 & effort_task==1 & time_binding==0 & inlist(participant_id,2,3,6,11,13,14,15,23,24,28,30,31,32,34,37,39,41,49,51,55,59,64,82,83,88), mlabsize(small) by(participant_id)

xtreg num_correct rational capital_draw pba_success i.round_number i.treatment if effort_task==1

xtreg num_correct capital_draw previous_outcome i.round_number i.treatment if effort_task==1 & capital_draw<1250, re vce(cluster participant_id)
xtreg num_correct capital_draw previous_outcome i.round_number i.treatment if effort_task==1 & capital_draw>=1250, re vce(cluster participant_id)


