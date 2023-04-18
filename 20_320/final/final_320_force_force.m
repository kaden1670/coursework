%20.320 Final Project Part 1
%Kaden DiMarco

% please make sure Implementation_data.csv is in your directory

%% initialization
%this section processes the C(t) data from the given csv.

data = readtable('Implementation_data.csv');
hubei_data_raw = data(156, 5:width(data)); %C(t) for hubei t_0 = 1/22/20
guangdong_data_raw = data(160, 5:width(data));
henan_data_raw = data(161, 5:width(data));
zhejiang_data_raw = data(162, 5:width(data));
hunan_data_raw = data(163, 5:width(data));
anhui_data_raw = data(164, 5:width(data));
jiangxi_data_raw = data(165, 5:width(data));
jiangsu_data_raw = data(168, 5:width(data));
chongqing_data_raw = data(169, 5:width(data));

all_hubei_data = table2array(hubei_data_raw); %convert hubei data to double so easier to manipulate
all_guangdong_data = table2array(guangdong_data_raw);
all_henan_data = table2array(henan_data_raw);
all_zhejiang_data = table2array(zhejiang_data_raw);
all_hunan_data = table2array(hunan_data_raw);
all_anhui_data = table2array(anhui_data_raw);
all_jiangxi_data = table2array(jiangxi_data_raw);
all_jiangsu_data = table2array(jiangsu_data_raw);
all_chongqing_data = table2array(chongqing_data_raw);


all_hubei_data(2,:) = 2:length(all_hubei_data)+1; %adding in days since 1/20/20
all_guangdong_data(2,:) = 2:length(all_guangdong_data)+1;
all_henan_data(2,:) = 2:length(all_henan_data)+1;
all_zhejiang_data(2,:) = 2:length(all_zhejiang_data)+1;
all_hunan_data(2,:) = 2:length(all_hunan_data)+1;
all_anhui_data(2,:) = 2:length(all_anhui_data)+1;
all_jiangxi_data(2,:) = 2:length(all_jiangxi_data)+1;
all_jiangsu_data(2,:) = 2:length(all_jiangsu_data)+1;
all_chongqing_data(2,:) = 2:length(all_chongqing_data)+1;

hubei_data = all_hubei_data(:,1:21); %selecting data up to 2/12/20 for C(t) consistency
guangdong_data = all_guangdong_data(:,1:21);
henan_data = all_henan_data(:,1:21);
zhejiang_data = all_zhejiang_data(:,1:21);
hunan_data = all_hunan_data(:,1:21);
anhui_data = all_anhui_data(:,1:21);
jiangxi_data = all_jiangxi_data(:,1:21);
jiangsu_data = all_jiangsu_data(:,1:21);
chongqing_data = all_chongqing_data(:,1:21);

extra_hubei_data = all_hubei_data(:,1:29); %the extra_... is for plotting data after 2/12/20
extra_guangdong_data = all_guangdong_data(:,1:29);
extra_henan_data = all_henan_data(:,1:29);
extra_zhejiang_data = all_zhejiang_data(:,1:29);
extra_hunan_data = all_hunan_data(:,1:29);
extra_anhui_data = all_anhui_data(:,1:29);
extra_jiangxi_data = all_jiangxi_data(:,1:29);
extra_jiangsu_data = all_jiangsu_data(:,1:29);
extra_chongqing_data = all_chongqing_data(:,1:29);

all_data = {hubei_data,guangdong_data,henan_data,zhejiang_data,hunan_data,...
    anhui_data, jiangxi_data,jiangsu_data,chongqing_data};
all_extra_data = {extra_hubei_data,extra_guangdong_data,extra_henan_data,...
    extra_zhejiang_data,extra_hunan_data,extra_anhui_data,extra_jiangxi_data,...
    extra_jiangsu_data,extra_chongqing_data};
    

%This loop deletes data that were the same as the previous day.
%As said in supplimentary methods, in such instances, the same data from the
%previous day were used, so these (C(t),t) pairs are removed for fitting
%accuracy.

all_data_non_adjusted = {zeros(1,length(all_data))};
interp_all_data = {zeros(1,length(all_data))};


points = {[], [],[],[],[],[],[],[],[]};    

