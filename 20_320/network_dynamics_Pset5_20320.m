%% 20.320 PSET 5
% Kaden DiMarco

%% 1b: L_o > gamma*k
%These parameters are arbatrary
L_o = 10;
Gamma = 1;
K = 1;

[T,E] = meshgrid(linspace(0,10,50),linspace(0,10,50));

%These are two different expressions of E for the nulclines
E1_Nulc = Gamma.*T(1,:); %both nulclines
E2_Nulc = L_o.*T(1,:)./(K+T(1,:)); 

figure()
plot(T(1,:), E1_Nulc)
hold on
plot(T(1,:), E2_Nulc)

%This is for plotting vectors
Tdot = E - Gamma.*T;
Edot = (L_o.*T)./(K+T) - E;

Tdot_Standardized = Tdot./sqrt(Tdot.^2+Edot.^2);
Edot_Standardized = Edot./sqrt(Tdot.^2+Edot.^2);
quiver(T, E, Tdot_Standardized, Edot_Standardized)
hold off
ylim([0,10])
xlim([0,10])
xlabel("T (Transcription Factor)")
ylabel("E (Enzyme)")
title("Problem 1B")
text(0, -1.2, "(0,0) is an unstable fixed point, (L_{o}/\gamma - K, L_{o} - \gamma*K) is stable")

%% 1C L_o < gamma*K

%These paramaters are arbitrary
L_o = 10;
Gamma = 1;
K = 15;

[T,E] = meshgrid(linspace(0,10,50),linspace(0,10,50));

%These are two different expressions of E for the nulclines
E1_Nulc = Gamma.*T(1,:); %both nulclines
E2_Nulc = L_o.*T(1,:)./(K+T(1,:)); 

figure()
plot(T(1,:), E1_Nulc)
hold on
plot(T(1,:), E2_Nulc)

%This is for plotting vectors
Tdot = E - Gamma.*T;
Edot = (L_o.*T)./(K+T) - E;

Tdot_Standardized = Tdot./sqrt(Tdot.^2+Edot.^2);
Edot_Standardized = Edot./sqrt(Tdot.^2+Edot.^2);
quiver(T, E, Tdot_Standardized, Edot_Standardized)
hold off
ylim([0,10])
xlim([0,10])
xlabel("T (Nondimensionalized)")
ylabel("E (Nondimensionalized)")
title("Problem 1C")
text(0, -1.2, "(0,0) is stable, (L_{o}/\gamma - K, L_{o} - \gamma*K) is not biologically relevant")

%% 2 Part 1
%setting up constants and ODEs
a=0.04;
b=0.9;
const = [a,b];
[x,y] = meshgrid(linspace(0,3,35),linspace(0,2.5,35));

xdot = -x+a.*y+(x.^2).*y;
ydot = b-a.*y-(x.^2).*y;
%nondimensionalizing
xdot_Standardized = xdot./sqrt(xdot.^2+ydot.^2);
ydot_Standardized = ydot./sqrt(xdot.^2+ydot.^2);
%make phase plot
figure()
q = quiver(x,y, xdot_Standardized, ydot_Standardized);
q.Color = 'black';

xlim([0,3])
ylim([0,2.5])

%Picking points to spiral in and out
point_in = [1.75,1.75];
point_out = [1,1];

%getting vectors for above points
tspan = [0,100];
[t_in,in] = ode15s(@funfunction, tspan, point_in,[],const);
[t_out,out] = ode15s(@funfunction, tspan, point_out,[],const);

%plotting vectors for each point
hold on
plot(in(:,1),in(:,2), '-c', "LineWidth",1.5);
plot(out(:,1),out(:,2), '-r', "LineWidth",1.5);

xlabel("x (Nondimensionalized)")
ylabel("y (Nondimensionalized)")
title("Problem 2 Part 1")


% 2 Part 2
%t_in is for inward spiral (starting point outside orbit)
figure()
plot(t_in, in(:,1), 'c')
hold on
plot(t_in, in(:,2), 'r')
xlabel('Time')
ylabel("Nondimensionalized concentration")
legend('x', 'y')
title("Outside of Orbit")

%t_out is for outward spiral (starting point inside orbit)
figure()
plot(t_out, out(:,1), 'c')
hold on
plot(t_out, out(:,2), 'r')
legend('x', 'y')
xlabel('Time')
ylabel("Nondimensionalized concentration")
title("Inside of orbit")

%% Question3

k = [8,0.8,.08];
%initializing some [S]_o
S = linspace(0,1,100);
%calling x = Vmax,K/Vmax,P
figure()
x = [{0},{0},{0}];
for i = 1:length(k)
    x{i} = (S.*(k(i)+1-S))./((1-S).*(k(i)+S));
    semilogx(x{i}, S)
    if i ~= 3
        hold on
    end
end
xlabel("V_{max,K}/V_{max,P}")
ylabel("S^{*}")
title("Problem 3A")
legend(sprintf("k = %d", k(1)), sprintf("k = %d",k(2)),...
    sprintf("k = %d", k(3)), "location", "best");

%Question 2b
%Finding NH: Fit to L^n/(Kd+L^N)
modelFun = @(k,L)(L.^k(1))./(k(2)+L.^k(1));
Guess = [1,1];
NH1 = nlinfit(x{1}, S, modelFun, Guess);
NH2 = nlinfit(x{2}, S, modelFun, Guess);
NH3 = nlinfit(x{3}, S, modelFun, Guess);

figure()
plot(k, [NH1(1), NH2(1), NH3(1)], '-h')
xlabel('k')
ylabel("Hill Coefficient")
title("Hill Coefficient vs K")
disp([NH1(1), NH2(1), NH3(1)])

%RV vs K
%Km,p = Km,K 
RV = 81.*((k+0.1).^2)./((k+0.9).^2);
figure()
plot(k, RV, '-h')
xlabel("k")
ylabel("Rv")
title("Rv vs k")


%% Functions
function dot = funfunction(~,point,const)
dot = zeros(2,1);
x = point(1);
y = point(2);
a = const(1);
b = const(2);

%phase equations from stem
%The purpose of this function is to make vectors a given initial point
dot(1,:) = -x+a.*y+(x.^2).*y;
dot(2,:) = b-a.*y-(x.^2).*y;
end

