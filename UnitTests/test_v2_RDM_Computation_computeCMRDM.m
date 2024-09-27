% test_computeCMRDM.m
% This script tests the functionality of RSA.RDM_Computation.computeCMRDM()


% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Basic test with a confusion matrix
disp('Test 1: Basic test with a confusion matrix...');
confMatrix = randi([0, 10], 5, 5);  % Random 5x5 confusion matrix
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Normalization by 'sum'
disp('Test 2: Normalizing by ''sum''...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'sum');
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Normalization by 'diagonal'
disp('Test 3: Normalizing by ''diagonal''...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'diagonal');
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: No normalization
disp('Test 4: No normalization (''none'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'normalize', 'none');
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Symmetrizing with 'arithmetic' mean
disp('Test 5: Symmetrizing with ''arithmetic'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'arithmetic');
    disp('Test 5 passed.');
catch
    disp('Test 5 failed.');
end

%% Test 6: Symmetrizing with 'geometric' mean
disp('Test 6: Symmetrizing with ''geometric'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'geometric');
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Symmetrizing with 'harmonic' mean
disp('Test 7: Symmetrizing with ''harmonic'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'harmonic');
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: No symmetrization
disp('Test 8: No symmetrization (''none'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'symmetrize', 'none');
    disp('Test 8 passed.');
catch
    disp('Test 8 failed.');
end

%% Test 9: Linear distance transformation
disp('Test 9: Transforming to distance using ''linear''...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'distance', 'linear');
    disp('Test 9 passed.');
catch
    disp('Test 9 failed.');
end

%% Test 10: Power distance transformation
disp('Test 10: Transforming to distance using ''power''...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'distance', 'power', 'distpower', 2);
    disp('Test 10 passed.');
catch
    disp('Test 10 failed.');
end

%% Test 11: Logarithmic distance transformation
disp('Test 11: Transforming to distance using ''logarithmic''...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'distance', 'logarithmic', 'distpower', 2);
    disp('Test 11 passed.');
catch
    disp('Test 11 failed.');
end

%% Test 12: No distance transformation
disp('Test 12: No distance transformation (''none'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'distance', 'none');
    disp('Test 12 passed.');
catch
    disp('Test 12 failed.');
end

%% Test 13: Rank distances with 'rank'
disp('Test 13: Ranking distances (''rank'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'rank');
    disp('Test 13 passed.');
catch
    disp('Test 13 failed.');
end

%% Test 14: Percentile rank distances
disp('Test 14: Ranking distances (''percentrank'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'percentrank');
    disp('Test 14 passed.');
catch
    disp('Test 14 failed.');
end

%% Test 15: No ranking of distances
disp('Test 15: No ranking of distances (''none'')...');
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(confMatrix, 'rankdistances', 'none');
    disp('Test 15 passed.');
catch
    disp('Test 15 failed.');
end

%% Test 16: Handling non-square matrix (expecting error)
disp('Test 16: Testing with non-square matrix (should throw an error)...');
nonSquareMatrix = randi([0, 10], 5, 4);  % Non-square matrix
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(nonSquareMatrix);
    disp('Test 16 failed (no error).');
catch
    disp('Test 16 passed (error as expected).');
end

%% Test 17: Empty matrix input (expecting error)
disp('Test 17: Testing with empty matrix (should throw an error)...');
emptyMatrix = [];
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(emptyMatrix);
    disp('Test 17 failed (no error).');
catch
    disp('Test 17 passed (error as expected).');
end

%% Test 18: All-zero matrix input
disp('Test 18: Testing with an all-zero matrix...');
zeroMatrix = zeros(5, 5);
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(zeroMatrix);
    disp('Test 18 passed.');
catch
    disp('Test 18 failed.');
end

%% Test 19: Diagonal matrix (self-similarity)
disp('Test 19: Testing with a diagonal matrix...');
diagonalMatrix = eye(5);  % Identity matrix
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(diagonalMatrix);
    disp('Test 19 passed.');
catch
    disp('Test 19 failed.');
end

%% Test 20: Large matrix input
disp('Test 20: Testing with a large matrix...');
largeMatrix = randi([0, 10], 100, 100);  % 100x100 confusion matrix
try
    [RDM, params] = RSA.RDM_Computation.computeCMRDM(largeMatrix);
    disp('Test 20 passed.');
catch
    disp('Test 20 failed.');
end

disp('All tests completed.');