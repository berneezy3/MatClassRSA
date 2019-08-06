%% 2 class tie

nClasses = 2; % number of classes
nDecVals = nClasses * (nClasses-1)/2;
decisionVals = zeros(1, nDecVals);
[indOfWinner tallies] = SVMhandleties(decisionVals, [2 1]);

%% check basic 2-class case runs correctly

nClasses = 2; % number of classes
nDecVals = nClasses * (nClasses-1)/2;
classOrder = [2 1];
decisionVals = zeros(1, nDecVals);
decisionVals = .0001
[indOfWinner tallies] = SVMhandleties(decisionVals, classOrder);
assert(indOfWinner == 2);
assert(classOrder(indOfWinner) == 1);
assert( isequal(tallies, [0 1]) )

%% check basic 3-class case runs correct

nClasses = 3; % number of classes
nDecVals = nClasses * (nClasses-1)/2;
classOrder = [2 3 1];
decisionVals = zeros(1, nDecVals);
decisionVals = [-.5 -.4 .7];
[indOfWinner tallies] = SVMhandleties(decisionVals, classOrder);
assert(indOfWinner == 1);
assert(classOrder(indOfWinner) == 2);
assert( isequal(tallies, [2 0 1]) );

%% check basic 3-class case runs correct

nClasses = 3; % number of classes
nDecVals = nClasses * (nClasses-1)/2;
classOrder = [2 3 1];
decisionVals = zeros(1, nDecVals);
decisionVals = [.5 -.4 .7];
[indOfWinner tallies] = SVMhandleties(decisionVals, classOrder);
% indOfWinner could be either 1,2 or 3 in this case!!!
assert( isequal(tallies, [1 1 1]) );

%%

uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%%

[libsvmC] = classifyCrossValidate(X_3D, ...
    categoryLabels, "PCAinFold", 0, 'classifier', 'SVM');