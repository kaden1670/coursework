T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = 57.11*10^6; %population of Hubei from geonames project
C_t_o = hubei_data(1,1);
X_t_o = C_t_o./N;

a = [X_t_o,Alpha,Beta];
b = rand(1,2);

ko = horzcat(a,b);

[X,Rsdnrm,Rsd,ExFlg,OptmInfo,Lmda,Jmat] = lsqcurvefit(@infection,ko,hubei_data(2,:)...
    ,hubei_data(1,:));

function X_ = infection(k,t)
    %y0 is the only param needed to fit variable initial conditions
    % y0 is Io/Xo
    
    Io_div_Xo = rand(1,1);
    y0 = [1-k(1)-Io_div_Xo.*k(1), Io_div_Xo.*k(1), 0, k(1)];
    
    [t,p] = ode45(@infectionODE, t, y0);
    
    function dydt = infectionODE(~,y)

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
    %   [S, I, R, X]
    %   S - Susceptible population
    %   I - Infected population
    %   R - Removed population
    %   X - Symptomatic, quarantined population
    %
    % k: a 1x5 [Xo, Alpha, Beta, k_0, k] 
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
    

    Alpha = k(2);
    Beta = k(3);
    k_0 = k(4);
    k_ = k(5);

    dydt(1,:) = -Alpha.*S.*I - k_0.*S;
    dydt(2,:) = Alpha.*S.*I - Beta.*I - k_0.*I - k_.*I;
    dydt(3,:) = Beta.*I + k_0.*S;
    dydt(4,:) = (k_ + k_0).*I;
    end
X_ = p(:,4);
end








