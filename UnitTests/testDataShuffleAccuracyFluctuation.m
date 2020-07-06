%  Load S06.m
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S6.mat.'''))
inDir = uigetdir(pwd);
cd(inDir)
load S06.mat


%% Test EEG classification with different data shuffling
[CM, acc, predY, pVal, classifierInfo] = classifyEEG(X, ...
labels6, 'PCAinFold', 0, 'classify', 'LDA', 'randomSeed', 1);
acc
%%
[CM, acc, predY, pVal, classifierInfo] = classifyEEG(X, ...
labels6, 'PCAinFold', 0, 'classify', 'LDA', 'randomSeed', 2);
acc
%%
[CM, acc, predY, pVal, classifierInfo] = classifyEEG(X, ...
labels6, 'PCAinFold', 1, 'classify', 'LDA', 'randomSeed', 5);
acc
%%
[CM, acc, predY, pVal, classifierInfo] = classifyEEG(X, ...
labels6, 'PCAinFold', 1, 'randomSeed', 7);
acc
