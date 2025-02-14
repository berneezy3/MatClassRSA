% test_v2_Visualization_plotMatrix.m
% -------------------------------------
% Ray - March 2024

clear all; close all; clc


%% Basic test: 3x3 identity matrix (for a simple, square matrix case)

disp('Test 1: Plotting a 3x3 identity matrix without optional parameters...');
RDM = eye(3); % identity matrix
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Edge case with an empty matrix
disp('Test 2: Plotting an empty matrix...');
RDM = [];
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Edge case with a non-square matrix
disp('Test 3: Plotting a 3x2 non-square matrix...');
RDM = rand(3, 2);
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: Large matrix (10x10) to check performance
disp('Test 4: Plotting a large 10x10 random matrix...');
RDM = rand(10);
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Testing 'ranktype' option with 'rank'
disp('Test 5: Plotting with ''ranktype'' option set to ''rank''...');
RDM = rand(5);
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'ranktype', 'rank');
    disp('Test 5 passed.');
catch
    disp('Test 5 failed.');
end

%% Test 6: Testing 'ranktype' option with 'percentrank'
disp('Test 6: Plotting with ''ranktype'' option set to ''percentrank''...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'ranktype', 'percentrank');
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Testing 'axisColors' option with custom colors
disp('Test 7: Plotting with ''axisColors'' option...');
RDM = rand(4);  % 4x4 random matrix
axisColors = {'r', 'g', 'b', 'y'};  % red, green, blue, yellow
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'axisColors', axisColors);
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: Testing 'axisLabels' with custom labels
disp('Test 8: Plotting with ''axisLabels'' option...');
axisLabels = {'A', 'B', 'C', 'D'};
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'axisLabels', axisLabels);
    disp('Test 8 passed.');
catch
    disp('Test 8 failed.');
end

%% Test 9: Combining 'axisColors' and 'axisLabels'
disp('Test 9: Plotting with both ''axisColors'' and ''axisLabels''...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'axisColors', axisColors, 'axisLabels', axisLabels);
    disp('Test 9 passed.');
catch
    disp('Test 9 failed.');
end

%% Test 10: Testing non-symmetric matrix with ranktype options (should issue a warning)
disp('Test 10: Plotting non-symmetric matrix with ''ranktype'' set to ''rank''...');
RDM = rand(4,4); % A random 4x4 matrix is unlikely to be symmetric
RDM(1,2) = 10;   % Ensure it's not symmetric
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'ranktype', 'rank');
    disp('Test 10 passed (check for warning).');
catch
    disp('Test 10 failed.');
end

%% Test 11: Testing 'iconPath' with custom icons for axis labels
disp('Test 11: Plotting with ''iconPath'' option...');
% iconPath should be an image file path. For this test, use placeholder string (adjust to actual file paths)
iconPath = {'path/to/icon1.png', 'path/to/icon2.png', 'path/to/icon3.png', 'path/to/icon4.png'};
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'iconPath', iconPath);
    disp('Test 11 passed.');
catch
    disp('Test 11 failed.');
end

%% Test 12: Testing 'iconSize' for customizing the size of the icons
disp('Test 12: Plotting with ''iconSize'' option...');
iconSize = 50;  % Example size in pixels
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'iconPath', iconPath, 'iconSize', iconSize);
    disp('Test 12 passed.');
catch
    disp('Test 12 failed.');
end

%% Test 13: Testing 'iconSize' and 'axisColors' together
disp('Test 13: Plotting with ''iconSize'' and ''axisColors'' options...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'iconPath', iconPath, 'iconSize', iconSize, 'axisColors', axisColors);
    disp('Test 13 passed.');
catch
    disp('Test 13 failed.');
end

%% Test 14: Testing combination of 'iconSize', 'iconPath', 'axisColors', and 'axisLabels'
disp('Test 14: Plotting with ''iconSize'', ''iconPath'', ''axisColors'', and ''axisLabels'' options...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'iconPath', iconPath, 'iconSize', iconSize, 'axisColors', axisColors, 'axisLabels', axisLabels);
    disp('Test 14 passed.');
catch
    disp('Test 14 failed.');
end

%% Test 15: Testing invalid 'ranktype' option
disp('Test 15: Plotting with invalid ''ranktype'' option (should throw an error)...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'ranktype', 'invalid_ranktype');
    disp('Test 15 failed (no error thrown).');
catch
    disp('Test 15 passed (error thrown as expected).');
end

%% Test 16: Testing empty 'iconPath' with 'iconSize'
disp('Test 16: Plotting with ''iconSize'' but no ''iconPath'' (should ignore iconSize)...');
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'iconSize', iconSize);
    disp('Test 16 passed.');
catch
    disp('Test 16 failed.');
end

%% Test 17: Testing mismatch in length of 'axisColors' and matrix dimensions
disp('Test 17: Plotting with mismatch between ''axisColors'' length and matrix size (should throw a warning)...');
RDM = rand(5);  % 5x5 matrix
axisColors = {'r', 'g', 'b'};  % Only 3 colors for 5x5 matrix
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'axisColors', axisColors);
    disp('Test 17 failed (no warning or error).');
catch
    disp('Test 17 passed (handled as expected).');
end

%% Test 18: Testing mismatch in 'axisLabels' length and matrix size
disp('Test 18: Plotting with mismatch between ''axisLabels'' length and matrix size (should throw a warning)...');
axisLabels = {'A', 'B', 'C'};  % Only 3 labels for a 5x5 matrix
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM, 'axisLabels', axisLabels);
    disp('Test 18 failed (no warning or error).');
catch
    disp('Test 18 passed (handled as expected).');
end

%% Test 19: Testing matrix with NaN values
disp('Test 19: Plotting matrix with NaN values...');
RDM = rand(5);
RDM(2,3) = NaN;  % Introduce NaN value
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 19 passed.');
catch
    disp('Test 19 failed.');
end

%% Test 20: Testing matrix with Inf values
disp('Test 20: Plotting matrix with Inf values...');
RDM = rand(5);
RDM(4,1) = Inf;  % Introduce Inf value
try
    [img, fig] = RSA.Visualization.plotMatrix(RDM);
    disp('Test 20 passed.');
catch
    disp('Test 20 failed.');
end

disp('All tests completed.');