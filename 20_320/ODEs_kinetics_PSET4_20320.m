%20.320 PSET 4
%Kaden DiMarco

%% Question 1d
Kf = 10^5; %L/Ms
Kr = 10^-4; %1/s
Vs = 5*10^-10; %M/sec
L = 10*10^-9; %nM
Ker = 0.1; %1/s
Kec = 1; %1/s
[Krec1, Krec2, Kdeg1, Kdeg2] = deal(0.5); %1/sec
% Rs_0 = 10000; %receptors/cell, need in moles/L
Rs_0 = 10000./(6.022*10^23 * (4./3)*pi*(100*10^-6 )^3 * 1000);

%getting too few solutions, so changing ode15s solution threshold
options = odeset('AbsTol', 1e-14, 'RelTol', 1e-14);

[t1d, p1d] = ode15s(@TransportODEs, [0 10000], [Rs_0, 0, L, 0, 0], options, [Kf,...
    Kr, Vs, Ker, Kec, Krec1, Krec2, Kdeg1, Kdeg2]);

figure()
plot(t1d, p1d(:,4), 'r')
title("Surface Complexes versus Time")
xlabel('Time (s)')
ylabel("Surface Complexes (M)")
text(2000, 12e-12, "There are no surface complexes at steady state")

figure()
plot(t1d, p1d(:,1), 'B')
title("Surface Receptors versus Time")
xlabel('Time (s)')
ylabel("Surface Receptors (M)")
axis([0 10000 0 1.1e-8])
text(500, 0.1e-8, "Surface receptors are concentrated around 1e-8 M at steady state")

%%
%Question 1F
%Using same ODE function but determining the effect of different constants
[t1e, p1e] = ode15s(@TransportODEs, [0 10000], [Rs_0, 0, L, 0, 0], options, [Kf,...
    Kr, Vs, Ker, Kec, 0.9, 0.1, 0.1, 0.9]);

figure()
plot(t1d, p1d(:,4), 'b')
title("Surface Complexes versus Time")
xlabel('Time (s)')
ylabel("Surface Complexes (M)")
hold on
plot(t1e, p1e(:,4), 'r')
legend(["Original constants", "Changed constants"], "location", "best")
text(2000, 12e-12, "There are no surface complexes at steady state for both conditions")

figure()
plot(t1d, p1d(:,1), 'b')
title("Surface Receptors versus Time")
xlabel('Time (s)')
ylabel("Surface Receptors (M)")
hold on
plot(t1e, p1e(:,1), 'r')
legend(["Original constants", "Changed constants"], "location", "best")
text(500, 2e-8, {"Changing constant values changed the concentration","of receptors on the cell surface at steady state", "from around 1e-8 to 5e-8"})

%%
%Question 3a
% I used the same kt range as 5.18
kt = linspace(0, 2.5, 1e4);
N = [1,2,4,8,16,32,64];
simulated_exit_times = {[],[],[],[],[],[],[]};
%setting up CV to populate in the loop for each N
CV = zeros(1, length(N));
figure()

%ignore [P]0 since [P]n is dimensionless
%find and plot [P]N for each kt dimensionless time point

for i = 1:length(N)
    hold on
    P_N = (N(i).*((N(i).*kt).^(N(i)-1)).*exp(-N(i).*kt))./factorial(N(i)-1);
    
    weight = round(1000.*P_N);
    simulated_exit_times{i} = repelem(kt, weight);
    CV(i) = nanstd(simulated_exit_times{i})/nanmean(simulated_exit_times{i});
    
    plot(kt, P_N)
end
hold off
title("Figure 5.18 Reproduction")
ylabel("Dimensionless [P]_{N}")
xlabel("Dimensionless time (kt)")
legend({"N=1", "N+2", "N=4", "N=8", 'N=16', "N=36", "N=64"}, "location", "best")

%Question 3b


figure()
loglog(N, CV)
title("C.V. vs N")
xlabel("N")
ylabel("C.V.")
disp(CV)
%%
function dydt = TransportODEs(~,y,k)

% 
% System of ODEs describing an enzyme binding alongside a 
%competitive inhibitor
% Inputs:
% y: a 1x5 [Rs,Ri,L,Cs,Ci] 
% k: a 1x9 [Kf, Kr, Vs, Ker, Kec, Krec1, Krec2, Kdeg1, Kdeg2]


% Output (output is dydt):
% A 5x1  [dRs/dt,dRi/dt,dL/dt,dCs/dt,dCi/dt]

dydt = zeros(5,1);
Rs = y(1);
Ri = y(2);
L = y(3);
Cs = y(4);
Ci = y(5);

Kf = k(1);
Kr = k(2);
Vs = k(3);
Ker = k(4);
Kec = k(5);
Krec1 = k(6);
Krec2 = k(7);
Kdeg1 = k(8);
Kdeg2 = k(9);

dydt(1,:) = Vs + Krec1.*Ri - Ker.*Rs + Kr.*Cs - Kf.*Rs.*L;
dydt(2,:) = Ker.*Rs - Krec1.*Ri - Kdeg1.*Ri;
dydt(3,:) = Kr.*Cs - Kf.*Rs.*L;
dydt(4,:) = Kf.*Rs.*L - Kr.*Cs + Krec2.*Ci - Kec.*Cs;
dydt(5,:) = Kec.*Cs - Krec2.*Ci - Kdeg2.*Ci;
end 

function dydt = SSATransportODEs(~,y,k)

% 
% System of ODEs describing an enzyme binding alongside a 
%competitive inhibitor
% Inputs:
% y: a 1x5 [Rs,Ri,L,Cs,Ci] 
% k: a 1x9 [Kf, Kr, Vs, Ker, Kec, Krec1, Krec2, Kdeg1, Kdeg2]


% Output (output is dydt):
% A 5x1  [dRs/dt,dRi/dt,dL/dt,dCs/dt,dCi/dt]

dydt = zeros(5,1);
Rs = y(1);
Ri = y(2);
L = y(3);
Cs = y(4);
Ci = y(5);

Kf = k(1);
Kr = k(2);
Vs = k(3);
Ker = k(4);
Kec = k(5);
Krec1 = k(6);
Krec2 = k(7);
Kdeg1 = k(8);
Kdeg2 = k(9);

dydt(1,:) = Krec1.*Ri - Ker.*Rs;
dydt(2,:) = Ker.*Rs - Krec1.*Ri - Kdeg1.*Ri;
dydt(3,:) = 0;
dydt(4,:) = Krec2.*Ci - Kec.*Cs;
dydt(5,:) = Kec.*Cs - Krec2.*Ci - Kdeg2.*Ci;
end 
