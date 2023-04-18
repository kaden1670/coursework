%20.320 PSET 2 
%Kaden DiMarco
%Question 2

%units are nM
Ligand_array = [0.00586, 0.0351, 0.0883, 0.234, 0.586, 1.47, 3.51, 8.83 ...
    23.4, 58.6];

Y_array = [4.2*10^-9, 9.1*10^-7, 1.4*10^-5, 0.00027, 0.0042, 0.062, 0.48, ...
    0.93, 0.996, 1.0];

figure()
semilogx(Ligand_array, Y_array, 'o', 'MarkerFaceColor',[0 0.447 0.741],...
    'MarkerSize', 10)
title("Y vs. [L]_{0}")
ylabel("Y")
xlabel("[L]_{o} (nM)")
txt = "This curve is likely cooperative; there is a fast transition from unbound to bound complex.";
text(0.0013, 0.7, txt)

%The Y vs [L] graph is likely cooperative
%lets test it by making a hill plot

figure()
% find ln(y/1-y) and ln(ligand concentrations)
hill_y = log(Y_array) - log(1-Y_array);
hill_x = log(Ligand_array);

%hill_y(10) = infinity so I will leave it out of the plot. Y still gets
%very close to 1 so it is a fair correction
scatter(hill_x(1:9), hill_y(1:9))
%finding y=mx+b coefficients from fitting x and y values with a 1st order
%polynomial
P = polyfit(hill_x(1:9), hill_y(1:9), 1);
%yFit is the line estimated from the linear coefficients
yFit = P(1)*hill_x(1:9) + P(2);
hold on;
plot(hill_x(1:9),yFit,'r-');
xlabel("ln([L]_{0} (nM))")
ylabel("ln(y/(1-y))")
%round linear fit coef for text on graph
%I did not like round() because it left trailing zeros
neat_P1 = num2str(fix(P(1)*10^2)/100);
neat_P2 = num2str(fix(P(2)*10^2)/100);
txt = sprintf("y = %sx + %s", neat_P1, neat_P2);
text(-5,1, txt)
text(-5, 0, "A hill coefficient of 3 indicates positive cooperativity.")
