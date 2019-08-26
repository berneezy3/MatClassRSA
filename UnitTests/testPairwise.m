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