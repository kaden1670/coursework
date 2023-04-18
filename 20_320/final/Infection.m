%20.320 Final Project Part 1
%Kaden DiMarco

%% initialization

data = readtable('Implementation_data.csv');
hubei_data_raw = data(156, 5:width(data)); %C(t) for hubei t_0 = 1/22/20
all_hubei_data = table2array(hubei_data_raw); %convert hubei data to double so easier to manipulate
all_hubei_data(2,:) = 0:length(all_hubei_data)-1; %adding in days since 1/22/20
hubei_data = all_hubei_data(:,1:21); %selecting data up to 2/12/20 for C(t) consistency

%This loop deletes data that were the same as the previous day
%As said in supplimentary methods, in such instances, the same data from the
%previous day were used
bad_indexes=[];
counter = 1;
for i = 1:length(hubei_data)
    if i ~= 1
        if hubei_data(1,i)==hubei_data(1,i-1)
            bad_indexes(counter) = i;
            counter = counter + 1;
        end
    end
end

hubei_data(:,bad_indexes) = [];
    

%%
T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = 57.11*10^6; %population of Hubei from geonames project
C_t_o = hubei_data(1,1);

X_t_o = C_t_o./N;

I_t_o = (I_o./X_o).*X_t_o; %(I_o./X_o) ≥ 10^-3
S_t_o = 1 - I_t_o - X_t_o;


% k > 0, k_o > 0

%% ode coefficient fitter
Io_div_Xo = 10^-3; %guess
R = 0; %guess
X = C_t_o./N;

k_o = 10^-3; %guess
k = 10^-3; %guess

order = [1 0 4];
parameters = {[Io_div_Xo,R,X],[Alpha,Beta,k_o,k]};
initial_states = [1;0];
Ts = 0;

inf_model = idnlgrey(Fitting_Infection(parameters),order,parameters,initial_states,Ts);
setpar(nonlinear_model,'Fixed',{[false false true], [true,true,false,false]});
nonlinear_model = nlgreyest(hubei_data,nonlinear_model,'Display','Full');



%% functions

function dydt = infection(~,y,k)

% 
% System of ODEs describing COVID-19 outbreak as quantified in Maier and
% Brockmann 2020.
%
% The time frame is from Jan 21 - Feb9. Assuming negligble birth and death
% rates.
%
% All equations adopted from Maier and Brockmann 2020
% 
% Inputs:
%
% y: a 1x4 [S, I, R, X]
%   S - Susceptible population
%   I - Infected population
%   R - Removed population
%   X - Symptomatic, quarantined population
%
% k: a 1x4 [Alpha, Beta, k_0, k] 
%                            Alpha  - Transmission rate
%                            Beta   - Recovery rate
%                            k_o    - Containment rate (influenced by social
%                                     distancing)
%                            k      - Removal rate (I -> R) (from
%                                     quarantine measures that only affect
%                                     susceptible individuals)
%                            
% Output (output is dydt):
% A 1X4  [dS/dt, dI/dt, dR/dt, dX/dt]
 

dydt = zeros(4,1);
S = y(1);
I = y(2);
R = y(3);
X = y(4);

Alpha = k(1);
Beta = k(2);
k_0 = k(3);
k = k(4);

dydt(1,:) = -Alpha.*S.*I - k_0.*S;
dydt(2,:) = Alpha.*S.*I - Beta.*I - k_0.*I - k.*I;
dydt(3,:) = Beta.*I + k_o.*S;
dydt(4,:) = (k + k_o).*I;

end






function dydt_output = Fitting_Infection(~,y,k)

% this only returns I=X(t) and is used for model fitting
% System of ODEs describing COVID-19 outbreak as quantified in Maier and
% Brockmann 2020.
%
% The time frame is from Jan 21 - Feb9. Assuming negligble birth and death
% rates.
%
% All equations adopted from Maier and Brockmann 2020
% 
% Inputs:
%
% y: a 1x3 [Io/Xo, R, X]
%  Io/Xo - initial condition to be fit
%   S - Susceptible population
%   I - Infected population
%   R - Removed population
%   X - Symptomatic, quarantined population
%
% k: a 1x4 [Alpha, Beta, k_0, k] 
%                            Alpha  - Transmission rate
%                            Beta   - Recovery rate
%                            k_o    - Containment rate (influenced by social
%                                     distancing)
%                            k      - Removal rate (I -> R) (from
%                                     quarantine measures that only affect
%                                     susceptible individuals)
%                            
% Output (output is dydt):
% A 1X4  [dS/dt, dI/dt, dR/dt, dX/dt]

N = 57.11*10^6;

dydt = zeros(4,1);
R = y(2);
X = y(3);
I = y(1).*X;
S = N - I - X;

Alpha = k(1);
Beta = k(2);
k_0 = k(3);
k = k(4);

dydt(1,:) = -Alpha.*S.*I - k_0.*S;
dydt(2,:) = Alpha.*S.*I - Beta.*I - k_0.*I - k.*I;
dydt(3,:) = Beta.*I + k_o.*S;
dydt(4,:) = (k + k_o).*I;

dydt_output = dydt(4,:);

end
