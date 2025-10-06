clear all
a_both = 0.5;%share when both succeed
a_succeed = 0:0.1:1;%share when succeed alone
a_fail = 1-a_succeed;%share when fail alone
target = 1;
effort_1 = 0:0.05:1;
effort_2 = 0:0.05:1;
c_i = 1; %constant c(e) = c_i * (e_i^2/2) => c'(e_i)=c_i*e_i
reward = 1:1:2;
skill_lb = 0;
skill_ub = 1;
capital_mean = 0.5;
A=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
B=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
capital_spread_1 = 0;
capital_spread_2 = 0.1;
capital_spread_3 = 0.2;
capital_spread_4 = 0.3;
capital_spread_5 = 0.4;
capital_spread_6 = 0.45;
inequality = [0, 2*capital_spread_2, 2*capital_spread_3, 2*capital_spread_4, 2*capital_spread_5, 2*capital_spread_6];
capital_draw_1_S1 = (capital_mean - capital_spread_1):0.1:(capital_mean + capital_spread_1);
capital_draw_2_S1 = (capital_mean - capital_spread_1):0.1:(capital_mean + capital_spread_1);
capital_draw_1_S2 = (capital_mean - capital_spread_2):0.1:(capital_mean + capital_spread_2);
capital_draw_2_S2 = (capital_mean - capital_spread_2):0.1:(capital_mean + capital_spread_2);
capital_draw_1_S3 = (capital_mean - capital_spread_3):0.1:(capital_mean + capital_spread_3);
capital_draw_2_S3 = (capital_mean - capital_spread_3):0.1:(capital_mean + capital_spread_3);
capital_draw_1_S4 = (capital_mean - capital_spread_4):0.1:(capital_mean + capital_spread_4);
capital_draw_2_S4 = (capital_mean - capital_spread_4):0.1:(capital_mean + capital_spread_4);
capital_draw_1_S5 = (capital_mean - capital_spread_5):0.1:(capital_mean + capital_spread_5);
capital_draw_2_S5 = (capital_mean - capital_spread_5):0.1:(capital_mean + capital_spread_5);
capital_draw_1_S6 = (capital_mean - capital_spread_6):0.1:(capital_mean + capital_spread_6);
capital_draw_2_S6 = (capital_mean - capital_spread_6):0.1:(capital_mean + capital_spread_6);
%capital_draw_1 = capital_lb:0.05:capital_ub;
%capital_draw_2 = capital_lb:0.05:capital_ub;
optimal_effort_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S1_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S1_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S1=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S1_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S1_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S1_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S1_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S1 = zeros(size(capital_draw_1_S1,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S1 = zeros(size(capital_draw_2_S1,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S1 = zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S1 = zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S1 = zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S1 = zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S1 = zeros(size(capital_draw_2_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S1=zeros(size(capital_draw_1_S1,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S1=zeros(size(capital_draw_1_S1,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail

optimal_effort_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S2_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S2_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S2=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S2_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S2_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S2_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S2_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S2 = zeros(size(capital_draw_1_S2,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S2 = zeros(size(capital_draw_2_S2,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S2 = zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S2 = zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S2 = zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S2 = zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S2 = zeros(size(capital_draw_2_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S2=zeros(size(capital_draw_1_S2,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S2=zeros(size(capital_draw_1_S2,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail

optimal_effort_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S3_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S3_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S3=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S3_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S3_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S3_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S3_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S3 = zeros(size(capital_draw_1_S3,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S3 = zeros(size(capital_draw_2_S3,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S3 = zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S3 = zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S3 = zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S3 = zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S3 = zeros(size(capital_draw_2_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S3=zeros(size(capital_draw_1_S3,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S3=zeros(size(capital_draw_1_S3,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail

optimal_effort_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S4_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S4_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S4=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S4_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S4_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S4_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S4_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S4 = zeros(size(capital_draw_1_S4,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S4 = zeros(size(capital_draw_2_S4,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S4 = zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S4 = zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S4 = zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S4 = zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S4 = zeros(size(capital_draw_2_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S4=zeros(size(capital_draw_1_S4,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S4=zeros(size(capital_draw_1_S4,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail

optimal_effort_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S5_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S5_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S5=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S5_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S5_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S5_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S5_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S5 = zeros(size(capital_draw_1_S5,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S5 = zeros(size(capital_draw_2_S5,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S5 = zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S5 = zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S5 = zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S5 = zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S5 = zeros(size(capital_draw_2_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S5=zeros(size(capital_draw_1_S5,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S5=zeros(size(capital_draw_1_S5,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail

optimal_effort_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_S6_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_S6_high=zeros(size(reward,2),size(a_succeed,2));
expected_optimal_effort_S6=zeros(size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
optimal_effort_function_S6_low=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S6_high=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S6_totalboth=zeros(size(reward,2),size(a_succeed,2));
optimal_effort_function_S6_diffboth=zeros(size(reward,2),size(a_succeed,2));
pba_success_P1_exante_S6 = zeros(size(capital_draw_1_S6,2),size(effort_1,2));% pba of success here is using effort, not optimal effort!
pba_success_P2_exante_S6 = zeros(size(capital_draw_2_S6,2),size(effort_2,2));% pba of success here is using effort, not optimal effort!
pba_success_P1_expost_S6 = zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success using optimal effort function
pba_fail_P1_expost_S6 = zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of failure using optimal effort function
sum_pba_success_P1_expost_S6 = zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
sum_pba_fail_P1_expost_S6 = zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% sum over k of pba of success
pba_success_P2_expost_S6 = zeros(size(capital_draw_2_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_1,2));% pba of success  using  optimal effort function
effort_min_S6=zeros(size(capital_draw_1_S6,2));%minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_capital_if_reach_interm_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_reach_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_interm_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_capital_if_miss_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_reach_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
expected_effort_if_miss_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));
pba_capital_conditional_reach_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if success
pba_capital_conditional_miss_S6=zeros(size(capital_draw_1_S6,2),size(reward,2),size(a_succeed,2),size(a_fail,2),size(effort_2,2));%posterior pba if fail


for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S1,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S1,2)
pba_success_P1_exante_S1(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S1(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S1(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S1(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S1(k,m)=1;
    end
    if pba_success_P1_exante_S1(k,m)<0
        pba_success_P1_exante_S1(k,m)=0;
    end
    if pba_success_P2_exante_S1(o,n)>1
        pba_success_P2_exante_S1(o,n)=1;
    end
    if pba_success_P2_exante_S1(o,n)<0
        pba_success_P2_exante_S1(o,n)=0;
    end

optimal_effort_S1(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S1(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S1(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S1_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_1)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S1_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_1)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S1(k,l,h,i,n)=((optimal_effort_S1(k,l,h,i,n)*skill_ub)+capital_draw_1_S1(:,k)-1)/(optimal_effort_S1(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S1(k,l,h,i,n)=((optimal_effort_S1(k,l,h,i,n)*skill_ub)+capital_draw_1_S1(:,k)-1)/(optimal_effort_S1(k,l,h,i,n)*(skill_ub-skill_lb));  
A(l,h,i,n)=((reward(:,l)*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S1(1,n))+a_succeed(:,h))).^(1/3));
B(l,h,i,n)=(A(l,h,i,n)*skill_ub)+(3/5*((skill_ub-skill_lb).^(1/3))*(((1-capital_mean-capital_spread_1).^(5/3))-((1-capital_mean+capital_spread_1).^(5/3))));

optimal_effort_function_S1(k,l,h,i,n) = optimal_effort_S1(k,l,h,i,n);
optimal_effort_function_S1_low(l,h) = optimal_effort_S1_low(l,h);
optimal_effort_function_S1_high(l,h) = optimal_effort_S1_high(l,h);
if pba_success_P1_expost_S1(k,l,h,i,n)<= 0
    optimal_effort_function_S1(k,l,h,i,n)=0;
    optimal_effort_function_S1_low(l,h)=0;
    optimal_effort_function_S1_high(l,h)=0;
end

if optimal_effort_function_S1_low(l,h)>0 && optimal_effort_function_S1_high(l,h)>0
    optimal_effort_function_S1_totalboth(l,h)=optimal_effort_function_S1_low(l,h)+optimal_effort_function_S1_high(l,h);
    optimal_effort_function_S1_diffboth(l,h)=optimal_effort_function_S1_low(l,h)-optimal_effort_function_S1_high(l,h);
else
    optimal_effort_function_S1_totalboth(l,h)="neg";
    optimal_effort_function_S1_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S1(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S1(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S1(k,l,h,i,n)<0
        pba_success_P1_expost_S1(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S1(k,l,h,i,n)>1
        pba_success_P2_expost_S1(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S1(k,l,h,i,n)<0
        pba_success_P2_expost_S1(k,l,h,i,n)=0;
    end

pba_fail_P1_expost_S1(k,l,h,i,n)=1-pba_success_P1_expost_S1(k,l,h,i,n);

effort_min_S1(k)=(target-capital_draw_1_S1(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S1(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_1).^(4/3))-((1-capital_mean+capital_spread_1).^(4/3)));%%using uniform [k-delta, k+delta]

%fun = @(k,l,h,i,n) (((reward(:,l)*(target-capital_draw_1_S1(:,k)))/(2*(skill_ub-skill_lb)))...
 %   *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S1(o,n))+a_succeed(:,h))).^(1/3);
%q = integral(@(k) fun(k,1,6,6,1),0.4,0.6);

sum_pba_success_P1_expost_S1(:,l,h,i,n)=sum(pba_success_P1_expost_S1(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S1(:,l,h,i,n)=sum(pba_fail_P1_expost_S1(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S2,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S2,2)
pba_success_P1_exante_S2(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S2(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S2(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S2(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S2(k,m)=1;
    end
    if pba_success_P1_exante_S2(k,m)<0
        pba_success_P1_exante_S2(k,m)=0;
    end
    if pba_success_P2_exante_S2(o,n)>1
        pba_success_P2_exante_S2(o,n)=1;
    end
    if pba_success_P2_exante_S2(o,n)<0
        pba_success_P2_exante_S2(o,n)=0;
    end

optimal_effort_S2(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S2(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S2(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S2_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_2)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S2_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_2)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S2(k,l,h,i,n)=((optimal_effort_S2(k,l,h,i,n)*skill_ub)+capital_draw_1_S2(:,k)-1)/(optimal_effort_S2(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S2(k,l,h,i,n)=((optimal_effort_S2(k,l,h,i,n)*skill_ub)+capital_draw_1_S2(:,k)-1)/(optimal_effort_S2(k,l,h,i,n)*(skill_ub-skill_lb));  

optimal_effort_function_S2(k,l,h,i,n) = optimal_effort_S2(k,l,h,i,n);
optimal_effort_function_S2_low(l,h) = optimal_effort_S2_low(l,h);
optimal_effort_function_S2_high(l,h) = optimal_effort_S2_high(l,h);
if pba_success_P1_expost_S2(k,l,h,i,n)<= 0
    optimal_effort_function_S2(k,l,h,i,n)=0;
    optimal_effort_function_S2_low(l,h)=0;
    optimal_effort_function_S2_high(l,h)=0;
end

if optimal_effort_function_S2_low(l,h)>0 && optimal_effort_function_S2_high(l,h)>0
    optimal_effort_function_S2_totalboth(l,h)=optimal_effort_function_S2_low(l,h)+optimal_effort_function_S2_high(l,h);
    optimal_effort_function_S2_diffboth(l,h)=optimal_effort_function_S2_low(l,h)-optimal_effort_function_S2_high(l,h);
else
    optimal_effort_function_S2_totalboth(l,h)="neg";
    optimal_effort_function_S2_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S2(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S2(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S2(k,l,h,i,n)<0
        pba_success_P1_expost_S2(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S2(k,l,h,i,n)>1
        pba_success_P2_expost_S2(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S2(k,l,h,i,n)<0
        pba_success_P2_expost_S2(k,l,h,i,n)=0;
    end

pba_fail_P1_expost_S2(k,l,h,i,n)=1-pba_success_P1_expost_S2(k,l,h,i,n);

effort_min_S2(k)=(target-capital_draw_1_S2(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S2(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_2).^(4/3))-((1-capital_mean-capital_spread_2).^(4/3)));%%using uniform [k-delta, k+delta]

sum_pba_success_P1_expost_S2(:,l,h,i,n)=sum(pba_success_P1_expost_S2(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S2(:,l,h,i,n)=sum(pba_fail_P1_expost_S2(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S3,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S3,2)
pba_success_P1_exante_S3(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S3(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S3(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S3(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S3(k,m)=1;
    end
    if pba_success_P1_exante_S3(k,m)<0
        pba_success_P1_exante_S3(k,m)=0;
    end
    if pba_success_P2_exante_S3(o,n)>1
        pba_success_P2_exante_S3(o,n)=1;
    end
    if pba_success_P2_exante_S3(o,n)<0
        pba_success_P2_exante_S3(o,n)=0;
    end

optimal_effort_S3(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S3(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S3(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S3_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_3)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S3_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_3)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S3(k,l,h,i,n)=((optimal_effort_S3(k,l,h,i,n)*skill_ub)+capital_draw_1_S3(:,k)-1)/(optimal_effort_S3(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S3(k,l,h,i,n)=((optimal_effort_S3(k,l,h,i,n)*skill_ub)+capital_draw_1_S3(:,k)-1)/(optimal_effort_S3(k,l,h,i,n)*(skill_ub-skill_lb));  

optimal_effort_function_S3(k,l,h,i,n) = optimal_effort_S3(k,l,h,i,n);
optimal_effort_function_S3_low(l,h) = optimal_effort_S3_low(l,h);
optimal_effort_function_S3_high(l,h) = optimal_effort_S3_high(l,h);
if pba_success_P1_expost_S3(k,l,h,i,n)<= 0
    optimal_effort_function_S3(k,l,h,i,n)=0;
    optimal_effort_function_S3_low(l,h)=0;
    optimal_effort_function_S3_high(l,h)=0;
end

if optimal_effort_function_S3_low(l,h)>0 && optimal_effort_function_S3_high(l,h)>0
    optimal_effort_function_S3_totalboth(l,h)=optimal_effort_function_S3_low(l,h)+optimal_effort_function_S3_high(l,h);
    optimal_effort_function_S3_diffboth(l,h)=optimal_effort_function_S3_low(l,h)-optimal_effort_function_S3_high(l,h);
else
    optimal_effort_function_S3_totalboth(l,h)="neg";
    optimal_effort_function_S3_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S3(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S3(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S3(k,l,h,i,n)<0
        pba_success_P1_expost_S3(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S3(k,l,h,i,n)>1
        pba_success_P2_expost_S3(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S3(k,l,h,i,n)<0
        pba_success_P2_expost_S3(k,l,h,i,n)=0;
    end
    
pba_fail_P1_expost_S3(k,l,h,i,n)=1-pba_success_P1_expost_S3(k,l,h,i,n);

effort_min_S3(k)=(target-capital_draw_1_S3(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S3(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_3).^(4/3))-((1-capital_mean-capital_spread_3).^(4/3)));%%using uniform [k-delta, k+delta]


sum_pba_success_P1_expost_S3(:,l,h,i,n)=sum(pba_success_P1_expost_S3(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S3(:,l,h,i,n)=sum(pba_fail_P1_expost_S3(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S4,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S4,2)
pba_success_P1_exante_S4(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S4(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S4(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S4(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S4(k,m)=1;
    end
    if pba_success_P1_exante_S4(k,m)<0
        pba_success_P1_exante_S4(k,m)=0;
    end
    if pba_success_P2_exante_S4(o,n)>1
        pba_success_P2_exante_S4(o,n)=1;
    end
    if pba_success_P2_exante_S4(o,n)<0
        pba_success_P2_exante_S4(o,n)=0;
    end

optimal_effort_S4(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S4(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S4(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S4_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_4)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S4_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_4)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S4(k,l,h,i,n)=((optimal_effort_S4(k,l,h,i,n)*skill_ub)+capital_draw_1_S4(:,k)-1)/(optimal_effort_S4(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S4(k,l,h,i,n)=((optimal_effort_S4(k,l,h,i,n)*skill_ub)+capital_draw_1_S4(:,k)-1)/(optimal_effort_S4(k,l,h,i,n)*(skill_ub-skill_lb));  

optimal_effort_function_S4(k,l,h,i,n) = optimal_effort_S4(k,l,h,i,n);
optimal_effort_function_S4_low(l,h) = optimal_effort_S4_low(l,h);
optimal_effort_function_S4_high(l,h) = optimal_effort_S4_high(l,h);
if pba_success_P1_expost_S4(k,l,h,i,n)<= 0
    optimal_effort_function_S4(k,l,h,i,n)=0;
    optimal_effort_function_S4_low(l,h)=0;
    optimal_effort_function_S4_high(l,h)=0;
end

if optimal_effort_function_S4_low(l,h)>0 && optimal_effort_function_S4_high(l,h)>0
    optimal_effort_function_S4_totalboth(l,h)=optimal_effort_function_S4_low(l,h)+optimal_effort_function_S4_high(l,h);
    optimal_effort_function_S4_diffboth(l,h)=optimal_effort_function_S4_low(l,h)-optimal_effort_function_S4_high(l,h);
else
    optimal_effort_function_S4_totalboth(l,h)="neg";
    optimal_effort_function_S4_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S4(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S4(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S4(k,l,h,i,n)<0
        pba_success_P1_expost_S4(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S4(k,l,h,i,n)>1
        pba_success_P2_expost_S4(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S4(k,l,h,i,n)<0
        pba_success_P2_expost_S4(k,l,h,i,n)=0;
    end  
pba_fail_P1_expost_S4(k,l,h,i,n)=1-pba_success_P1_expost_S4(k,l,h,i,n);

effort_min_S4(k)=(target-capital_draw_1_S4(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S4(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_4).^(4/3))-((1-capital_mean-capital_spread_4).^(4/3)));%%using uniform [k-delta, k+delta]


sum_pba_success_P1_expost_S4(:,l,h,i,n)=sum(pba_success_P1_expost_S4(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S4(:,l,h,i,n)=sum(pba_fail_P1_expost_S4(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S5,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S5,2)
pba_success_P1_exante_S5(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S5(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S5(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S5(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S5(k,m)=1;
    end
    if pba_success_P1_exante_S5(k,m)<0
        pba_success_P1_exante_S5(k,m)=0;
    end
    if pba_success_P2_exante_S5(o,n)>1
        pba_success_P2_exante_S5(o,n)=1;
    end
    if pba_success_P2_exante_S5(o,n)<0
        pba_success_P2_exante_S5(o,n)=0;
    end

optimal_effort_S5(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S5(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S5(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S5_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_5)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S5_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_5)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S5(k,l,h,i,n)=((optimal_effort_S5(k,l,h,i,n)*skill_ub)+capital_draw_1_S5(:,k)-1)/(optimal_effort_S5(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S5(k,l,h,i,n)=((optimal_effort_S5(k,l,h,i,n)*skill_ub)+capital_draw_1_S5(:,k)-1)/(optimal_effort_S5(k,l,h,i,n)*(skill_ub-skill_lb));  

optimal_effort_function_S5(k,l,h,i,n) = optimal_effort_S5(k,l,h,i,n);
optimal_effort_function_S5_low(l,h) = optimal_effort_S5_low(l,h);
optimal_effort_function_S5_high(l,h) = optimal_effort_S5_high(l,h);
if pba_success_P1_expost_S5(k,l,h,i,n)<= 0
    optimal_effort_function_S5(k,l,h,i,n)=0;
    optimal_effort_function_S5_low(l,h)=0;
    optimal_effort_function_S5_high(l,h)=0;
end

if optimal_effort_function_S5_low(l,h)>0 && optimal_effort_function_S5_high(l,h)>0
    optimal_effort_function_S5_totalboth(l,h)=optimal_effort_function_S5_low(l,h)+optimal_effort_function_S5_high(l,h);
    optimal_effort_function_S5_diffboth(l,h)=optimal_effort_function_S5_low(l,h)-optimal_effort_function_S5_high(l,h);
else
    optimal_effort_function_S5_totalboth(l,h)="neg";
    optimal_effort_function_S5_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S5(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S5(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S5(k,l,h,i,n)<0
        pba_success_P1_expost_S5(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S5(k,l,h,i,n)>1
        pba_success_P2_expost_S5(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S5(k,l,h,i,n)<0
        pba_success_P2_expost_S5(k,l,h,i,n)=0;
    end   
pba_fail_P1_expost_S5(k,l,h,i,n)=1-pba_success_P1_expost_S5(k,l,h,i,n);

effort_min_S5(k)=(target-capital_draw_1_S5(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S5(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_5).^(4/3))-((1-capital_mean-capital_spread_5).^(4/3)));%%using uniform [k-delta, k+delta]


sum_pba_success_P1_expost_S5(:,l,h,i,n)=sum(pba_success_P1_expost_S5(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S5(:,l,h,i,n)=sum(pba_fail_P1_expost_S5(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S6,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                        for o=1:size(capital_draw_2_S6,2)
pba_success_P1_exante_S6(k,m)=(effort_1(:,m)*skill_ub+capital_draw_1_S6(:,k)-1)/(effort_1(:,m)*(skill_ub-skill_lb));
pba_success_P2_exante_S6(o,n)=(effort_2(:,n)*skill_ub+capital_mean-1)/(effort_2(:,n)*(skill_ub-skill_lb)); %pba success using uniform [k-delta, k+delta]
    if pba_success_P1_exante_S6(k,m)>1 %can't have pba >1 or <0
        pba_success_P1_exante_S6(k,m)=1;
    end
    if pba_success_P1_exante_S6(k,m)<0
        pba_success_P1_exante_S6(k,m)=0;
    end
    if pba_success_P2_exante_S6(o,n)>1
        pba_success_P2_exante_S6(o,n)=1;
    end
    if pba_success_P2_exante_S6(o,n)<0
        pba_success_P2_exante_S6(o,n)=0;
    end

optimal_effort_S6(k,l,h,i,n)=(((reward(:,l)*(target-capital_draw_1_S6(:,k)))/(c_i*(skill_ub-skill_lb)))...
    *(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S6(o,n))+a_succeed(:,h))).^(1/3);%known capital draw
optimal_effort_S6_low(l,h)=(((reward(:,l)*(target-(1/3)*2*capital_spread_6)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);%known capital draw
optimal_effort_S6_high(l,h)=(((reward(:,l)*(target-(2/3)*2*capital_spread_6)*a_succeed(:,h))/(c_i*(skill_ub-skill_lb)))).^(1/3);
pba_success_P1_expost_S6(k,l,h,i,n)=((optimal_effort_S6(k,l,h,i,n)*skill_ub)+capital_draw_1_S6(:,k)-1)/(optimal_effort_S6(k,l,h,i,n)*(skill_ub-skill_lb));
pba_success_P2_expost_S6(k,l,h,i,n)=((optimal_effort_S6(k,l,h,i,n)*skill_ub)+capital_draw_1_S6(:,k)-1)/(optimal_effort_S6(k,l,h,i,n)*(skill_ub-skill_lb));  

optimal_effort_function_S6(k,l,h,i,n) = optimal_effort_S6(k,l,h,i,n);
optimal_effort_function_S6_low(l,h) = optimal_effort_S6_low(l,h);
optimal_effort_function_S6_high(l,h) = optimal_effort_S6_high(l,h);
if pba_success_P1_expost_S6(k,l,h,i,n)<= 0
    optimal_effort_function_S6(k,l,h,i,n)=0;
    optimal_effort_function_S6_low(l,h)=0;
    optimal_effort_function_S6_high(l,h)=0;
end

if optimal_effort_function_S6_low(l,h)>0 && optimal_effort_function_S6_high(l,h)>0
    optimal_effort_function_S6_totalboth(l,h)=optimal_effort_function_S6_low(l,h)+optimal_effort_function_S6_high(l,h);
    optimal_effort_function_S6_diffboth(l,h)=optimal_effort_function_S6_low(l,h)-optimal_effort_function_S6_high(l,h);
else
    optimal_effort_function_S6_totalboth(l,h)="neg";
    optimal_effort_function_S6_diffboth(l,h)="neg";
end

    if pba_success_P1_expost_S6(k,l,h,i,n)>1 %can't have pba >1 or <0
        pba_success_P1_expost_S6(k,l,h,i,n)=1;
    end
    if pba_success_P1_expost_S6(k,l,h,i,n)<0
        pba_success_P1_expost_S6(k,l,h,i,n)=0;
    end
    if pba_success_P2_expost_S6(k,l,h,i,n)>1
        pba_success_P2_expost_S6(k,l,h,i,n)=1;
    end
    if pba_success_P2_expost_S6(k,l,h,i,n)<0
        pba_success_P2_expost_S6(k,l,h,i,n)=0;
    end
pba_fail_P1_expost_S6(k,l,h,i,n)=1-pba_success_P1_expost_S6(k,l,h,i,n);

effort_min_S6(k)=(target-capital_draw_1_S6(:,k))/skill_ub; %minimum positive effort (if k_1 draw below, effort = 0 cuz sure to miss)
expected_optimal_effort_S6(l,h,i,n)=A(l,h,i,n)*((c_i*(skill_ub-skill_lb)).^(-1/3))...
    *(3/4)*(((1-capital_mean+capital_spread_6).^(4/3))-((1-capital_mean-capital_spread_6).^(4/3)));%%using uniform [k-delta, k+delta]


sum_pba_success_P1_expost_S6(:,l,h,i,n)=sum(pba_success_P1_expost_S6(:,l,h,i,n),1);
sum_pba_fail_P1_expost_S6(:,l,h,i,n)=sum(pba_fail_P1_expost_S6(:,l,h,i,n),1);
                        end
                    end
                end
            end
        end
    end
end
%%
for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S1,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S1(k,l,h,i,n)= pba_success_P1_expost_S1(k,l,h,i,n)/sum_pba_success_P1_expost_S1(k,l,h,i,n);
                            pba_capital_conditional_miss_S1(k,l,h,i,n)= pba_fail_P1_expost_S1(k,l,h,i,n)/sum_pba_fail_P1_expost_S1(k,l,h,i,n);
                            expected_capital_if_reach_interm_S1(k,l,h,i,n) = capital_draw_1_S1(:,k)*pba_capital_conditional_reach_S1(k,l,h,i,n);
                            expected_capital_if_miss_interm_S1(k,l,h,i,n) = capital_draw_1_S1(:,k)*pba_capital_conditional_miss_S1(k,l,h,i,n);
                            expected_capital_if_reach_S1(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S1(:,l,h,i,n),1);
                            expected_capital_if_miss_S1(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S1(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S2,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S2(k,l,h,i,n)= pba_success_P1_expost_S2(k,l,h,i,n)/sum_pba_success_P1_expost_S2(k,l,h,i,n);
                            pba_capital_conditional_miss_S2(k,l,h,i,n)= pba_fail_P1_expost_S2(k,l,h,i,n)/sum_pba_fail_P1_expost_S2(k,l,h,i,n);
                            expected_capital_if_reach_interm_S2(k,l,h,i,n) = capital_draw_1_S2(:,k)*pba_capital_conditional_reach_S2(k,l,h,i,n);
                            expected_capital_if_miss_interm_S2(k,l,h,i,n) = capital_draw_1_S2(:,k)*pba_capital_conditional_miss_S2(k,l,h,i,n);
                            expected_capital_if_reach_S2(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S2(:,l,h,i,n),1);
                            expected_capital_if_miss_S2(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S2(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S3,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S3(k,l,h,i,n)= pba_success_P1_expost_S3(k,l,h,i,n)/sum_pba_success_P1_expost_S3(k,l,h,i,n);
                            pba_capital_conditional_miss_S3(k,l,h,i,n)= pba_fail_P1_expost_S3(k,l,h,i,n)/sum_pba_fail_P1_expost_S3(k,l,h,i,n);
                            expected_capital_if_reach_interm_S3(k,l,h,i,n) = capital_draw_1_S3(:,k)*pba_capital_conditional_reach_S3(k,l,h,i,n);
                            expected_capital_if_miss_interm_S3(k,l,h,i,n) = capital_draw_1_S3(:,k)*pba_capital_conditional_miss_S3(k,l,h,i,n);
                            expected_capital_if_reach_S3(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S3(:,l,h,i,n),1);
                            expected_capital_if_miss_S3(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S3(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S4,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S4(k,l,h,i,n)= pba_success_P1_expost_S4(k,l,h,i,n)/sum_pba_success_P1_expost_S4(k,l,h,i,n);
                            pba_capital_conditional_miss_S4(k,l,h,i,n)= pba_fail_P1_expost_S4(k,l,h,i,n)/sum_pba_fail_P1_expost_S4(k,l,h,i,n);
                            expected_capital_if_reach_interm_S4(k,l,h,i,n) = capital_draw_1_S4(:,k)*pba_capital_conditional_reach_S4(k,l,h,i,n);
                            expected_capital_if_miss_interm_S4(k,l,h,i,n) = capital_draw_1_S4(:,k)*pba_capital_conditional_miss_S4(k,l,h,i,n);
                            expected_capital_if_reach_S4(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S4(:,l,h,i,n),1);
                            expected_capital_if_miss_S4(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S4(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S5,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S5(k,l,h,i,n)= pba_success_P1_expost_S5(k,l,h,i,n)/sum_pba_success_P1_expost_S5(k,l,h,i,n);
                            pba_capital_conditional_miss_S5(k,l,h,i,n)= pba_fail_P1_expost_S5(k,l,h,i,n)/sum_pba_fail_P1_expost_S5(k,l,h,i,n);
                            expected_capital_if_reach_interm_S5(k,l,h,i,n) = capital_draw_1_S5(:,k)*pba_capital_conditional_reach_S5(k,l,h,i,n);
                            expected_capital_if_miss_interm_S5(k,l,h,i,n) = capital_draw_1_S5(:,k)*pba_capital_conditional_miss_S5(k,l,h,i,n);
                            expected_capital_if_reach_S5(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S5(:,l,h,i,n),1);
                            expected_capital_if_miss_S5(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S5(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S6,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            pba_capital_conditional_reach_S6(k,l,h,i,n)= pba_success_P1_expost_S6(k,l,h,i,n)/sum_pba_success_P1_expost_S6(k,l,h,i,n);
                            pba_capital_conditional_miss_S6(k,l,h,i,n)= pba_fail_P1_expost_S6(k,l,h,i,n)/sum_pba_fail_P1_expost_S6(k,l,h,i,n);
                            expected_capital_if_reach_interm_S6(k,l,h,i,n) = capital_draw_1_S6(:,k)*pba_capital_conditional_reach_S6(k,l,h,i,n);
                            expected_capital_if_miss_interm_S6(k,l,h,i,n) = capital_draw_1_S6(:,k)*pba_capital_conditional_miss_S6(k,l,h,i,n);
                            expected_capital_if_reach_S6(:,l,h,i,n)=sum(expected_capital_if_reach_interm_S6(:,l,h,i,n),1);
                            expected_capital_if_miss_S6(:,l,h,i,n)=sum(expected_capital_if_miss_interm_S6(:,l,h,i,n),1);
                        end
                    end
                end
            end
    end
end
%%
for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S1,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S1(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S1(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S1(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S1(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S1(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S1(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S2,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S2(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S2(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S2(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S2(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S2(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S2(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S3,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S3(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S3(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S3(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S3(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S3(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S3(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S4,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S4(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S4(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S4(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S4(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S4(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S4(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S5,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S5(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S5(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S5(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S5(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S5(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S5(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

for h=1:size(a_succeed,2)
    for i=1:size(a_fail,2)
        for k=1:size(capital_draw_1_S6,2)
            for l=1:size(reward,2)
                for m=1:size(effort_1,2)
                    for n=1:size(effort_2,2)
                            expected_effort_if_reach_S6(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_reach_S6(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S6(1,n))+a_succeed(:,h))).^(1/3);
                            expected_effort_if_miss_S6(k,l,h,i,n) = (((reward(:,l)*(target-expected_capital_if_miss_S6(k,l,h,i,n)))/...
                                ((skill_ub-skill_lb)))*(((2*a_both-a_succeed(:,h)-a_fail(:,i))*pba_success_P2_exante_S6(1,n))+a_succeed(:,h))).^(1/3);
                        end
                    end
                end
          end
    end
end

expected_capital_if_reach_summary(1,:)=expected_capital_if_reach_S1(1,1,:,11,1); %col 11 (:,11) is libertarian case, col 6 is the egalitarian (:,6)
expected_capital_if_reach_summary(2,:)=expected_capital_if_reach_S2(1,1,:,11,1);
expected_capital_if_reach_summary(3,:)=expected_capital_if_reach_S3(1,1,:,11,1);
expected_capital_if_reach_summary(4,:)=expected_capital_if_reach_S4(1,1,:,11,1);
expected_capital_if_reach_summary(5,:)=expected_capital_if_reach_S5(1,1,:,11,1);
expected_capital_if_reach_summary(6,:)=expected_capital_if_reach_S6(1,1,:,11,1);
expected_capital_if_miss_summary(1,:)=expected_capital_if_miss_S1(1,1,:,11,1);
expected_capital_if_miss_summary(2,:)=expected_capital_if_miss_S2(1,1,:,11,1);
expected_capital_if_miss_summary(3,:)=expected_capital_if_miss_S3(1,1,:,11,1);
expected_capital_if_miss_summary(4,:)=expected_capital_if_miss_S4(1,1,:,11,1);
expected_capital_if_miss_summary(5,:)=expected_capital_if_miss_S5(1,1,:,11,1);
expected_capital_if_miss_summary(6,:)=expected_capital_if_miss_S6(1,1,:,11,1);
expected_effort_if_reach_summary(1,:)=expected_effort_if_reach_S1(1,1,:,11,1);
expected_effort_if_reach_summary(2,:)=expected_effort_if_reach_S2(1,1,:,11,1);
expected_effort_if_reach_summary(3,:)=expected_effort_if_reach_S3(1,1,:,11,1);
expected_effort_if_reach_summary(4,:)=expected_effort_if_reach_S4(1,1,:,11,1);
expected_effort_if_reach_summary(5,:)=expected_effort_if_reach_S5(1,1,:,11,1);
expected_effort_if_reach_summary(6,:)=expected_effort_if_reach_S6(1,1,:,11,1);
expected_effort_if_miss_summary(1,:)=expected_effort_if_miss_S1(1,1,:,11,1);
expected_effort_if_miss_summary(2,:)=expected_effort_if_miss_S2(1,1,:,11,1);
expected_effort_if_miss_summary(3,:)=expected_effort_if_miss_S3(1,1,:,11,1);
expected_effort_if_miss_summary(4,:)=expected_effort_if_miss_S4(1,1,:,11,1);
expected_effort_if_miss_summary(5,:)=expected_effort_if_miss_S5(1,1,:,11,1);
expected_effort_if_miss_summary(6,:)=expected_effort_if_miss_S6(1,1,:,11,1);
expected_optimal_effort_libertarian(1,:)=mean(optimal_effort_function_S1(:,1,11,11,10));%col 11 (:,11) is libertarian case, col 6 is the egalitarian (:,6)
expected_optimal_effort_libertarian(2,:)=mean(optimal_effort_function_S2(:,1,11,11,10));
expected_optimal_effort_libertarian(3,:)=mean(optimal_effort_function_S3(:,1,11,11,10));
expected_optimal_effort_libertarian(4,:)=mean(optimal_effort_function_S4(:,1,11,11,10));
expected_optimal_effort_libertarian(5,:)=mean(optimal_effort_function_S5(:,1,11,11,10));
expected_optimal_effort_libertarian(6,:)=mean(optimal_effort_function_S6(:,1,11,11,10));
expected_optimal_effort_egalit(1,:)=mean(optimal_effort_function_S1(:,1,6,6,10));
expected_optimal_effort_egalit(2,:)=mean(optimal_effort_function_S2(:,1,6,6,10));
expected_optimal_effort_egalit(3,:)=mean(optimal_effort_function_S3(:,1,6,6,10));
expected_optimal_effort_egalit(4,:)=mean(optimal_effort_function_S4(:,1,6,6,10));
expected_optimal_effort_egalit(5,:)=mean(optimal_effort_function_S5(:,1,6,6,10));
expected_optimal_effort_egalit(6,:)=mean(optimal_effort_function_S6(:,1,6,6,10));
expected_optimal_effort_sharesucceed70(1,:)=mean(optimal_effort_function_S1(:,1,8,8,10));
expected_optimal_effort_sharesucceed70(2,:)=mean(optimal_effort_function_S2(:,1,8,8,10));
expected_optimal_effort_sharesucceed70(3,:)=mean(optimal_effort_function_S3(:,1,8,8,10));
expected_optimal_effort_sharesucceed70(4,:)=mean(optimal_effort_function_S4(:,1,8,8,10));
expected_optimal_effort_sharesucceed70(5,:)=mean(optimal_effort_function_S5(:,1,8,8,10));
expected_optimal_effort_sharesucceed70(6,:)=mean(optimal_effort_function_S6(:,1,8,8,10));
expected_optimal_effort_sharesucceed20(1,:)=mean(optimal_effort_function_S1(:,1,3,3,10));
expected_optimal_effort_sharesucceed20(2,:)=mean(optimal_effort_function_S2(:,1,3,3,10));
expected_optimal_effort_sharesucceed20(3,:)=mean(optimal_effort_function_S3(:,1,3,3,10));
expected_optimal_effort_sharesucceed20(4,:)=mean(optimal_effort_function_S4(:,1,3,3,10));
expected_optimal_effort_sharesucceed20(5,:)=mean(optimal_effort_function_S5(:,1,3,3,10));
expected_optimal_effort_sharesucceed20(6,:)=mean(optimal_effort_function_S6(:,1,3,3,10));
optimal_effort_function_low_summary(1,:)=optimal_effort_function_S1_low(1,:);
optimal_effort_function_low_summary(2,:)=optimal_effort_function_S2_low(1,:);
optimal_effort_function_low_summary(3,:)=optimal_effort_function_S3_low(1,:);
optimal_effort_function_low_summary(4,:)=optimal_effort_function_S4_low(1,:);
optimal_effort_function_low_summary(5,:)=optimal_effort_function_S5_low(1,:);
optimal_effort_function_low_summary(6,:)=optimal_effort_function_S6_low(1,:);
optimal_effort_function_high_summary(1,:)=optimal_effort_function_S1_high(1,:);
optimal_effort_function_high_summary(2,:)=optimal_effort_function_S2_high(1,:);
optimal_effort_function_high_summary(3,:)=optimal_effort_function_S3_high(1,:);
optimal_effort_function_high_summary(4,:)=optimal_effort_function_S4_high(1,:);
optimal_effort_function_high_summary(5,:)=optimal_effort_function_S5_high(1,:);
optimal_effort_function_high_summary(6,:)=optimal_effort_function_S6_high(1,:);
optimal_effort_function_totalboth_summary(1,:)=optimal_effort_function_S1_totalboth(1,:);
optimal_effort_function_totalboth_summary(2,:)=optimal_effort_function_S2_totalboth(1,:);
optimal_effort_function_totalboth_summary(3,:)=optimal_effort_function_S3_totalboth(1,:);
optimal_effort_function_totalboth_summary(4,:)=optimal_effort_function_S4_totalboth(1,:);
optimal_effort_function_totalboth_summary(5,:)=optimal_effort_function_S5_totalboth(1,:);
optimal_effort_function_totalboth_summary(6,:)=optimal_effort_function_S6_totalboth(1,:);
optimal_effort_function_diffboth_summary(1,:)=optimal_effort_function_S1_diffboth(1,:);
optimal_effort_function_diffboth_summary(2,:)=optimal_effort_function_S2_diffboth(1,:);
optimal_effort_function_diffboth_summary(3,:)=optimal_effort_function_S3_diffboth(1,:);
optimal_effort_function_diffboth_summary(4,:)=optimal_effort_function_S4_diffboth(1,:);
optimal_effort_function_diffboth_summary(5,:)=optimal_effort_function_S5_diffboth(1,:);
optimal_effort_function_diffboth_summary(6,:)=optimal_effort_function_S6_diffboth(1,:);

%%

figure(1)
%plot(capital_draw_1_S6(:),optimal_effort_S6(:,1,3,3,11),'LineWidth',2)
%hold on
plot(capital_draw_1_S6(:),optimal_effort_S6(:,1,6,6,11),'LineWidth',2)
hold on
%plot(capital_draw_1_S6(:),optimal_effort_S6(:,1,8,8,11),'LineWidth',2)
%hold on
plot(capital_draw_1_S6(:),optimal_effort_S6(:,1,11,11,11),'LineWidth',2)
hold on
legend(['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    ['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],'Location','northeast')
xlim([0.05 0.95])
xlabel('Circumstances')
ylabel('Optimal effort');
title('Optimal effort as a function of circumstances')
saveas(figure(1),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital.pdf' -transparent

figure(11)
plot(capital_draw_1_S6(:),optimal_effort_S6(:,1,11,11,11),'LineWidth',2)
hold on
xlim([0.05 0.95])
xlabel('Circumstances')
ylabel('Optimal effort');
saveas(figure(11),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital for presentation.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital for presentation.pdf' -transparent

figure(2)
%plot(capital_draw_1_S6(:),optimal_effort_function_S6(:,1,3,3,11),'LineWidth',1.5)
%hold on
plot(capital_draw_1_S6(:),optimal_effort_function_S6(:,1,6,6,11),'LineWidth',1.5)
hold on
%plot(capital_draw_1_S6(:),optimal_effort_function_S6(:,1,8,8,11),'LineWidth',1.5)
%hold on
plot(capital_draw_1_S6(:),optimal_effort_function_S6(:,1,11,11,11),'LineWidth',1.5)
hold on
legend(['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],...
    ['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    'Location','northeast')
xlim([0.05 0.95])
xlabel('Circumstances')
ylabel('Optimal effort');
title('Optimal effort function as a function of circumstances')
saveas(figure(2),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital_with corner.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital_with corner.pdf' -transparent

figure(3)
plot(effort_1(:), pba_success_P1_exante_S5(2,:),'LineWidth',1.5)
hold on
plot(effort_1(:),pba_success_P1_exante_S5(5,:),'LineWidth',1.5,'linestyle','--')
hold on
plot(effort_1(:),pba_success_P1_exante_S5(8,:),'LineWidth',1.5,'linestyle',':')
hold on
legend(['k_i=' num2str(capital_draw_1_S5(1,2))],['k_i=' num2str(capital_draw_1_S5(1,5))],['k_i=' num2str(capital_draw_1_S5(1,8))],'Location','northwest')
xlabel('Effort')
ylabel('Probability of reaching target');
title('Probability of reaching target given effort')
saveas(figure(3),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given effort.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given effort.pdf' -transparent

figure(4)
%plot(capital_draw_1_S6(:), pba_success_P1_expost_S6(:,1,3,3,11),'LineWidth',1.5)
%hold on
plot(capital_draw_1_S6(:), pba_success_P1_expost_S6(:,1,6,6,11),'LineWidth',1.5)
hold on
%plot(capital_draw_1_S6(:), pba_success_P1_expost_S6(:,1,8,8,11),'LineWidth',1.5)
%hold on
plot(capital_draw_1_S6(:), pba_success_P1_expost_S6(:,1,11,11,11),'LineWidth',1.5)
hold on
legend(['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],...
    ['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    'Location','northwest')
xlim([0.05 0.95])
xlabel('Circumstances')
ylim([0.05 0.95])
ylabel('Probability of reaching target evaluated at e_i*');
title('Probability of reaching target evaluated at e_i*')
saveas(figure(4),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort.pdf' -transparent

figure(44)
plot(capital_draw_1_S6(:), pba_success_P1_expost_S6(:,1,11,11,11),'LineWidth',2,'Color',"#D95319")
hold on
xlim([0.05 0.95])
xlabel('Circumstances')
ylim([0.05 0.95])
ylabel('Probability of reaching target evaluated at e_i*');
saveas(figure(44),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort for presentation.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort for presentation.pdf' -transparent

figure(5)
plot(inequality(:),expected_capital_if_reach_summary(:,11),'LineWidth',2,'Color',"#2F7A59")
hold on
plot(inequality(:),expected_capital_if_miss_summary(:,11),'LineWidth',2,'Color',"#2F7A59",'linestyle','--')
hold on
plot(inequality(:),expected_effort_if_reach_summary(:,11),'LineWidth',2,'Color',"#D95319")
hold on
plot(inequality(:),expected_effort_if_miss_summary(:,11),'LineWidth',2,'Color',"#D95319",'linestyle','--')
hold on
legend(['Expected circumstances if succeed'],['Expected circumstances if fail'],['Expected effort if succeed'],['Expected effort if fail'],'Location','southeast')
ylim([0.1 0.9])
xlabel('Circumstances dispersion 2\delta')
ylabel('Expected effort/circumstances');
saveas(figure(5),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected capital and effort_Libertarian.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected capital and effort_Libertarian.pdf' -transparent

figure(6)
plot(inequality(:),expected_capital_if_reach_summary(:,6),'LineWidth',1.5,'Color',"#2F7A59")
hold on
plot(inequality(:),expected_capital_if_miss_summary(:,6),'LineWidth',1.5,'Color',"#2F7A59",'linestyle','--')
hold on
plot(inequality(:),expected_effort_if_reach_summary(:,6),'LineWidth',1.5,'Color',"#D95319")
hold on
plot(inequality(:),expected_effort_if_miss_summary(:,6),'LineWidth',1.5,'Color',"#D95319",'linestyle','--')
hold on
legend(['Expected circumstances if succeed'],['Expected circumstances if fail'],['Expected effort if succeed'],['Expected effort if fail'],'Location','southeast')
ylim([0 1])
xlabel('Circumstances dispersion 2\delta')
ylabel('Expected effort/capital');
title('Expected circumstances and effort (Egalitarian case)')
saveas(figure(6),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected capital and effort_Egalitarian.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected capital and effort_Egalitarian.pdf' -transparent

figure(7)
plot(inequality(:),expected_optimal_effort_sharesucceed20(:,1),'LineWidth',1.5)
hold on
plot(inequality(:),expected_optimal_effort_egalit(:,1),'LineWidth',1.5)
hold on
plot(inequality(:),expected_optimal_effort_sharesucceed70(:,1),'LineWidth',1.5)
hold on
plot(inequality(:),expected_optimal_effort_libertarian(:,1),'LineWidth',1.5)
hold on
legend(['share if succeed=' num2str(a_succeed(1,3))],...
    ['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],...
    ['share if succeed=' num2str(a_succeed(1,8))],...
    ['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    'Location','northeast')
ylim([0.05 0.75])
xlabel('Circumstances dispersion 2\delta')
ylabel('Expected optimal effort');
title('Expected e_i* by rule')
saveas(figure(7),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected optimal effort by fairness rule.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Expected optimal effort by fairness rule.pdf' -transparent

figure(8)
plot(inequality(:),optimal_effort_function_totalboth_summary(:,3),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_totalboth_summary(:,6),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_totalboth_summary(:,8),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_totalboth_summary(:,11),'LineWidth',1.5)
hold on
legend(['share if succeed=' num2str(a_succeed(1,3))],...
    ['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],...
    ['share if succeed=' num2str(a_succeed(1,8))],...
    ['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    'Location','northeast')
xlabel('Circumstances dispersion 2\delta')
ylabel('Total optimal effort');
title('Total e_i* by rule')
saveas(figure(8),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Total optimal effort by fairness rule.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Total optimal effort by fairness rule.pdf' -transparent

figure(9)
plot(inequality(:),optimal_effort_function_diffboth_summary(:,3),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_diffboth_summary(:,6),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_diffboth_summary(:,8),'LineWidth',1.5)
hold on
plot(inequality(:),optimal_effort_function_diffboth_summary(:,11),'LineWidth',1.5)
hold on
legend(['share if succeed=' num2str(a_succeed(1,3))],...
    ['share if succeed=' num2str(a_succeed(1,6)) ' (Egalitarian)'],...
    ['share if succeed=' num2str(a_succeed(1,8))],...
    ['share if succeed=' num2str(a_succeed(1,11)) ' (Libertarian)'],...
    'Location','northwest')
xlabel('Circumstances dispersion 2\delta')
ylabel('Difference in optimal effort');
title('Difference in e_i* by rule')
saveas(figure(9),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Difference in optimal effort by fairness rule.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Difference in optimal effort by fairness rule.pdf' -transparent