%can I initialize R as 0?

% initialization
T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = 57.11*10^6; %population of Hubei from geonames project
C_t_o = hubei_data(1,1);
X_t_o = C_t_o./N;

to_be_fit = [0.1,0.1,0.1];
% p = [k_o, k, Io/Xo]
p = [0.1,0.1,0.1];
infection_fit = @(p,t) infection([Alpha, Beta, p(1:3), X_t_o],t);


comparison_time = 2:0.0001:22;
comparison_x = x(1).*comparison_time.^x(2);

X_fitted = lsqcurvefit(infection_fit,to_be_fit,hubei_data(2,:),hubei_data(1,:));



function Xoutput = infection(y0,t)
%y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o]

%y = [S,I,R,X]
y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6), 0, y0(6)];
%k = [Alpha, Beta, k_o, k]
k_ = [y0(1),y0(2),y0(3),y0(4)];

Xoutput = infectionODEs([],y,k_);
a =1
    function dydt = infectionODEs(~,y,k)
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

    Alpha_ = k(1);
    Beta_ = k(2);
    k_o = k(3);
    k = k(4);

    dydt(1,:) = -Alpha_.*S.*I - k_o.*S;
    dydt(2,:) = Alpha_.*S.*I - Beta_.*I - k_o.*I - k.*I;
    dydt(3,:) = Beta_.*I + k_o.*S;
    dydt(4,:) = (k + k_o).*I;

    end

end
