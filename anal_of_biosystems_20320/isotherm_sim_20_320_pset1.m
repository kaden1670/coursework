%Author: Kaden DiMarco

%Kd is in M
Kd = 25*10^-12;
%Kon is in (Ms)^-1
Kon = 2.1*10^5;
Koff = Kon*Kd;
%these is just an array of the different ligand concentrations for the
%isothem, I am keeping track of [L] in M
Ligand_array = [0.1, 0.3, 1, 3, 10, 30, 100, 300, 1000]*10^-12;
min = 60;
hour = 60*60;
%each time will be used to create a different isotherm
time_array = [10*min, hour, 3*hour, 9*hour, 24*hour, 72*hour];
Kobs = Kon*Ligand_array + Koff;

%initialize fitting
modelFun = @(Kd,Ligand_array)((Ligand_array./(Kd+Ligand_array))); 
guess = 1.2*10^(-9); 

colors = ['r', 'g', 'b', 'c', 'm', 'k'];
shapes = ['+', 'o', '*', 'x', 'd', 'p'];
%this array is to keep track of the estimated kd for each isotherm
kd_est = zeros(1,6);
figure()

for i = 1:length(time_array)
    
    %calculate y(t) for each time
    Y = (Ligand_array./(Kd+Ligand_array)).*(1-exp(-1*Kobs*time_array(i)));
    %plot dots and curved line for each y(t)
    fitParam = nlinfit(Ligand_array,Y,modelFun,guess);
    kd_est(i)=fitParam;
    semilogx(Ligand_array,Y,strcat(shapes(i), colors(i))) 
    hold on
    fittedY = modelFun(fitParam,Ligand_array);
    semilogx(Ligand_array,fittedY,strcat('-', colors(i)))
end

xlabel('[L] (M)') 
ylabel('Y')
title('Y vs [L] For Varying Reaction Times')
hold off
legend({'10 minutes','10 minutes','1 hour','1 hour','3 hours','3 hours', '9 hours', '9 hours','24 hours','24 hours','72 hours','72 hours'}, 'location', 'best')
disp(kd_est)