for j = 1:length(all_data)
    bad_indexes=[];
    counter = 1;
    for i = 1:length(all_data{j})
        %don't want to compare 1st index to index that doesn't exist
        if i ~= 1
            if all_data{j}(1,i)==all_data{j}(1,i-1)
                %records the index to be removed, and counter moves up so
                %the next bad index can be stored
                bad_indexes(counter) = i;
                counter = counter + 1;
            end
        end
    end
    all_data_non_adjusted{j} = all_data{j};
    all_data{j}(:,bad_indexes) = [];
    half_points = all_data{j}(2,:) - 0.5;
    points{j} = sort(horzcat(half_points,all_data{j}(2,:)));
    %the 1.5 time in points is outside of interpolation range, so I will
    %ignore
    points{j}(1) = [];
    
    %linear interpolation
    interp_all_data{j} = interp1(all_data{j}(2,:),all_data{j}(1,:),points{j},'linear'); 
end

hubei_data = all_data{1};
hubei_data_non_adjusted = all_data_non_adjusted{1};


%interpolating data past Feb. 12
interp_all_extra_data={zeros(1,length(all_extra_data))};

%remove duplicate entries for the extended hubei data for Fig 2
extra_points = {[], [],[],[],[],[],[],[],[]};    

for j = 1:length(all_extra_data)
    bad_indexes=[];
    counter = 1;
    for i = 1:length(all_extra_data{j})
        if i ~= 1
            if all_extra_data{j}(1,i)==all_extra_data{j}(1,i-1)
                bad_indexes(counter) = i;
                counter = counter + 1;
            end
        end
    end
    all_extra_data_non_adjusted{j} = all_extra_data{j};
    all_extra_data{j}(:,bad_indexes) = [];
    half_points = all_extra_data{j}(2,:) - 0.5;
    extra_points{j} = sort(horzcat(half_points,all_extra_data{j}(2,:)));
    extra_points{j}(1) = [];
    
    %linear interpolation

    interp_all_extra_data{j} = interp1(all_extra_data{j}(2,:),...
        all_extra_data{j}(1,:),extra_points{j},'linear'); 
end
extra_hubei_data = all_extra_data{1};


%% Reproducing Figure 1A

% I want to fit C(t) = at^b 
modelFun = @(k,t)(k(1).*t.^(k(2)));
x0 = [1,1];
%specifying levenberg-marquardt method and setting options
options = optimoptions(@lsqcurvefit,'Algorithm','levenberg-marquardt');

options.OptimalityTolerance = 1e-12;
options.StepTolerance = 1e-12;
options.FunctionTolerance = 1e-20;
lb = [];
ub = [];

%the exponential constant for C(t) scaling only considers 1/24/20-2/9/20
%9th
x = lsqcurvefit(modelFun,x0,hubei_data(2,2:17),hubei_data(1,2:17),lb,ub,options);

%curve fit with interpolated data excluding duplicate days
%x = lsqcurvefit(modelFun,x0,points{1}(3:31),interp_all_data{1}(3:31),lb,ub,options);
infection_model = x(1).*hubei_data(2,:).^(x(2));


%plotting
figure()
plot(hubei_data_non_adjusted(2,:),hubei_data_non_adjusted(1,:),'s', 'Color',[0.4 0.4 0.4],...
    "LineWidth", 1.5, "MarkerSize", 8, "AlignVertexCenters", 'off',...
    'LineJoin', 'chamfer' )

ax = gca;
ax.YAxis.Limits = [0 40000];
xticks([1,5,9,13,17,21])
xticklabels({'21. 01.', '25. 01.', '29. 01.', '02. 02.', '06. 02.', '10. 02.'})
xtickangle(45)
yticks([0,10e3, 20e3, 30e3, 40e3])
yticklabels({'0', '10k', '20k', '30k', '40k'})
ylabel('confirmed cases')
hold on
plot(hubei_data(2,:),infection_model, '-k', "LineWidth", 1.75)
hold on
xline(20, ':', 'Color',[0.4 0.4 0.4], "LineWidth", 2)
text(17,10e3, "Feb. 9th",'FontSize',16)
legend({"Hubei", "t^{\mu}, \mu = 2.46"}, "location", "best",'FontSize',16)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',12)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',12)

