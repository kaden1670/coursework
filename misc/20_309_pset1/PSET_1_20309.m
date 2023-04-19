
% allocate space for results
numberOfGains = numel( StaticImageVariousGains );
gainSetting = nan( 1, numberOfGains );
actualGain = nan( 1, numberOfGains );
intercept = nan( 1, numberOfGains );

% find best fit and plot raw data
figure

for ii = 1:numberOfGains
    imageData = double( squeeze( StaticImageVariousGains(ii).ImageData ) );
    darkData = double( squeeze( StaticImageVariousGains(ii).DarkImageData ) );
    
    darkLevel = mean( darkData, 3 );
    
    pixelMean = mean( imageData, 3 ) - darkLevel;
    pixelVariance = var( imageData, 0, 3 );
    pixelMaximum = max( imageData, [], 3 );
   
    pixelMean = pixelMean(:);
    pixelVariance = pixelVariance(:);
    pixelMaximum = pixelMaximum(:);
    
    badOnes = pixelMaximum >=  4095 | pixelMean < 0;
    pixelMean( badOnes ) = [];
    pixelVariance( badOnes ) = [];
    % OBVIOUSLY, YOU ARE GOING TO NEED TO DO SOME STUFF IN THIS LOOP
    
    gainSetting(ii) = StaticImageVariousGains(ii).Gain;
    bestFit = fitlm( pixelMean, pixelVariance, 'poly1','Weights', 1 ./ max( 10, pixelVariance ));
    intercept(ii) = bestFit.Coefficients{'(Intercept)','Estimate'};
    actualGain(ii) = bestFit.Coefficients{'x1','Estimate'};
    
    % plot the raw data
    loglog( pixelMean(:), pixelVariance(:), 'x' );
    hold on
end
%%

% plot best fits log-log
for ii = 1:numberOfGains
    xAxis = logspace( -1, log10( 4095 ), 256 )';% log10( 1 ./ fitModels{ii}.Coefficients.Estimate('x1') ), log10( 4095 ), 256 )';    
    loglog( xAxis, actualGain(ii) .* xAxis + intercept(ii), 'LineWidth', 3 );
    hold on
end

% plot best fits linear
figure
for ii = 1:numberOfGains
    xAxis = logspace( -1, log10( 4095 ), 256 )';% log10( 1 ./ fitModels{ii}.Coefficients.Estimate('x1') ), log10( 4095 ), 256 )';    
    plot( xAxis, actualGain(ii) .* xAxis + intercept(ii), 'LineWidth', 3 );
    hold on
end

% find calibration model
calibrationModel = fitlm(gainSetting, actualGain, 'poly1');
gainXAxis = (0:24)';
calibration = calibrationModel.predict( gainXAxis );

% plot calibraion model and data points
figure
plot( gainSetting, actualGain, 'x', 'LineWidth', 3 )
hold on
plot( gainXAxis, calibration, 'LineWidth', 3 )
xlabel( 'Camera Gain Setting (DN)' )
ylabel( 'Actual Gain (ADU/electron' )
title( 'Gain Calibration Curve', 'FontSize', 16 )


%%
load( 'MantaCameraDataFall2020v2.mat' )
%%
numberOfExposures = numel( DarkImageVariousExposures );

% EDIT THE CODE BELOW TO COMPUTE DARK CURRENT AND READ NOISE
% allocate space for results
exposure = nan( 1, numberOfExposures );
avgVariance = nan( 1, numberOfExposures );

% compute average variance for each exposure
for ii = 1:numberOfExposures
    exposure(ii) = DarkImageVariousExposures(ii).Exposure;
    imageData = double( squeeze( DarkImageVariousExposures(ii).ImageData ) );
    pixelVariance = var( imageData, 0, 3 );
    pixelMean = mean( imageData, 3 );
    avgVariance(ii) = mean(pixelVariance,[1,2]);
    
end

% compute best fit model
darkImageFit = fitlm(exposure,avgVariance,'poly3','Weights', 1 ./ max( 10, avgVariance ) )
    
% This shows how to access the output values from fitlm
readNoise = darkImageFit.Coefficients{'(Intercept)','Estimate'}
darkCurrent = darkImageFit.Coefficients{'x1','Estimate'}

% plot results
figure
xAxis = logspace( -6, 1, 250 );
loglog( xAxis, darkImageFit.predict( xAxis' ) )
hold on
loglog( exposure, avgVariance, 'x', 'LineWidth', 2 )
xlabel( 'Exposure (s)' )
ylabel( 'Variance (electrons^2)' )
title( 'Variance vs Exposure for Dark Image' )