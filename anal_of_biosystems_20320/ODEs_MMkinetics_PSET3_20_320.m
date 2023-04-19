%Kaden DiMarco
%20.320 PSET 3
%2a
I_0 = 500*10^(-9); %M
E_0 = 10*10^-9; %M
S_0 = 100*10^-9; % M
P_0 = 0;
E_S_0 = 0;
E_I_0 = 0;
E_I_S_0 = 0;

k1_ = 2*10^5;  %1/Ms
k1r_ = 5*10^-4; % 1/s
k_cat_ = 0.2; %1/s
k2_ = 1*10^5; % 1/Ms
k2r_ = 1*10^-3; %1/s

[t_noI, p_noI] = ode15s(@UninhibitedODEs, [0 2000], [E_0, S_0, E_S_0, P_0], [], [k1_, k1r_, k_cat_]);
[t_compI, p_compI] = ode15s(@CompInhibitedODEs, [0 2000], [E_0, S_0, E_S_0, P_0, I_0, E_I_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);
[t_NoncompI, p_NoncompI] = ode15s(@NonCompInhibitedODEs, [0 2000], [E_0, S_0, E_S_0, P_0, I_0, E_I_0, E_I_S_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);
[t_UncompI, p_UncompI] = ode15s(@UnCompInhibitedODEs, [0 2000], [E_0, S_0, E_S_0, P_0, I_0, E_I_0, E_I_S_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);

figure()
plot(t_noI, p_noI(:,4),'k')
hold on
plot(t_compI, p_compI(:,4),'r')
hold on
plot(t_NoncompI, p_NoncompI(:,4),'g')
hold on
plot(t_UncompI, p_UncompI(:,4),'b')

title("Product Concentration versus Time")
xlabel("Time (s)")
ylabel("[P] (M)")
legend(["Uninhibited", "Competitive Inhibition", "Noncompetitive Inhibition", "Uncompetitive Inhibition"], "location", "best") 

hold off

%%
%2b
%create incremement of P matching the 2a time span
p = linspace(0, S_0);

% km for uninhibited syste,
km_uninhib = (k1r_+ k_cat_)/(k1_);

%this equation is derrived from dp/dt = kcat[ES] 
% and from solving for ES from dES/dt using QSSA
t_unihnib = (-km_uninhib*log10(S_0-p) + p + km_uninhib*log10(S_0))/...
    (k_cat_*E_0);


figure()
plot(t_unihnib, p, 'k')
title("Product Concentration versus Time with QSSA")
xlabel("Time (s)")
ylabel("[P] (M)")
legend("uninhibited system", "location", "best")

%Percent error:
%found common time values between QSSA and no QSSA graphs for the no
%inhibitor case
p_qssaNI = p([49, 75, 88, 95, 98]).';
p_NI = p_noI(1:5, 4);

error = (abs(p_NI - p_qssaNI)/(p_NI))*100;

figure()
plot(t_noI(1:5), error)
title("percent error introduced by QSSA versus time")
ylabel("Percent Error")
xlabel("Time (s)")
text(5, 20, "5 time points +- 5 seconds apart were compared") 

%Y_percent_error = abs(
%%
%Question 3
P_min = 10^-12;
P_max = 10^-6;
%I tried this but linspace gave me a more accurate C2max
%IgG = logspace(-12,-6);
IgG = linspace(P_min, P_max);
Kd_1 = 10^-9; %M
Kd_2 = 1.576; %#/cel
R_0 = 10^5; % #/cell

Beta = IgG./(IgG + (Kd_1/2));
Delta = Beta.*(1-Beta).*(R_0/Kd_2);

C1 = R_0.*Beta.*((-1+sqrt(1+(4.*Delta)))./(2.*Delta));
C2 = (R_0/2).*((1+(2.*Delta)-sqrt(1+(4.*Delta)))./(2.*Delta));

[M,I] = max(C2);

figure()
semilogx(IgG, C1)
hold on
semilogx(IgG, C2, 'r')
title("Bound Receptors versus Antibody Concentration")
ylabel("Number of Bound Antibodies Per Cell")
xlabel("Antibody Concentration (M)")
legend(["One antibody leg is bound", "Both antibody legs are bound"], 'location', 'best')
text(10^-11,1*10^4, "Crosslinking is maximum when [P]_{o} = 1.01e-8 ([P]_{o} = K_{d,1}/2)")
disp(IgG(I))




%%
function dydt = UninhibitedODEs(~,y,k)

% 
% System of ODEs describing uninhibited enzyme binding
% Inputs:
% y: a 1x3 [E,S,ES,P] 
% k: a 1x3 [k1,k1r,kcat]


% Output (output is dydt):
% A 6x1  [dE/dt,dS/dt,dES/dt,dP/dt]

dydt = zeros(4,1);
E = y(1);
S = y(2);
E_S = y(3);
%P = Y(4);
k1 = k(1);
k1r = k(2);
k_cat = k(3);

dydt(1,:) = -k1.*E.*S + k1r.*E_S + k_cat.*E_S;
dydt(2,:) = -k1.*E.*S + k1r.*E_S;
dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S;
dydt(4,:) = k_cat.*E_S;

end 

function dydt = CompInhibitedODEs(~,y,k)

% 
% System of ODEs describing an enzyme binding alongside a 
%competitive inhibitor
% Inputs:
% y: a 1x6 [E,S,ES,P,I,EI] 
% k: a 1x5 [k1,k1r,kcat,k2,k2r]


% Output (output is dydt):
% A 6x1  [dE/dt,dS/dt,dES/dt,dP/dt,dI/dt,dEI/dt]

dydt = zeros(6,1);
E = y(1);
S = y(2);
E_S = y(3);
%P = y(4);
I = y(5);
E_I = y(6);

k1 = k(1);
k1r = k(2);
k_cat = k(3);
k2 = k(4);
k2r = k(5);

dydt(1,:) = k1r.*E_S - k1.*E.*S + k2r.*E_I -k2.*E.*I + k_cat.*E_S;
dydt(2,:) = k1r.*E_S - k1.*E.*S;
dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I - k2.*E.*I;
dydt(6,:) = k2.*E.*I - k2r.*E_I;

end 

function dydt = NonCompInhibitedODEs(~,y,k)

% 
% System of ODEs describing an enzyme binding alongside a noncompetitive
% inhibitor
% Inputs:
% y: a 1x7 [E,S,ES,P,I,EI,EIS] 
% k: a 1x5 [k1,k1r,kcat,k2,k2r]


% Output (output is dydt):
% A 6x1  [dE/dt,dS/dt,dES/dt,dP/dt,dI/dt,dEI/dt,dEIS/dt]

dydt = zeros(6,1);
E = y(1);
S = y(2);
E_S = y(3);
%P = y(4);
I = y(5);
E_I = y(6);
E_I_S = y(7);

k1 = k(1);
k1r = k(2);
k_cat = k(3);
k2 = k(4);
k2r = k(5);

dydt(1,:) = k1r.*E_S - k1.*E.*S + k_cat.*E_S + k2r.*E_I - k2.*E.*I;
dydt(2,:) = k1r.*E_S - k1.*E.*S + k1r.*E_I_S - k1.*E_I.*S;
dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S +k2r.*E_I_S - k2.*E_S.*I;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I - k2.*E.*I + k2r.*E_I_S - k2.*E_S.*I;
dydt(6,:) = k2.*E.*I - k2r.*E_I + k1r.*E_I_S - k1.*E_I.*S;
dydt(7,:) = k1.*E_I.*S - k1r.*E_I_S + k2.*E_S.*I - k2r.*E_I_S;

%these ODEs negate EI + S <--> ESI
% dydt(1,:) = k1r.*E_S - k1.*E.*S + k_cat.*E_S + k2r.*E_I - k2.*E.*I;
% dydt(2,:) = k1r.*E_S - k1.*E.*S;
% dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S +k2r.*E_I_S - k2.*E_S.*I;
% dydt(4,:) = k_cat.*E_S;
% dydt(5,:) = k2r.*E_I - k2.*E.*I + k2r.*E_I_S - k2.*E_S.*I;
% dydt(6,:) = k2.*E.*I - k2r.*E_I;
% dydt(7,:) = k2.*E_S.*I - k2r.*E_I_S;

end 

function dydt = UnCompInhibitedODEs(~,y,k)

% 
% System of ODEs describing an enzyme binding alongside an uncompetitive
% inhibitor
% Inputs:
% y: a 1x7 [E,S,ES,P,I,EI,EIS] 
% k: a 1x5 [k1,k1r,kcat,k2,k2r]


% Output (output is dydt):
% A 7x1  [dE/dt,dS/dt,dES/dt,dP/dt,dI/dt,dEI/dt,dEIS/dt]

dydt = zeros(7,1);
E = y(1);
S = y(2);
E_S = y(3);
%P = y(4);
I = y(5);
E_I_S = y(7);

k1 = k(1);
k1r = k(2);
k_cat = k(3);
k2 = k(4);
k2r = k(5);

dydt(1,:) = k1r.*E_S - k1.*E.*S + k_cat.*E_S;
dydt(2,:) = k1r.*E_S - k1.*E.*S;
dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S + k2r.*E_I_S - k2.*E_S.*I;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I_S - k2.*E_S.*I;
dydt(7,:) = k2.*E_S.*I - k2r.*E_I_S;

end 