title('Figure 1A Reproduction');
th = get(gca,'title');
pth = get(th,'position');
pth(2) = pth(2)+0.02;
set(th,'position',pth);


%% Reproducing Figure 2A

% initialization
T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = 57.1*10^6; %population of Hubei from geonames project
C_t_o = hubei_data(1,1);
X_t_o = C_t_o./N;

%as in SI, alpha is fit around (.6-.8) and T_I is around (2.6 - 20)
%assuming 'around' means within the significant figure of for alpha and
%beta constraints

% to_be_fit = [Alpha,Beta,k_o, k, Io/Xo] these are the coefficients that I want to fit
% with lsqcurvefit
to_be_fit = [Alpha,Beta,0.1,0.1,1];

%infection_fit is a dummy function that is used to initialize all the
%initial conditions I don't want to fit without passing them through
%lsqcurvefit

infection_fit = @(p,t) infection([p(1:5), X_t_o, N, hubei_data(2,:)],t);


options2 = optimoptions(@lsqcurvefit);
options2.MaxFunctionEvaluations = 1e4;

% this returns the fitted parameters from to_be_fit
X_fitted_2A = lsqcurvefit(infection_fit,to_be_fit,hubei_data(2,:), hubei_data(1,:),[0.55,0.0490,0,0,10^-3],[0.849,0.3922,inf,inf,inf],options2);



%fits odes to interpolated hubei data

%X_fitted = lsqcurvefit(infection_fit,to_be_fit,points, interp_hubei_data,[0,0,0],[],options2);
%plot_infection_fit = @(p,t) Plot_infection([Alpha, Beta, p(1:3), X_t_o, points],t);
%[~,Plotting_data] = plot_infection_fit(X_fitted,[]);
%infection_fit = @(p,t) infection([Alpha, Beta, p(1:3), X_t_o, N, points],t);

%I repurposed infection_fit to instead give me all data instead of just
%X(t) with solutions to the city data's C(t) time points.
plot_infection_fit = @(p,t) Plot_infection([p(1:5), X_t_o, hubei_data(2,:)]);

[Plotting_data,X_t_Data_at_feb_12] = plot_infection_fit(X_fitted_2A,[]);
time = Plotting_data.x;
X_t = Plotting_data.y(4,:).*N;
%need to add t = 23 to get index to start plotting model after feb 12 (-.)
time_x = time;
time_x(length(time_x)+1) = 23;
time_x = sort(time_x);
X_t(length(X_t)+1) = X_t_Data_at_feb_12*N;
%this doesnt mess up x(t) since values always increase with time.
X_t = sort(X_t);


I_t = Plotting_data.y(2,:).*N;

for i = 1:length(X_t)
    if time_x(i) == 23
        extra_plot_index = i;
        break
    end
end


figure()
plot(hubei_data(2,:), hubei_data(1,:), 's', 'Color',[0.4 0.4 0.4],...
    "LineWidth", 2, "MarkerSize", 14, "AlignVertexCenters", 'off',...
    'LineJoin', 'chamfer' )
hold on
plot(extra_hubei_data(2,20:26), extra_hubei_data(1,20:26),'-o','Color',...
    [0.55 0.55 0.55], "LineWidth", 2, "MarkerSize", 11, "AlignVertexCenters",...
    'off', 'LineJoin', 'round' )
hold on 
plot(time_x(1:extra_plot_index-1), X_t(1:extra_plot_index-1), '-k', "LineWidth", 1.75)
hold on
plot(time, I_t, '--', "LineWidth", 3, 'Color',[0.8314 0.2431 0.5412])
hold on
plot(time_x(extra_plot_index:length(time_x)), X_t(extra_plot_index:length(time_x)), '-.k', "LineWidth", 1.75)
hold on
%for plotting interpolated data
%plot(points,interp_hubei_data, 's')

ylabel("confirmed cases", "LineWidth", 2,'FontSize',14)
yticks([0,20e3, 40e3, 60e3])
yticklabels({'0', '20k', '40k', '60k'})
xticks([1,8,15,22,29,36,43,50])
xticklabels({'21. 01.', '28. 01.', '04. 02.', '11. 02.', '18. 02.',...
    '25. 02.', '03. 03', '10. 03.'})
