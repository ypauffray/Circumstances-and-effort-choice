clear all
a_succeed = 0:0.1:1;%share when succeed alone
target = 1;
reward = 0:0.5:1; 
b_i = 1:0.5:5; %constant effort cost c(e) = b * (e_i^2/2) => c'(e_i)=b*e_i
skill_lb = 0;
skill_ub = 1;
capital_mean = 0.5;
capital_spread = 0.49;
capital_draw = (capital_mean - capital_spread):0.0001:(capital_mean + capital_spread);

optimal_effort=zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
pba_success_expost = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));% pba of success using optimal effort function
optimal_effort2 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
optimal_effort3 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
optimal_effort4 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
optimal_effort_check = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
pba_success_expost2 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
pba_success_expost3 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
pba_success_expost4 = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
pba_success_expost_check = zeros(size(capital_draw,2),size(b_i,2),size(a_succeed,2),size(reward,2));
for h=1:size(a_succeed,2)
       for k=1:size(capital_draw,2)
            for l=1:size(b_i,2)
                for n=1:size(reward,2)
                    optimal_effort2(k,l,h,n)=((reward(:,n)*(target-capital_draw(:,k))*a_succeed(:,h))/(b_i(:,l)*skill_ub)).^(1/3);%known capital draw
                    pba_success_expost2(k,l,h,n)=((optimal_effort2(k,l,h,n)*skill_ub)+capital_draw(:,k)-target)/(optimal_effort2(k,l,h,n)*skill_ub);
                    if capital_draw(:,k)<=target-((skill_ub)*((reward(:,n)*a_succeed(:,h)/b_i(:,l)).^(1/2)))
                        optimal_effort(k,l,h,n)=0;
                        pba_success_expost(k,l,h,n)=0;
                    else
                        optimal_effort(k,l,h,n)=((reward(:,n)*(target-capital_draw(:,k))*a_succeed(:,h))/(b_i(:,l)*skill_ub)).^(1/3);%known capital draw
                        pba_success_expost(k,l,h,n)=((optimal_effort(k,l,h,n)*skill_ub)+capital_draw(:,k)-target)/(optimal_effort(k,l,h,n)*skill_ub);
                    end
                    %full additive
                    if capital_draw(:,k)<=target-skill_ub-((reward(:,n)*a_succeed(:,h))/(b_i(:,l)*skill_ub))
                        optimal_effort3(k,l,h,n)=0;
                        pba_success_expost3(k,l,h,n)=0;
                    else
                        optimal_effort3(k,l,h,n)=(reward(:,n)*a_succeed(:,h))/(b_i(:,l)*skill_ub);
                        pba_success_expost3(k,l,h,n)=(optimal_effort3(k,l,h,n)+skill_ub+capital_draw(:,k)-target)/skill_ub;
                    end
                    %full multiplicative
                    if capital_draw(:,k)<=sqrt(b_i(:,l)/reward(:,n)*a_succeed(:,h))
                        optimal_effort4(k,l,h,n)=0;
                        pba_success_expost4(k,l,h,n)=0;
                    else
                        optimal_effort4(k,l,h,n)=(reward(:,n)*a_succeed(:,h)*capital_draw(:,k))/(b_i(:,l)*skill_ub);
                        pba_success_expost4(k,l,h,n)=1-(target/skill_ub*optimal_effort4(k,l,h,n)*capital_draw(:,k));
                    end

                    if optimal_effort2(k,l,h,n)<= (target-capital_draw(:,k))/skill_ub
                       optimal_effort2(k,l,h,n)=0;
                       pba_success_expost2(k,l,h,n)=0;
                    end
                    optimal_effort_check(k,l,h,n)=optimal_effort2(k,l,h,n)-optimal_effort(k,l,h,n);
                    pba_success_expost_check(k,l,h,n)=pba_success_expost(k,l,h,n)-pba_success_expost2(k,l,h,n);
                 end
               end
            end
        end
%%

%using optimal effort function here i.e. with corner case included
figure(1)
plot(capital_draw(:),optimal_effort(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(1:2829),optimal_effort(1:2829,3,11,3),'LineWidth',2,'Color',"#D95319")
hold on
plot(capital_draw(2831:size(capital_draw,2)),optimal_effort(2831:size(capital_draw,2),3,11,3),'LineWidth',2,'Color',"#D95319")
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))],'Location','northeast')
xlim([0.02 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Optimal effort');
saveas(figure(1),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital_with corner for presentation.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Optimal effort as function of capital_with corner for presentation.pdf' -transparent

figure(2)
plot(capital_draw(:), pba_success_expost(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(:), pba_success_expost(:,3,11,3),'LineWidth',2)
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))], ...
    'Location','northwest')
xlim([0.05 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Probability of success evaluated at e_i*');
saveas(figure(2),'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort for presentation.png')
set(gca(), 'color', 'w');
export_fig 'C:\Users\Yves-Paul\OneDrive\WUSTL\Research\00 - Fairness\Probability of reaching target given optimal effort for presentation.pdf' -transparent

figure(3)%additive case
plot(capital_draw(:),optimal_effort3(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(:),optimal_effort3(:,3,11,3),'LineWidth',2,'Color',"#D95319")
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))],'Location','northeast')
xlim([0.02 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Optimal effort');

figure(4)
plot(capital_draw(:), pba_success_expost3(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(:), pba_success_expost3(:,3,11,3),'LineWidth',2)
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))], ...
    'Location','northwest')
xlim([0.05 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Probability of success evaluated at e_i*');

figure(5)%multiplicative case
plot(capital_draw(:),optimal_effort4(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(:),optimal_effort4(:,3,11,3),'LineWidth',2,'Color',"#D95319")
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))],'Location','northeast')
xlim([0.02 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Optimal effort');

figure(6)
plot(capital_draw(:), pba_success_expost4(:,1,11,3),'LineWidth',2)
hold on
plot(capital_draw(:), pba_success_expost4(:,3,11,3),'LineWidth',2)
hold on
legend(['Effort cost b_i=' num2str(b_i(1,1))],['Effort cost b_i=' num2str(b_i(1,3))], ...
    'Location','northwest')
xlim([0.05 0.98])
ylim([0 1])
xlabel('Circumstances')
ylabel('Probability of success evaluated at e_i*');
