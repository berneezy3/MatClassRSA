% testPlotMatrix.m
% ---------------------
% Bernard - March 1, 2020
%
% Testing data scaling for SVM.

%%
% S06.mat should be in UnitTests directory
load('S06.mat');

[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

%% Positive and negative values

xIn = [1 -2 3 -4 5 -6 7 -8 9 -10];

min_val = -1;
max_val = 1;

[xScaled, shift1, shift2, scaleFactor] = scaleDataInRange(xIn, [min_val, max_val])

scaledData = scaleDataShiftDivide(xIn, shift1, shift2, scaleFactor)

assert(isequal(scaledData, xScaled), 'Shift/Scaling factors do not properly shift data.');
assert(isequal(min_val, min(xScaled)), 'Range lower bound does not match min value ');
assert(isequal(max_val, max(xScaled)), 'Range upper bound does not match max value ');


%%


xIn = [1 2 3 4 5 6 7 8 9 10];

min_val = 0;
max_val = 1;

[xScaled, shift1, shift2, scaleFactor] = scaleDataInRange(xIn, [min_val, max_val])

scaledData = scaleDataShiftDivide(xIn, shift1, shift2, scaleFactor)

assert(isequal(scaledData, xScaled), 'Shift/Scaling factors do not properly shift data.');
assert(isequal(min_val, min(xScaled)), 'Range lower bound does not match min value ');
assert(isequal(max_val, max(xScaled)), 'Range upper bound does not match max value ');


%% Test on s06


xIn = X_2D;

min_val = 0;
max_val = 1;

[xScaled, shift1, shift2, scaleFactor] = scaleDataInRange(X_2D, [min_val, max_val]);

scaledData = scaleDataShiftDivide(X_2D, shift1, shift2, scaleFactor);

assert(isequal(scaledData, xScaled), 'Shift/Scaling factors do not properly shift data.');
assert(isequal(min_val, min(xScaled)), 'Range lower bound does not match min value ');
assert(isequal(max_val, max(xScaled)), 'Range upper bound does not match max value ');

%% Test on partitioned folds of S06

% UNBALANCED, SCALED, WEIGHED

fold = 4000;

min_val = -1;
max_val = 1;

[X_2D_Scaled, shift1, shift2, scaleFactor] = scaleDataInRange(X_2D, [min_val, max_val]);

trainX = X_2D(1:fold, :);
testX = X_2D(fold + 1:end, :);

trainXScaled = X_2D_Scaled(1:fold, :);
testXScaled = X_2D_Scaled(fold + 1:end, :);

trainY = labels6(1:fold);
testY = labels6(fold + 1:end);

mdl = classifyTrain(trainX, trainY, 'PCA', .99, 'classifier', 'SVM');

P = classifyPredict(mdl, testX, testY);

figure
plotMatrix(P.CM)
title('Unbalanced classes, scaled, weighed')
colorbar

%%


fold = 4000;

min_val = -1;
max_val = 1;

[X_2D_Scaled, shift1, shift2, scaleFactor] = scaleDataInRange(X_2D, [min_val, max_val]);

trainX = X_2D(1:fold, :);
testX = X_2D(fold + 1:end, :);

trainXScaled = X_2D_Scaled(1:fold, :);
testXScaled = X_2D_Scaled(fold + 1:end, :);

trainY = labels6(1:fold);
testY = labels6(fold + 1:end);

mdl = classifyTrain(trainXScaled, trainY, 'PCA', .99, 'classifier', 'SVM');

P = classifyPredict(mdl, testXScaled, testY);
%%
figure
plotMatrix(P.CM)
title('Unbalanced classes, data scaled, unweighed')

%%

fold = 3600;

min_val = -1;
max_val = 1;


[X_2D_Scaled, shift1, shift2, scaleFactor] = scaleDataInRange(X_2D, [min_val, max_val]);

trainX = X_2D(1:fold, :);
testX = X_2D(fold + 1:end, :);

trainXScaled = X_2D_Scaled(1:fold, :);
testXScaled = X_2D_Scaled(fold + 1:end, :);

trainY = labels6(1:fold);
testY = labels6(fold + 1:end);

mdl = classifyTrain(trainX, trainY, 'PCA', .99, 'classifier', 'SVM');
%%
P_bsw = classifyPredict(mdl, testX, testY);
figure
plotMatrix(P_bsw.CM)
title('Balanced , unscaled, unweighted')
colorbar
%% Positive and negative values Min/Max

xIn = [1 -2 3 -4 5 -6 7 -8 9 -10];

min_val = -1;
max_val = 1;

[xScaled, inputRange, outputRange] = scaleDataMinMax(xIn, [], [min_val, max_val])

scaledData = scaleDataMinMax(xIn, inputRange, outputRange)

assert(isequal(scaledData, xScaled), 'Shift/Scaling factors do not properly shift data.');
assert(isequal(min_val, min(xScaled)), 'Range lower bound does not match min value ');
assert(isequal(max_val, max(xScaled)), 'Range upper bound does not match max value ');