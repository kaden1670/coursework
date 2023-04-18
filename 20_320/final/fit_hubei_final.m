
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

%fits odes to interpolated hubei data

%X_fitted = lsqcurvefit(infection_fit,to_be_fit,points, interp_hubei_data,[0,0,0],[],options2);
%plot_infection_fit = @(p,t) Plot_infection([Alpha, Beta, p(1:3), X_t_o, points],t);
%[~,Plotting_data] = plot_infection_fit(X_fitted,[]);
%infection_fit = @(p,t) infection([Alpha, Beta, p(1:3), X_t_o, N, points],t);

plot_infection_fit = @(p,t) Plot_infection([Alpha, Beta, p(1:3), X_t_o, hubei_data(2,:)]);

[Plotting_data] = plot_infection_fit(X_fitted,[]);
time = Plotting_data.x;
X_t = Plotting_data.y(4,:).*N;
I_t = Plotting_data.y(2,:).*N;

figure()
plot(hubei_data(2,:), hubei_data(1,:), 's', 'Color',[0.4 0.4 0.4],...
    "LineWidth", 2, "MarkerSize", 14, "AlignVertexCenters", 'off',...
    'LineJoin', 'chamfer' )
hold on
plot(extra_hubei_data(2,20:26), extra_hubei_data(1,20:26),'-o','Color',...
    [0.55 0.55 0.55], "LineWidth", 2, "MarkerSize", 11, "AlignVertexCenters",...
    'off', 'LineJoin', 'round' )
hold on 
plot(time, X_t, '-k', "LineWidth", 1.75)
hold on
plot(time, I_t, '--', "LineWidth", 3, 'Color',[0.8314 0.2431 0.5412])
hold on

%for plotting interpolated data
%plot(points,interp_hubei_data, 's')

ylabel("confirmed cases", "LineWidth", 2,'FontSize',12)
yticks([0,20e3, 40e3, 60e3])
yticklabels({'0', '20k', '40k', '60k'})
xticks([1,8,15,22,29,36,43,50])
xticklabels({'21. 01.', '28. 01.', '04. 02.', '11. 02.', '18. 02.',...
    '25. 02.', '03. 03', '10. 03.'})
xtickangle(45)
hold on
xline(18, '--', 'Color',[0.4 0.4 0.4], "LineWidth", 2)
text(12,41e3, "Feb. 7th",'Color',[0.55 0.55 0.55],'FontSize',12)
hold on
xline(23, '--', 'Color',[0.4 0.4 0.4], "LineWidth", 2)
text(24,13e3, "Feb. 12th",'Color',[0.55 0.55 0.55],'FontSize',12)
legend({'Hubei','after Feb. 12th', 'X (model fit)', 'I (model fit)'},'location',...
    'NW','FontSize',12)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',12)

function Xoutput = infection(y0,~)
    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o,N]
    N = y0(7);
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6), 0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4)];
    hubei_data = y0(8:length(y0));
    options = odeset('AbsTol', 1e-6, 'RelTol', 1e-6);

    out = ode15s(@infectionODEs, [0 40], y, options, k);

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






function [plotOut] = Plot_infection(y0,~)
    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o]
    
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6),0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4)];
    
    options = odeset('AbsTol', 1e-6, 'RelTol', 1e-6);

    out = ode15s(@Plot_infectionODEs, [0 50], y, options, k);

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


plotOut = out;
end

