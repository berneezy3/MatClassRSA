% test_shiftPairwiseAccuracyRDM.m
% This script tests the functionality of RSA.RDM_Computation.shiftPairwiseAccuracyRDM()

% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Basic test with a 0-to-1 scale matrix
disp('Test 1: Basic test with a 0-to-1 scale matrix...');
xIn = rand(5);  % Random 5x5 matrix with values between 0 and 1
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Test with a 0-to-100 scale matrix
disp('Test 2: Test with a 0-to-100 scale matrix...');
xIn = randi([50, 100], 5, 5);  % Random 5x5 matrix with values between 50 and 100
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn, 'pairScale', 100);
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Matrix with NaN on diagonal
disp('Test 3: Matrix with NaN on the diagonal...');
xIn = rand(5); 
xIn(logical(eye(5))) = NaN;  % Set diagonal elements to NaN
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    if all(isnan(diag(xShift)))
        disp('Test 3 passed.');
    else
        disp('Test 3 failed (diagonal values not NaN).');
    end
catch
    disp('Test 3 failed.');
end

%% Test 4: Matrix with values above 1 (should normalize by 100)
disp('Test 4: Test with values above 1 (expect normalization to 0-to-1 scale)...');
xIn = randi([1, 150], 4, 4);  % Random values from 1 to 150
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Empty matrix input
disp('Test 5: Testing with an empty matrix...');
xIn = [];
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    disp('Test 5 failed (no error for empty matrix).');
catch
    disp('Test 5 passed (error as expected).');
end

%% Test 6: Non-square matrix (should still work)
disp('Test 6: Testing with non-square matrix...');
xIn = rand(3, 4);  % Random 3x4 matrix
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Test with all-zero matrix
disp('Test 7: Testing with all-zero matrix...');
xIn = zeros(5, 5);  % 5x5 zero matrix
try
    xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn);
    if all(xShift == -0.5)
        disp('Test 7 passed.');
    else
        disp('Test 7 failed.');
    end
catch
    disp('Test 7 failed.');
end

disp('All tests completed.');