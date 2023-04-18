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

%%
%% These are ODEs with QSSA built in
%QSSA ---> dES/dt = 0
function dydt = QSSACompInhibitedODEs(~,y,k)

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
0 == k1.*E.*S - k1r.*E_S - k_cat.*E_S;
dydt(3,:) = 0;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I - k2.*E.*I;
dydt(6,:) = k2.*E.*I - k2r.*E_I;

end 

function dydt = QSSAUninhibitedODEs(~,y,k)

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
0 == k1.*E.*S - k1r.*E_S - k_cat.*E_S;
dydt(3,:) = 0;
dydt(4,:) = k_cat.*E_S;

end 


function dydt = QSSANonCompInhibitedODEs(~,y,k)

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

% dydt(1,:) = k1r.*E_S - k1.*E.*S + k_cat.*E_S + k2r.*E_I - k2.*E.*I;
% dydt(2,:) = k1r.*E_S - k1.*E.*S + k1r.*E_I_S - k1.*E_I.*S;
% dydt(3,:) = k1.*E.*S - k1r.*E_S - k_cat.*E_S +k2r.*E_I_S - k2.*E_S.*I;
% dydt(4,:) = k_cat.*E_S;
% dydt(5,:) = k2r.*E_I - k2.*E.*I + k2r.*E_I_S - k2.*E_S.*I;
% dydt(6,:) = k2.*E.*I - k2r.*E_I + k1r.*E_I_S - k1.*E_I.*S;
% dydt(7,:) = k1.*E_I.*S - k1r.*E_I_S + k2.*E_S.*I - k2r.*E_I_S;

dydt(1,:) = k1r.*E_S - k1.*E.*S + k_cat.*E_S + k2r.*E_I - k2.*E.*I;
dydt(2,:) = k1r.*E_S - k1.*E.*S;
0 == k1.*E.*S - k1r.*E_S - k_cat.*E_S +k2r.*E_I_S - k2.*E_S.*I;
dydt(3,:) = 0;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I - k2.*E.*I + k2r.*E_I_S - k2.*E_S.*I;
dydt(6,:) = k2.*E.*I - k2r.*E_I;
dydt(7,:) = k2.*E_S.*I - k2r.*E_I_S;

end 

function dydt = QSSAUnCompInhibitedODEs(~,y,k)

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
0 == k1.*E.*S - k1r.*E_S - k_cat.*E_S + k2r.*E_I_S - k2.*E_S.*I;
dydt(3,:) = 0;
dydt(4,:) = k_cat.*E_S;
dydt(5,:) = k2r.*E_I_S - k2.*E_S.*I;
dydt(7,:) = k2.*E_S.*I - k2r.*E_I_S;

end 

%%
%%
%2b
%create incremement of P matching the 2a time span
p = linspace(0, S_0);

% km for each system
km_uninhib = (k1r_+ k_cat_)/(k1_);

%I tried fiting in Kapp for each system into the t(p) equation
%instead, I decided to modify their ODEs to include QSSA

% km_comp = km_uninhib*(1+(I_0/kI));
%km_comp = km_uninhib*(I_0/k2_);
%km_Uncomp = (km_uninhib/(1+(I_0/kI)));

%this equation is derrived from dp/dt = kcat[ES] 
% and from solving for ES from dES/dt using QSSA
t_unihnib = (-km_uninhib*log10(S_0-p) + p + km_uninhib*log10(S_0))/...
    (k_cat_*E_0);

ES_QSSA = (k_cat_*E_0*S_0)/(km_uninhib + S_0);

%ODE derrived QSSA solutions
[t_compIQSSA, p_compIQSSA] = ode15s(@CompInhibitedODEs, [0,1200], [E_0, S_0, E_S_0, P_0, I_0, E_I_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);
[t_noIQSSA, p_noIQSSA] = ode15s(@UninhibitedODEs, [0,1200], [E_0, S_0, ES_QSSA, P_0], [], [k1_, k1r_, k_cat_]);
[t_NoncompIQSSA, p_NoncompIQSSA] = ode15s(@NonCompInhibitedODEs, [0,1200], [E_0, S_0, E_S_0, P_0, I_0, E_I_0, E_I_S_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);
[t_UncompIQSSA, p_UncompIQSSA] = ode15s(@UnCompInhibitedODEs, [0,1200], [E_0, S_0, E_S_0, P_0, I_0, E_I_0, E_I_S_0], [], [k1_, k1r_, k_cat_, k2_, k2r_]);



figure()
plot(t_unihnib, p, ':k')
hold on
plot(t_noIQSSA, p_noIQSSA(:,4), 'k')
hold on
plot(t_compIQSSA, p_compIQSSA(:,4), 'r')
hold on
plot(t_NoncompIQSSA, p_NoncompIQSSA(:,4), 'g')
hold on
plot(t_UncompIQSSA, p_UncompIQSSA(:,4), 'r')
%hold on
%plot(t_Noncomp, p, 'y')
% hold on
% plot(t_Uncomp, p, 'g')

