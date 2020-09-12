

%%
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S06.mat
cd(currDir)
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';
%%

M = classifyTrain( X_2D(1:floor(end/5), :) , labels6(1:floor(end/5)), 'classifier', 'LDA', 'PCA', 0);

%%


M = classifyTrain( X_2D(1:floor(end/5), :) , labels6(1:floor(end/5)), 'classifier', 'SVM', 'PCA', 0, 'verbose', 1);

%%

M = classifyTrain( X_2D(1:floor(end/5), :) , labels6(1:floor(end/5)), 'classifier', 'RF', 'PCA', 0, 'randomSeed', 3);

%%

C = classifyPredict( M, X_2D(floor(end/5+1:end), :),  labels6(floor(end/5+1:end)));

%%

C = classifyPredict( M, X_2D(floor(end/5+1:end), :),  labels6(floor(end/5+1:end)));

%%


