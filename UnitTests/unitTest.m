%%
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load S6.mat
cd(currDir)
%%

% M = classifyTrain( X_2D(1:end-10, :) , categoryLabels(1:end-10), 'classify', 'LDA', 'PCA', 0);

%%
M = classifyTrain(X_2D(1:end-10, :), categoryLabels(1:end-10), 'classify', 'LDA', 'PCA', .5);

%%
C = classifyPredict( M, X_2D(end-10:end, :) );

%% TEST FOR AVERAGE TRIALS IN classifyTrain and classifyPredict!

% M = classifyTrain(X_2D(1:end-500, :), categoryLabels(1:end-500), 'classify', 'LDA', ...
%     'PCA', .9, 'averageTrials', 2, 'averageTrialsHandleRemainder', 'discard');
%%

% C = classifyPredict( M, X_2D(end-500:end, :), 'actualLabels', categoryLabels(end-500:end));

%%

% M = classifyTrain(X_3D(:, : , 1:end-500), categoryLabels(1:end-500), 'classify', 'LDA', ...
%     'PCA', .9, 'averageTrials', 2, 'averageTrialsHandleRemainder', 'discard');

%%

% C = classifyPredict( M, X_3D(:,:, end-500:end), 'actualLabels',categoryLabels(end-500:end), 'averageTrials', 2 );

%%
% 
% C = classifyPredict( M, X_2D(end-500:end, :), 'actualLabels',categoryLabels(end-500:end), 'averageTrials', 2, ...
%     'averageTrialsHandleRemainder', 'append');
% 

%% 

% C = classifyPredict( M, X_2D(end-50:end, :), 'actualLabels',categoryLabels(end-50:end));


%%
% testY = categoryLabels(end-10:end)
% 
% C = classifyPredict(M, X_2D(end-10:end, :), testY);
% 

%%

[C] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'randomSeed', 'default', 'PCAinFold', 0, 'pairwise', 1);
%%



%%

% Call the classification function
[C] = classifyCrossValidate(X_3D, ...
    categoryLabels, 'randomSeed', 'default', 'classifier', 'LDA', "PCAinFold", 0);

%%
% Convert the confusion matrix to an RDM
RDM = computeRDM(C.CM);
 %%
 
% Create the four visualizations
f1 = plotMatrix(RDM, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
 %%
 f5 = plotMatrix(C.CM, 'colormap', 'summer', ...
    'axisLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
     'axisColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
 %%
f2 = plotMDS(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });
%%
f3 = plotDendrogram(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' }, 'fontSize', 30);
%%
f4 = plotMST(RDM, 'nodeLabels', {'HB' 'HF' 'AB' 'AF' 'FV' 'IO'}, ...
'nodeColors', {[1 .5 .3] [.1 .5 1] 'r' 'g' 'c' 'm' });

%%
%%

%%