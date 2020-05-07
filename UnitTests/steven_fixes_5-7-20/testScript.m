load '../losorelli_500sweep_epoched.mat'

[X_shuf,Y_shuf] = shuffleData(X, Y);
[X_avg,Y_avg] = averageTrials(X_shuf, Y_shuf, 5);


%% test CV once to get a good idea of runtime for single iteration


C = classifyCrossValidateMulti(X_avg, Y_avg, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true, 'scale', true);
plotMatrix(C.CM);
colorbar;


%% test CV once to get a good idea of runtime for single iteration

M = classifyTrainMulti( X_avg(1:50,:), Y_avg(1:50), 'classifier', 'LDA', ...
    'PCA', .99, 'randomSeed', 1, 'center', true, 'scale', true);
C = classifyPredict( M, X_avg(51:end,:),  Y_avg(51:end));

