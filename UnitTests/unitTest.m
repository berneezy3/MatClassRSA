uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%%
[M, V, nPC] = classifyTrain(X_3D, categoryLabels, 'classify', 'LDA');
%%
M = classifyTrain(X_3D, categoryLabels, 'classify', 'LDA', 'PCA', 0);