% test_plotMST.m
% This script tests the functionality of RSA.visualize.plotMST(RDM, varargin)

% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Basic test with a simple RDM
disp('Test 1: Basic test with a simple RDM...');
RDM = squareform(pdist(rand(5, 3)));  % 5x5 distance matrix
try
    fig = RSA.Visualization.plotMST(RDM);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Test with nodeColors
disp('Test 2: Testing with nodeColors...');
nodeColors = {'r', 'g', 'b', 'y', 'm'};  % 5 colors
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeColors', nodeColors);
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Test with nodeLabels
disp('Test 3: Testing with nodeLabels...');
nodeLabels = {'A', 'B', 'C', 'D', 'E'};  % Labels for nodes
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeLabels', nodeLabels);
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: Test with iconPath (path to dummy images)
disp('Test 4: Testing with iconPath...');
% Assuming placeholder images in the folder './testVisualizations/stimuli/'
iconPath = './testVisualizations/stimuli/';
try
    fig = RSA.Visualization.plotMST(RDM, 'iconPath', iconPath);
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Test with iconSize
disp('Test 5: Testing with iconSize...');
try
    fig = RSA.Visualization.plotMST(RDM, 'iconPath', iconPath, 'iconSize', 60);
    disp('Test 5 passed.');
catch
    disp('Test 5 failed.');
end

%% Test 6: Test with edgeLabelSize
disp('Test 6: Testing with edgeLabelSize...');
try
    fig = RSA.Visualization.plotMST(RDM, 'edgeLabelSize', 20);
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Test with nodeLabelSize
disp('Test 7: Testing with nodeLabelSize...');
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeLabelSize', 20);
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: Test with nodeLabelRotation
disp('Test 8: Testing with nodeLabelRotation...');
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeLabelRotation', 45);
    disp('Test 8 passed.');
catch
    disp('Test 8 failed.');
end

%% Test 9: Test with lineWidth
disp('Test 9: Testing with lineWidth...');
try
    fig = RSA.Visualization.plotMST(RDM, 'lineWidth', 4);
    disp('Test 9 passed.');
catch
    disp('Test 9 failed.');
end

%% Test 10: Test with lineColor
disp('Test 10: Testing with lineColor...');
try
    fig = RSA.Visualization.plotMST(RDM, 'lineColor', [0.1, 0.6, 0.3]);
    disp('Test 10 passed.');
catch
    disp('Test 10 failed.');
end

%% Test 11: Test with all options together
disp('Test 11: Testing with all options...');
try
    fig = RSA.Visualizatione.plotMST(RDM, 'nodeColors', nodeColors, 'nodeLabels', nodeLabels, ...
        'iconPath', iconPath, 'iconSize', 50, 'edgeLabelSize', 15, 'nodeLabelSize', 12, ...
        'nodeLabelRotation', 30, 'lineWidth', 3, 'lineColor', [0.2, 0.3, 0.4]);
    disp('Test 11 passed.');
catch
    disp('Test 11 failed.');
end

%% Test 12: Test with empty nodeColors
disp('Test 12: Testing with empty nodeColors...');
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeColors', []);
    disp('Test 12 passed.');
catch
    disp('Test 12 failed.');
end

%% Test 13: Test with empty nodeLabels
disp('Test 13: Testing with empty nodeLabels...');
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeLabels', []);
    disp('Test 13 passed.');
catch
    disp('Test 13 failed.');
end

%% Test 14: Test with invalid RDM (non-symmetric)
disp('Test 14: Testing with non-symmetric RDM...');
invalidRDM = RDM;
invalidRDM(1, 2) = 1.5;  % Making it non-symmetric
try
    fig = RSA.Visualization.plotMST(invalidRDM);
    disp('Test 14 failed (no error thrown).');
catch
    disp('Test 14 passed (error thrown as expected).');
end

%% Test 15: Test with NaNs in RDM
disp('Test 15: Testing with NaN values in RDM...');
nanRDM = RDM;
nanRDM(3, 4) = NaN;  % Adding NaN to the RDM
try
    fig = RSA.Visualization.plotMST(nanRDM);
    disp('Test 15 failed (no error thrown).');
catch
    disp('Test 15 passed (error thrown as expected).');
end

%% Test 16: Test with diagonal values not zero in RDM
disp('Test 16: Testing with non-zero diagonal values in RDM...');
invalidRDM_diag = RDM;
invalidRDM_diag(1, 1) = 0.5;  % Setting diagonal to non-zero
try
    fig = RSA.Visualization.plotMST(invalidRDM_diag);
    disp('Test 16 failed (no error thrown).');
catch
    disp('Test 16 passed (error thrown as expected).');
end

%% Test 17: Test with too many nodeColors
disp('Test 17: Testing with more nodeColors than nodes...');
extraColors = {'r', 'g', 'b', 'y', 'm', 'c', 'k'};  % More colors than nodes
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeColors', extraColors);
    disp('Test 17 passed.');
catch
    disp('Test 17 failed.');
end

%% Test 18: Test with too few nodeLabels
disp('Test 18: Testing with fewer nodeLabels than nodes...');
fewerLabels = {'A', 'B'};  % Fewer labels than nodes
try
    fig = RSA.Visualization.plotMST(RDM, 'nodeLabels', fewerLabels);
    disp('Test 18 failed (no error thrown).');
catch
    disp('Test 18 passed (error thrown as expected).');
end

%% Test 19: Test with invalid iconPath
disp('Test 19: Testing with invalid iconPath...');
invalidIconPath = './invalidIcons/';  % Invalid directory
try
    fig = RSA.Visualization.plotMST(RDM, 'iconPath', invalidIconPath);
    disp('Test 19 failed (no error thrown).');
catch
    disp('Test 19 passed (error thrown as expected).');
end

%% Test 20: Test with no input (expecting error)
disp('Test 20: Testing with no input...');
try
    fig = RSA.Visualization.plotMST();
    disp('Test 20 failed (no error thrown).');
catch
    disp('Test 20 passed (error thrown as expected).');
end

disp('All tests completed.');