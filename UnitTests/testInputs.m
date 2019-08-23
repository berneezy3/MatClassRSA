

%%
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%

M = classifyTrain( X_2D(1:floor(end/5), :) , categoryLabels(1:floor(end/5)), 'classifier', 'LDA', 'PCA', 0);

%%


M = classifyTrain( X_2D(1:floor(end/5), :) , categoryLabels(1:floor(end/5)), 'classifier', 'SVM', 'PCA', 0, 'verbose', 1);

%%

M = classifyTrain( X_2D(1:floor(end/5), :) , categoryLabels(1:floor(end/5)), 'classifier', 'RF', 'PCA', 0);

%%

C = classifyPredict( M, X_2D(floor(end/5+1:end), :),  categoryLabels(floor(end/5+1:end)));

%%

C = classifyPredict( M, X_2D(floor(end/5+1:end), :),  categoryLabels(floor(end/5+1:end)));

%%