xtickangle(45)
hold on
xline(18, ':', 'Color',[0.4 0.4 0.4], "LineWidth", 2)
text(12,41e3, "Feb. 7th",'Color',[0.55 0.55 0.55],'FontSize',12)
hold on
xline(23, ':', 'Color',[0.4 0.4 0.4], "LineWidth", 2)
text(24,13e3, "Feb. 12th",'Color',[0.55 0.55 0.55],'FontSize',12)
legend({'Hubei','after Feb. 12th', 'X (model fit)', 'I (model fit)'},'location',...
    'NW','FontSize',12)

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
b = get(gca,'YTickLabel');
set(gca,'YTickLabel',b,'fontsize',14)

title('Figure 2A Reproduction');
th = get(gca,'title');
pth = get(th,'position');
pth(2) = pth(2)+0.04;
set(th,'position',pth);

%Calculating P and Q
P_2A = (X_fitted_2A(3)./(X_fitted_2A(3)+X_fitted_2A(4)));
Q_2A = (X_fitted_2A(3)+X_fitted_2A(4))./((X_fitted_2A(2)+X_fitted_2A(3)+X_fitted_2A(4)));

%% For reproducing Figure 2C

% initialization
T_I = 8; %duration of infection in days
Beta = 1./T_I; 
R_o_free = 6.2; %basic reproduction number
Alpha = R_o_free.*Beta;
N = [nan,104303132, 4290000, 51200000, 66980000, 64610000, 44000000, 76770000,...
    28390000]; %populations from geonames project

%initializing variables to hold fit, I(t), and X(t) data along with
%timepoints of solutions
all_x_fit = {zeros(1:length(interp_all_data))};
all_I_t = {zeros(1:length(interp_all_data))};
all_X_t = {zeros(1:length(interp_all_data))};
all_time = {zeros(1:length(interp_all_data))};
all_P = {zeros(1:length(interp_all_data))};
all_Q = {zeros(1:length(interp_all_data))};


for i = 2:length(interp_all_data)
    %initializing initial condition for ODEs
    C_t_o = interp_all_data{i}(1,1);
    X_t_o = C_t_o./N(i);


    % to_be_fit = [Alpha, Beta, k_o, k, Io/Xo, p,p_c] these are the coefficients that I want to fit
    % with lsqcurvefit
    %coefficients are sensitive to initial guesses... this means the value of fitted
    %the parameters are less important than their role in the shape of X(t)
    %and I(t)
    to_be_fit = [Alpha, Beta, 0.01,0.01,2,0.01,0.01];

    %infection_fit is a dummy function that is used to initialize all the
    %initial conditions I don't want to fit without passing them through
    %lsqcurvefit
  
    infection_fit = @(p,t) infection([p(1:5), X_t_o, N(i), p(6:7), points{i}],t);

    
    %I tried sifting through options to get the best fit, standard worked
    %for all of the plots
    options2 = optimoptions(@lsqcurvefit);
%     options2.MaxFunctionEvaluations = 1e4;
%     options2.OptimalityTolerance = 1e-8;
    options2.StepTolerance = 1e-10;
  %  options2.FunctionTolerance = 1e-9;
    options2.MaxFunctionEvaluations = 1e4;
    options2.MaxIterations = 1e3;
    %options2.UseParallel = true; %can use if code slow
    %options2.FiniteDifferenceStepSize = 5e-6;
    lb = [0.55 0.0490 0 0 10^-3 0.5, 0];
    
    %ub just helps code run faster/ a bit more accurate
    ub = [0.849,0.3922 inf inf inf 1 1];
    

    all_x_fit{i} = lsqcurvefit(infection_fit,to_be_fit,points{i}, interp_all_data{i},lb,ub,options2);

    %plot infection is the same function as infection but it returns all
    %output equations
    plot_infection_fit = @(p,t) Plot_infection([p(1:5), X_t_o, p(6:7), points{i}]);

    [Plotting_data] = plot_infection_fit(all_x_fit{i},[]);
    all_time{i} = Plotting_data.x;
    all_X_t{i} = Plotting_data.y(4,:).*N(i);
    all_I_t{i} = Plotting_data.y(2,:).*N(i);
    
    all_P{i} = (all_x_fit{i}(3)./(all_x_fit{i}(3)+all_x_fit{i}(4)));
    all_Q{i} = (all_x_fit{i}(3)+all_x_fit{i}(4))./((all_x_fit{i}(2)+all_x_fit{i}(3)+all_x_fit{i}(4)));
    
