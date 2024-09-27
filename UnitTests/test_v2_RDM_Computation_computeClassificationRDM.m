% test_computeClassificationRDM.m
% This script tests the functionality of RSA.RDM_Computation.computeClassificationRDM()


% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Basic test with a confusion matrix
disp('Test 1: Basic test with a confusion matrix...');
confMatrix = randi([0, 10], 5, 5);  % Random 5x5 confusion matrix
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Test with pairwise correlation matrix
disp('Test 2: Testing with pairwise correlation matrix...');
pairwiseMatrix = rand(5);  % 5x5 random matrix (pairwise correlations)
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(pairwiseMatrix, 'matrixtype', 'pairwise');
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Normalize by sum
disp('Test 3: Testing with normalization by ''sum''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'normalize', 'sum');
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: Normalize by diagonal
disp('Test 4: Testing with normalization by ''diagonal''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'normalize', 'diagonal');
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: No normalization
disp('Test 5: Testing with no normalization...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'normalize', 'none');
    disp('Test 5 passed.');
catch
    disp('Test 5 failed.');
end

%% Test 6: Symmetrize using arithmetic mean
disp('Test 6: Symmetrizing with ''arithmetic'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'symmetrize', 'arithmetic');
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Symmetrize using geometric mean
disp('Test 7: Symmetrizing with ''geometric'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'symmetrize', 'geometric');
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: Symmetrize using harmonic mean
disp('Test 8: Symmetrizing with ''harmonic'' mean...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'symmetrize', 'harmonic');
    disp('Test 8 passed.');
catch
    disp('Test 8 failed.');
end

%% Test 9: No symmetrization
disp('Test 9: Testing with no symmetrization...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'symmetrize', 'none');
    disp('Test 9 passed.');
catch
    disp('Test 9 failed.');
end

%% Test 10: Linear distance transformation
disp('Test 10: Transforming distance using ''linear'' option...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'distance', 'linear');
    disp('Test 10 passed.');
catch
    disp('Test 10 failed.');
end

%% Test 11: Power distance transformation
disp('Test 11: Transforming distance using ''power'' option...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'distance', 'power', 'distpower', 2);
    disp('Test 11 passed.');
catch
    disp('Test 11 failed.');
end

%% Test 12: Logarithmic distance transformation
disp('Test 12: Transforming distance using ''logarithmic'' option...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'distance', 'logarithmic', 'distpower', 2);
    disp('Test 12 passed.');
catch
    disp('Test 12 failed.');
end

%% Test 13: No distance transformation
disp('Test 13: Testing with no distance transformation...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'distance', 'none');
    disp('Test 13 passed.');
catch
    disp('Test 13 failed.');
end

%% Test 14: Ranking distances
disp('Test 14: Ranking distances using ''rank''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'rankdistances', 'rank');
    disp('Test 14 passed.');
catch
    disp('Test 14 failed.');
end

%% Test 15: Percentile ranking distances
disp('Test 15: Ranking distances using ''percentrank''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'rankdistances', 'percentrank');
    disp('Test 15 passed.');
catch
    disp('Test 15 failed.');
end

%% Test 16: No ranking of distances
disp('Test 16: Testing with no ranking of distances...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'rankdistances', 'none');
    disp('Test 16 passed.');
catch
    disp('Test 16 failed.');
end

%% Test 17: Autodetect matrix type (default)
disp('Test 17: Autodetecting matrix type...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'matrixtype', 'auto');
    disp('Test 17 passed.');
catch
    disp('Test 17 failed.');
end

%% Test 18: Specifying confusion matrix type
disp('Test 18: Specifying matrix type as ''cm''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'matrixtype', 'cm');
    disp('Test 18 passed.');
catch
    disp('Test 18 failed.');
end

%% Test 19: Specifying pairwise matrix type
disp('Test 19: Specifying matrix type as ''pairwise''...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(pairwiseMatrix, 'matrixtype', 'pairwise');
    disp('Test 19 passed.');
catch
    disp('Test 19 failed.');
end

%% Test 20: Invalid matrix type
disp('Test 20: Testing invalid matrix type (expect an error)...');
try
    [RDM, params] = RSA.RDM_Computation.computeClassificationRDM(confMatrix, 'matrixtype', 'invalid');
    disp('Test 20 failed (no error thrown).');
catch
    disp('Test 20 passed (error thrown as expected).');
end

disp('All tests completed.');