% test_v2_Visualization_plotMatrix.m
% -------------------------------------
% Ray - March 2024

clear all; close all; clc

% Initialize the RSA object
RSA = MatClassRSA;

%% Test 1: Plotting a 5x5 random symmetric matrix
disp('Test 1: Plotting a 5x5 random symmetric matrix...');
RDM = rand(5);
RDM = (RDM + RDM') / 2;  % Make it symmetric
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 1 passed.');
catch
    disp('Test 1 failed.');
end

%% Test 2: Plotting a non-symmetric matrix (expect a warning)
disp('Test 2: Plotting a non-symmetric matrix (expect a warning)...');
RDM = rand(5, 5);  % Random non-symmetric matrix
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 2 passed.');
catch
    disp('Test 2 failed.');
end

%% Test 3: Plotting with 'nodeColors' option
disp('Test 3: Plotting with ''nodeColors'' option...');
RDM = rand(5);
RDM = (RDM + RDM') / 2;  % Symmetric matrix
nodeColors = {'r', 'g', 'b', 'y', 'm'};  % Red, green, blue, yellow, magenta
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeColors', nodeColors);
    disp('Test 3 passed.');
catch
    disp('Test 3 failed.');
end

%% Test 4: Plotting with 'nodeLabels' option
disp('Test 4: Plotting with ''nodeLabels'' option...');
nodeLabels = {'Class1', 'Class2', 'Class3', 'Class4', 'Class5'};
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeLabels', nodeLabels);
    disp('Test 4 passed.');
catch
    disp('Test 4 failed.');
end

%% Test 5: Plotting with 'iconPath' option (using placeholder icons)
disp('Test 5: Plotting with ''iconPath'' option...');
% Provide a placeholder path for icons (update paths accordingly)
iconPath = './testVisualizations/stimuli/';
try
    fig = RSA.Visualization.plotMDS(RDM, 'iconPath', iconPath);
    disp('Test 5 passed.');
catch
    disp('Test 5 failed.');
end

%% Test 6: Plotting with 'dimensions' option
disp('Test 6: Plotting with ''dimensions'' option...');
dimensions = [1 3];  % Display 1st and 3rd dimensions
try
    fig = RSA.Visualization.plotMDS(RDM, 'dimensions', dimensions);
    disp('Test 6 passed.');
catch
    disp('Test 6 failed.');
end

%% Test 7: Plotting with 'xLim' and 'yLim' options
disp('Test 7: Plotting with ''xLim'' and ''yLim'' options...');
xLim = [-1 1];  % Limit X-axis from -1 to 1
yLim = [-1 1];  % Limit Y-axis from -1 to 1
try
    fig = RSA.Visualization.plotMDS(RDM, 'xLim', xLim, 'yLim', yLim);
    disp('Test 7 passed.');
catch
    disp('Test 7 failed.');
end

%% Test 8: Plotting with 'classical' set to false (non-classical MDS)
disp('Test 8: Plotting with ''classical'' set to false...');
try
    fig = RSA.Visualization.plotMDS(RDM, 'classical', false);
    disp('Test 8 passed.');
catch
    disp('Test 8 failed.');
end

%% Test 9: Plotting with both 'nodeColors' and 'nodeLabels' options
disp('Test 9: Plotting with both ''nodeColors'' and ''nodeLabels'' options...');
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeColors', nodeColors, 'nodeLabels', nodeLabels);
    disp('Test 9 passed.');
catch
    disp('Test 9 failed.');
end

%% Test 10: Plotting with 'nodeColors' and 'iconPath' options
disp('Test 10: Plotting with ''nodeColors'' and ''iconPath'' options...');
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeColors', nodeColors, 'iconPath', iconPath);
    disp('Test 10 passed.');
catch
    disp('Test 10 failed.');
end

%% Test 11: Plotting with invalid 'dimensions' input (should throw an error)
disp('Test 11: Plotting with invalid ''dimensions'' input (should throw an error)...');
invalidDimensions = [5 6];  % Dimensions out of range
try
    fig = RSA.Visualization.plotMDS(RDM, 'dimensions', invalidDimensions);
    disp('Test 11 failed (no error).');
catch
    disp('Test 11 passed (error thrown as expected).');
end

%% Test 12: Plotting an empty matrix (expect an error)
disp('Test 12: Plotting an empty matrix...');
RDM = [];
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 12 failed (no error thrown).');
catch
    disp('Test 12 passed (error thrown as expected).');
end

%% Test 13: Plotting a diagonal matrix
disp('Test 13: Plotting a diagonal matrix...');
RDM = eye(5);  % Diagonal matrix
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 13 passed.');
catch
    disp('Test 13 failed.');
end

%% Test 14: Plotting with too many 'nodeColors' (should handle mismatch)
disp('Test 14: Plotting with too many ''nodeColors''...');
RDM = rand(4);
RDM = (RDM + RDM') / 2;  % Symmetric matrix
nodeColors = {'r', 'g', 'b', 'y', 'm'};  % 5 colors for 4 nodes
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeColors', nodeColors);
    disp('Test 14 passed.');
catch
    disp('Test 14 failed.');
end

%% Test 15: Plotting with too few 'nodeLabels' (should handle mismatch)
disp('Test 15: Plotting with too few ''nodeLabels''...');
nodeLabels = {'Class1', 'Class2'};
try
    fig = RSA.Visualization.plotMDS(RDM, 'nodeLabels', nodeLabels);
    disp('Test 15 failed (no error or warning).');
catch
    disp('Test 15 passed (handled correctly).');
end

%% Test 16: Plotting with invalid 'iconPath' (should throw error)
disp('Test 16: Plotting with invalid ''iconPath''...');
invalidIconPath = {'invalid_path1.png', 'invalid_path2.png'};
try
    fig = RSA.Visualization.plotMDS(RDM, 'iconPath', invalidIconPath);
    disp('Test 16 failed (no error thrown).');
catch
    disp('Test 16 passed (error thrown as expected).');
end

%% Test 17: Plotting a zero matrix
disp('Test 17: Plotting a zero matrix...');
RDM = zeros(5);  % 5x5 matrix of zeros
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 17 passed.');
catch
    disp('Test 17 failed.');
end

%% Test 18: Plotting with high-dimensional data
disp('Test 18: Plotting with high-dimensional data...');
RDM = rand(5);  % Random 5x5 symmetric matrix
RDM = (RDM + RDM') / 2;
dimensions = [1 3];  % Display 1st and 3rd dimensions
try
    fig = RSA.Visualization.plotMDS(RDM, 'dimensions', dimensions);
    disp('Test 18 passed.');
catch
    disp('Test 18 failed.');
end

%% Test 19: Plotting a large 100x100 random symmetric matrix
disp('Test 19: Plotting a large 100x100 random symmetric matrix...');
RDM = rand(100);
RDM = (RDM + RDM') / 2;  % Make it symmetric
try
    fig = RSA.Visualization.plotMDS(RDM);
    disp('Test 19 passed.');
catch
    disp('Test 19 failed.');
end
