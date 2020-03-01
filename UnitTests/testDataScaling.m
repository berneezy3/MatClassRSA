% testPlotMatrix.m
% ---------------------
% Bernard - March 1, 2020
%
% Testing data scaling for SVM.

%% 

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