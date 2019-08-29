%%
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%% test SVM pairwise classification


[svmC] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'classifier', 'SVM', 'randomSeed', 'default', 'PCAinFold', 0, 'pairwise', 1);

%% test LDA pairwise classification


[ldaC] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'classifier', 'LDA', 'randomSeed', 'default', 'PCAinFold', 0, 'pairwise', 1);


%% test RF pairwise classification


[C] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'classifier', 'RF','randomSeed', 'default', 'PCAinFold', 0, 'pairwise', 1);

%%
trainSet = X_2D( 1:floor(end/5), :);
trainLabels = categoryLabels(1:floor(end/5));
M = classifyTrain( trainSet , trainLabels, 'classifier', 'SVM', 'pairwise', 1);
testData = X_2D( floor(end/5)+1:end, :);
testLabels = categoryLabels(floor(end/5)+1:end:end);
P = classifyPredict(M, testData);
%%
trainSet = X_2D( 1:floor(end/5), :);
trainLabels = categoryLabels(1:floor(end/5));
M = classifyTrain( trainSet , trainLabels, 'classifier', 'LDA', 'pairwise', 1);
testData = X_2D( floor(end/5)+1:end, :);
testLabels = categoryLabels(floor(end/5)+1:end:end);
P = classifyPredict(M, testData);
%%
trainSet = X_2D( 1:floor(end/5), :);
trainLabels = categoryLabels(1:floor(end/5));
M = classifyTrain( trainSet , trainLabels, 'classifier', 'RF', 'pairwise', 1);
%%
testData = X_2D( floor(end/5)+1:end, :);
testLabels = categoryLabels(floor(end/5)+1:end:end);
P = classifyPredict(M, testData);

%%

C = classifyPredict( M, X_2D(floor(end/5+1:end), :),  categoryLabels(floor(end/5+1:end)));
