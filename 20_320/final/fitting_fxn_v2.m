
% initialization
T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = 57.11*10^6; %population of Hubei from geonames project
C_t_o = hubei_data(1,1);
X_t_o = C_t_o./N;


% to_be_fit = [k_o, k, Io/Xo]
to_be_fit = [0.1,0.1,0.1];

p = [0.1,0.1,0.1];
infection_fit = @(p,t) infection([Alpha, Beta, p(1:3), X_t_o, N, hubei_data(2,:)],t);

% options1 = optimoptions(@lsqcurvefit,'Algorithm','levenberg-marquardt');
% options1.OptimalityTolerance = 1e-6;
% options1.StepTolerance = 1e-4;
% options1.FunctionTolerance = 1e-12;
% options1.MaxFunctionEvaluations = 1e6;
% options1.MaxIterations = 1e6;
% options1.UseParallel = true;
% options1.FiniteDifferenceStepSize = 1e-20;
% options1.CheckGradients = true;

options2 = optimoptions(@lsqcurvefit);

X_fitted = lsqcurvefit(infection_fit,to_be_fit,hubei_data(2,:), hubei_data(1,:),[0,0,0],[],options2);

plot_infection_fit = @(p,t) Plot_infection([Alpha, Beta, p(1:3), X_t_o, hubei_data(2,:)],t);
[~,Plotting_data] = plot_infection_fit(X_fitted,[]);
time = Plotting_data.x;
X_t = Plotting_data.y(4,:).*N;
I_t = Plotting_data.y(2,:).*N;

figure()
plot(time, X_t, '-k')
hold on
plot(time, I_t, '--r')
hold on
plot(hubei_data(2,:), hubei_data(1,:), 's','Color',[0.5 0.5 0.5])

function Xoutput = infection(y0,~)
    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o,N]
    N = y0(7);
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6), 0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4)];
    hubei_data = y0(8:length(y0));
    options = odeset('AbsTol', 1e-6, 'RelTol', 1e-6);

    out = ode15s(@infectionODEs, [0 30], y, options, k);

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

x = deval(out, hubei_data);
Xoutput = x(4,:).*N;

end






function [Xoutput1,plotOut] = Plot_infection(y0,~)
    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o]
    
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6),0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4)];
    
    options = odeset('AbsTol', 1e-6, 'RelTol', 1e-6);

    out = ode15s(@Plot_infectionODEs, [0 40], y, options, k);

    function dydt = Plot_infectionODEs(~,y,k)
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

x = deval(out, [2,4,5,6,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22]);
Xoutput1 = x(4,:);
plotOut = out;
end

