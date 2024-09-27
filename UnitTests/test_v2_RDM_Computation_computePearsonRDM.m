% test_computePearsonRDM.m
% This script tests the functionality of RSA.computeRDM.computePearsonRDM()

% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Basic test with valid input data
disp('Test 1: Basic test with valid input data...');
X = rand(10, 20);  % 10 features, 20 trials
Y = repelem(1:2, 10);  % Two classes, 10 trials each
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Test with additional permutations
disp('Test 2: Testing with num_permutations = 5...');
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y, 'num_permutations', 5);
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Test with rngType (setting seed)
disp('Test 3: Testing with rngType seed = 42...');
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y, 'rngType', 42);
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: Test with rngType dual-argument (shuffle, twister)
disp('Test 4: Testing with rngType = {''shuffle'', ''twister''}...');
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y, 'rngType', {'shuffle', 'twister'});
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Test with transposed input matrix
disp('Test 5: Testing with transposed input matrix...');
X = rand(20, 10);  % Intentionally mismatched: 20 trials, 10 features
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y);
    disp('Test 5 passed (matrix automatically transposed).');
catch
    disp('Test 5 failed.');
end

%% Test 6: Non-square labels (more labels than trials)
disp('Test 6: Test with mismatch between labels and trials (should throw an error)...');
Y_mismatch = [1 1 1 1 1 2 2 2 2 2 2];  % 11 labels for 10 trials
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X(1:10, :), Y_mismatch);
    disp('Test 6 failed (no error thrown).');
catch
    disp('Test 6 passed (error thrown as expected).');
end

%% Test 7: All-zero input matrix
disp('Test 7: Testing with an all-zero input matrix...');
X_zero = zeros(10, 20);  % All features are zero
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X_zero, Y);
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: Only one class in labels
disp('Test 8: Test with only one class in the labels vector...');
Y_single_class = ones(1, 20);  % Only one class
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X, Y_single_class);
    disp('Test 8 failed (no error for single class).');
catch
    disp('Test 8 passed (error thrown as expected).');
end

%% Test 9: Empty input matrix
disp('Test 9: Testing with an empty input matrix (should throw an error)...');
X_empty = [];
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X_empty, Y);
    disp('Test 9 failed (no error thrown).');
catch
    disp('Test 9 passed (error as expected).');
end

%% Test 10: High-dimensional input (more features than trials)
disp('Test 10: Testing with more features than trials...');
X_high_dim = rand(50, 20);  % 50 features, 20 trials
try
    dissimilarities = RSA.computeRDM.computePearsonRDM(X_high_dim, Y);
    disp('Test 10 passed.');
catch
    disp('Test 10 failed.');
end

disp('All tests completed.');