end

city_names = {"","Guangdong", 'Henan', 'Zhejiang', 'Hunan', 'Anhui', 'Jiangxi'...
    'Jiangsu', 'Chongqing'};

shapes = {'o','v','*','^','<','h','p','s'};
colors = {[0.8588 0.2471 0.5294],[0.4667 0.4510 0.6824],[0.8510 0.4196 0.2314],...
    [0.4824 0.6667 0.3333],[0.8980 0.6824 0.2706],[0.5804 0.4588 0.2549],...
    [0.3725 0.3725 0.3725],[0.2980 0.6275 0.4824]};
figure1=figure('Position', [10, 200, 2500, 750]);


for i = 2:length(all_X_t)
    %this loop serves to find the index where extra points past feb 12
    %begin
    for z = 1:length(extra_points{i})
        if extra_points{i}(z) > 22
            plot_index = z;
            break
        end
    end
            
    
    
    subplot(2,4,i-1)
    
    plot(points{i}, interp_all_data{i}, shapes{i-1}, 'Color',colors{i-1},...
    "LineWidth", 1.5, "MarkerSize", 8, "AlignVertexCenters", 'off',...
    'LineJoin', 'chamfer')
    hold on
    
    plot(extra_points{i}([plot_index:length(extra_points{i})]), ...
        interp_all_extra_data{i}([plot_index:length(extra_points{i})]),'o','Color',...
    [.5 .5 .5], "LineWidth", 1.5, "MarkerSize", 6, "AlignVertexCenters",...
    'off', 'LineJoin', 'round')

    hold on
    plot(all_time{i}, all_X_t{i},'-k', "LineWidth", 1.5)
    
    hold on
    plot(all_time{i}, all_I_t{i},'--', "LineWidth", 2, 'Color',[0.8314 0.2431 0.5412])
    
    [maximum, idx] = max(all_I_t{i});
    time_I_max = round(all_time{i}(idx));
    
    xline(23, '--', 'Color',[0.4 0.4 0.4], "LineWidth", 1.5)
    
    %making label for dotted line representing the max for I(t)
    if time_I_max > 11
        date = time_I_max - 11;
        if date == 1
            label = "Feb. 1st";
        elseif date == 2
            label = "Feb. 2nd.";
        elseif date == 3
            label = "Feb. 3rd";
        elseif date == 4
            label = "Feb. 4th";
        elseif date == 5
            label = "Feb. 5th";
        elseif date == 6
            label = "Feb. 6th";
        end
    elseif time_I_max == 11
        label = "Jan 31st";
    elseif time_I_max == 10
        label = "Jan 30th";
    end      
    
   % xline(time_I_max,'--', label,'fontsize',18,'Color',[0.4 0.4 0.4], "LineWidth", 1.5, ...
  %       'LabelVerticalAlignment', 'top', 'LabelOrientation', 'horizontal')
    
    xticks([0,10,20,30])
    yticks([0 .5e3 1e3 1.5e3])
    yticklabels({'0', '0.5k', '1k', '1.5k'})
    
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',18)
    b = get(gca,'YTickLabel');
    set(gca,'YTickLabel',b,'fontsize',18)
    ax = gca;
    ax.YAxis.Limits = [0 1500];
    axis([0 30 0 1500])
    text(2, 1e3, city_names{i}, 'FontSize',24)
    hold off
end

han=axes(figure1,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'confirmed cases', 'FontSize',24);
xlabel(han, 'days since Jan. 20th','FontSize',24);
title(han,'f(I)=p_α (I+1)^2   f_c (I)=p_c (S+1)^2','FontSize',24);

th = get(gca,'title');
pth = get(th,'position');
pth(2) = pth(2)+0.02;
set(th,'position',pth);

