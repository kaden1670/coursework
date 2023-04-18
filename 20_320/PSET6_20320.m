%Kaden DiMarco
%20.320 PSET 6

%Problem 4
%initialize data
t_set = [0,6,12,25];
Seals_in_Kuluk = [100,60,33,5]./100;
Seals_in_CL = [100,100,90,68]./100;

%Senescense model fitting
%k = [gamma_0, alpha];
modelFunSenescense = @(k,t)exp((-k(1)./k(2)).*(exp(k(2).*t)-1));
guess = [0.01,0.01];
[Kuluk_fit_param_s,~,~,~,MSE_KS] = nlinfit(t_set ,Seals_in_Kuluk, modelFunSenescense, guess);
[CL_fit_param_s,~,~,~,MSE_CLS] = nlinfit(t_set, Seals_in_CL, modelFunSenescense, guess);

%Constant death rate fitting
%k is gamma
modelFunConst = @(k,t)(exp(-k.*t));
Guess = [0.01];
[Kuluk_fit_param_c, ~, ~, ~, MSE_KC] = nlinfit(t_set, Seals_in_Kuluk, modelFunConst,Guess);
[CL_fit_param_c, ~, ~, ~, MSE_CLC] = nlinfit(t_set,Seals_in_CL, modelFunConst, Guess);

%applying fit parameters to initial condition N_o = 100, t_model is for
%graphing a smooth curve
t_model = (0:0.25:25);
Kuluk_fit_senesence = 100.*(exp((-Kuluk_fit_param_s(1)./Kuluk_fit_param_s(2)).*...
    ((exp(Kuluk_fit_param_s(2).*t_model))-1)));
CL_fit_senesence = 100.*(exp((-CL_fit_param_s(1)./CL_fit_param_s(2)).*...
    ((exp(CL_fit_param_s(2).*t_model))-1)));

Kuluk_fit_const = 100.*exp(-Kuluk_fit_param_c(1).*t_model);
CL_fit_const = 100.*exp(-CL_fit_param_c(1).*t_model);

%Kuluk
figure(1)
semilogy(t_model, Kuluk_fit_senesence, '--b')
hold on
semilogy(t_model, Kuluk_fit_const, ':r')
hold on
semilogy(t_set, Seals_in_Kuluk.*100, 'k*')
legend([sprintf("Senescense model, MSE = %f", MSE_KS),...
    sprintf("Constant death rate model, MSE = %f",MSE_KC), "data"])
hold off
ylabel("Sea Otter Population")
xlabel("Time (Months)")
title("Kuluk")


%CL
figure(2)
xlim([0 25])
ylim([0 100])
semilogy(t_model, CL_fit_senesence, '--b')
hold on 
semilogy(t_model, CL_fit_const, ':r')
hold on 
semilogy(t_set, Seals_in_CL.*100, 'k*')
legend([sprintf("Senescense model, MSE = %f",MSE_CLS), ...
    sprintf("Constant death rate model, MSE = %f", MSE_CLC), "data"])
ylabel("Sea Otter Population")
xlabel("Time (Months)")
title("Clam Lagoon")

A = table([Kuluk_fit_param_s(1);CL_fit_param_s(1)],[Kuluk_fit_param_s(2);CL_fit_param_s(2)],...
    'VariableNames',{'Gamma Naught' 'Alpha'},...
    'RowNames',{'Kuluk' 'Clam Lagoon'});


B = table([Kuluk_fit_param_c(1);CL_fit_param_c(1)],...
    'VariableNames',{'Gamma'},...
    'RowNames',{'Kuluk' 'Clam Lagoon'});


disp("Senescense")
disp(A)
disp(" ")
disp("Constant Death Rate")
disp(B)