%20.320 Final Project Part 1
%Kaden DiMarco

%% initialization

data = readtable('Implementation_data.csv');
hubei_data_raw = data(156, 5:width(data)); %C(t) for hubei t_0 = 1/22/20
all_hubei_data = table2array(hubei_data_raw); %convert hubei data to double so easier to manipulate
all_hubei_data(2,:) = 2:length(all_hubei_data)+1; %adding in days since 1/20/20
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
hubei_data_non_adjusted = hubei_data;
hubei_data(:,bad_indexes) = [];

%% Reproducing Figure 1A

% I want to fit C(t) = at^b 
modelFun = @(k,t)(k(1).*t.^(k(2)));
x0 = [1,1];
%specifying levenberg-marquardt method and setting options
options = optimoptions(@lsqcurvefit,'Algorithm','levenberg-marquardt');
x = lsqcurvefit(modelFun,x0,hubei_data(2,2:17),hubei_data(1,2:17),lb,ub,options);
options.OptimalityTolerance = 1e-12;
options.StepTolerance = 1e-12;
options.FunctionTolerance = 1e-20;
lb = [];
ub = [];

%the exponential constant for C(t) scaling only considers 1/24/20-2/9/20
%9th
x = lsqcurvefit(modelFun,x0,hubei_data(2,2:17),hubei_data(1,2:17),lb,ub,options);
infection_model = x(1).*hubei_data(2,:).^(x(2));


%plotting
figure()
plot(hubei_data_non_adjusted(2,:),hubei_data_non_adjusted(1,:),'s', 'Color',[0.5 0.5 0.5],...
    "LineWidth", 1.25)

ax = gca;
ax.YAxis.Limits = [0 40000];
xticks([1,5,9,13,17,21])
xticklabels({'21. 01.', '25. 01.', '29. 01.', '02. 02.', '06. 02.', '10. 02'})
xtickangle(45)
yticks([0,10e3, 20e3, 30e3, 40e3])
yticklabels({'0', '10k', '20k', '30k', '40k'})
ylabel('confirmed cases')
hold on
plot(hubei_data(2,:),infection_model, '-k', "LineWidth", 1.25)
hold on
xline(20, '--', 'Color',[0.5 0.5 0.5], "LineWidth", 1.25)
text(18,10e3, "Feb. 9th")
legend({"Hubei", "t^{\mu}, \mu = 2.46"}, "location", "best")