yh = get(gca,'ylabel');
pyh = get(yh,'position');
pyh(1) = pyh(1)-0.02;
set(yh,'position',pyh);

%% correlation
clear A
clear B
for i = 2:length(interp_all_data)
    A{i-1} = max(all_I_t{i})./max(all_X_t{i});
    B{i-1} = all_x_fit{i}(6);
end
A = [A{:}];
B = [B{:}];

[r1,p1] = corrcoef(A,B);

%% functions

function Xoutput = infection(y0,~)
%Infection fit calls this function with  the unfitted parameters constants, and only the fitted
%parameters as inputs. But both are passed into y0 for this function.

    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o,N,p,p_c,time]
    N = y0(7);
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6), 0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4),y0(8),y0(9)];
    city_data = y0(10:length(y0));
    
    options = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

    out = ode45(@infectionODEs, [0 40], y, options, k);

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
        % k: a 1x5 [Alpha, Beta, k_0, k, p, p_c] 
        %                            Alpha  - Transmission rate
        %                            Beta   - Recovery rate
        %                            k_o    - Containment rate (influenced by social
        %                                     distancing)
        %                            k      - Removal rate (I -> X) (from
        %                                     quarantine measures that only affect
        %                                     susceptible individuals)
        %                            p      - psychological factor
        %                                     representing inhibitive
        %                                     effect of pandemic on S.
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
    k_ = k(4);
    p = k(5);
    p_c = k(6);
    
    %F_c = (1/(1+ p_c.*((I^2)+1)));

    dydt(1,:) = -((Alpha_.*S.*I)./(p.*((1+I)^2))) - (1/(p_c.*(S+1)^2)).*k_o.*S;
    dydt(2,:) = ((Alpha_.*S.*I)./(p.*((1+I)^2))) - Beta_.*I - I.*(k_o+k_).*(1/(p_c.*((S+1)^2)));
    dydt(3,:) = Beta_.*I + (1/(p_c.*((S+1)^2))).*k_o.*S;
    dydt(4,:) = (k_ + k_o).*I.*(1/(p_c.*((S+1)^2)));


        end
%deval allows me to compare ode solutions with C(t) for different cities at the same time
%points as represented in C(t) 
    x = deval(out, city_data);
    Xoutput = x(4,:).*N;

end





%this function takes the fitted paramaters and solves the odes with them
function [plotOut,X_t_Data_at_feb_12] = Plot_infection(y0,~)
    %y0 = [Alpha,Beta,k_o,k,Io/Xo,X_t_o,p,p_c]
    
    %y = [S,I,R,X]
    y = [1-y0(6)-y0(5).*y0(6), y0(5).*y0(6),0, y0(6)];
    %k = [Alpha, Beta, k_o, k]
    k = [y0(1),y0(2),y0(3),y0(4),y0(7),y0(8)];
    
    options = odeset('AbsTol', 1e-8, 'RelTol', 1e-8);

    out = ode45(@Plot_infectionODEs, [0 50], y, options, k);

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
    % k: a 1x6 [Alpha, Beta, k_0, k, p, p_c] 
    %                            Alpha  - Transmission rate
    %                            Beta   - Recovery rate
    %                            k_o    - Containment rate (influenced by social
    %                                     distancing)
    %                            k      - Removal rate (I -> X) (from
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
    k_ = k(4);
    p = k(5);
    p_c = k(6);
    
    %F_c = (1/(1+ p_c.*((I^2)+1)));

    dydt(1,:) = -((Alpha_.*S.*I)./(p.*((1+I)^2))) - (1/(p_c.*(S+1)^2)).*k_o.*S;
    dydt(2,:) = ((Alpha_.*S.*I)./(p.*((1+I)^2))) - Beta_.*I - I.*(k_o+k_).*(1/(p_c.*((S+1)^2)));
    dydt(3,:) = Beta_.*I + (1/(p_c.*((S+1)^2))).*k_o.*S;
    dydt(4,:) = (k_ + k_o).*I.*(1/(p_c.*((S+1)^2)));

    end
%for making the dash dotted line for 2A
X_t_Data_at_feb_12 = deval(out, 23);
X_t_Data_at_feb_12 = X_t_Data_at_feb_12(4);


plotOut = out;

end
