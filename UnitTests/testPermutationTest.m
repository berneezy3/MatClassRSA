load 'losorelli_500sweep_epoched.mat'

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, Y);
[r c] = size(X_shuf);

trainData = X_shuf(1:floor(r*2/3), :);
trainLabels = Y_shuf(1:floor(r*2/3));
testData = X_shuf(floor(r*2/3)+1:end, :);
testLabels = Y_shuf(floor(r*2/3)+1:end);

trainData2 = [X_shuf(1:floor(r*1/3), :); X_shuf(floor(r*2/3)+1:end, :)];
trainLabels2 = [Y_shuf(1:floor(r*1/3)); Y_shuf(floor(r*2/3)+1:end)];
testData2 = X_shuf(floor(r*1/3)+1:floor(r*2/3), :);
testLabels2 = Y_shuf(floor(r*1/3)+1:floor(r*2/3));

trainData3 = X_shuf(floor(r*1/3)+1:end, :);
trainLabels3 = Y_shuf(floor(r*1/3)+1:end);
testData3 = X_shuf(1:floor(r*1/3), :);
testLabels3 = Y_shuf(1:floor(r*1/3));

mkdir(date)

%%

load 'S06.mat'
RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, labels6);
[~, ~, t] = size(X_shuf);

trainData = X_shuf(:, :, 1:floor(t*2/3));
trainLabels = Y_shuf( 1:floor(t*2/3) );
testData = X_shuf(:, :, floor(t*2/3)+1:end);
testLabels = Y_shuf(floor(t*2/3)+1:end);

mkdir(date)


%% Multiclass Classification

C_multi_LDA = RSA.Classification.crossValidateMulti(X_shuf, Y_shuf, ...
    'nFolds', 10, 'PCA', 0, 'classifier', 'LDA', 'PCAinFold', 0, 'permutations', 0);

C_multi_RF = RSA.Classification.crossValidateMulti(X_shuf, Y_shuf, ...
    'nFolds', 10, 'PCA', 0, 'classifier', 'RF', 'PCAinFold', 0, 'permutations', 0);

RSA.Visualization.plotMatrix(C_multi_LDA.CM, 'matrixLabels', 1);
title('Confusion Matrix, losorelli_500sweep, cvMulti(), LDA, 10 fold, ', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvMultiCM_LDA.jpg']);
close

RSA.Visualization.plotMatrix(C_multi_RF.CM, 'matrixLabels', 1);
title('Multiclass accuracy, losorelli_500sweep, cvMulti(), RF, 10 fold', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvMultiCM_RF.jpg']);
close


%% Optimized Multiclass Classification

% single opt fold
C_multi_opt_sf = RSA.Classification.crossValidateMulti_opt(X_shuf, Y_shuf, ...
    'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 1, 'permutations', 20, ...
    'trainDevSplit', [.8 .2], 'nFolds', 3, 'optimization', 'nestedCV');

RSA.Visualization.plotMatrix(C_multi_opt_sf.CM, 'matrixLabels', 1);
title('Confusion Matrix, losorelli_500sweep, cvMulti_opt(), singleFold, LDA, 20 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvMultiOptCM_SVM_sf.jpg']);
close
%%
% multiple opt fold
C_multi_opt_ncv = RSA.Classification.crossValidateMulti_opt(X_shuf, Y_shuf, ...
    'PCA', 0, 'classifier', 'SVM', 'PCAinFold', 0, 'permutations', 0, ...
    'nFolds', 10, 'optimization', 'nestedCV');

RSA.Visualization.plotMatrix(C_multi_opt_ncv.CM, 'matrixLabels', 1);
title('Multiclass accuracy, losorelli_500sweep, cvMulti_opt(), nestedCV, SVM, 20 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvMultiOptCM_SVM_ncv.jpg']);
close
%% Multiclass Train/Test Classification

[M_tt_multi_LDA, permTestData] = RSA.Classification.trainMulti( trainData , trainLabels, ...
    'classifier', 'LDA', 'PCA', 0.99, 'randomSeed', 1);

C_tt_multi_LDA = RSA.Classification.predict( M_tt_multi_LDA, testData, ...
    'actualLabels', testLabels, 'permutations', 100, 'permTestData', permTestData);

RSA.Visualization.plotMatrix(C_tt_multi_LDA.CM, 'matrixLabels', 1);
title('Multiclass accuracy, losorelli_500sweep, trainMulti()/predict(), LDA, 100 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainMultiPredictCM_LDA.jpg']);
close
%%
[M_tt_multi_RF, permTestData] = RSA.Classification.trainMulti( trainData, trainLabels, ...
    'classifier', 'RF', 'PCA', 0.99, 'randomSeed', 1);

C_tt_multi_RF = RSA.Classification.predict( M_tt_multi_RF, testData, ...
    'actualLabels', testLabels, 'permutations', 100, 'permTestData', permTestData);
%%
RSA.Visualization.plotMatrix(C_tt_multi_RF.CM, 'matrixLabels', 1);
title('Multiclass accuracy, losorelli_500sweep, trainMulti()/predict(), RF, 100 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainMultiPredictCM_RF.jpg']);
close

%% Optimized multiclass Train/Test Classification

[M_tt_multi_opt_sf, permTestData] = RSA.Classification.trainMulti_opt( ...
    trainData , trainLabels, 'classifier', 'SVM', 'PCA', 0.99, 'PCAinFold', true, ...
    'randomSeed', 1, 'optimization', 'singleFold', 'trainDevSplit', [.8 .2]);

C_tt_multi_opt_sf = RSA.Classification.predict( M_tt_multi_opt_sf, testData, ...
    'actualLabels', testLabels);

RSA.Visualization.plotMatrix(C_tt_multi_opt_sf.CM, 'matrixLabels', 1);
title('Confusion Matrix, losorelli_500sweep, train_opt()/predict(), singleFold, SVM, 20 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainOptCM_SVM_sf.jpg']);
close

%%

[M_tt_multi_opt_ncv, permTestData] = RSA.Classification.trainMulti_opt( trainData , trainLabels, ...
    'classifier', 'SVM', 'PCA', 0, 'randomSeed', 1, 'optimization', 'nestedCV', 'nFolds_opt', 3, 'permutations', 20);
%%
C_tt_multi_opt_ncv = RSA.Classification.predict( M_tt_multi_opt_ncv, testData, ...
    'actualLabels', testLabels, 'permTestData', permTestData, 'permutations', 20);

RSA.Visualization.plotMatrix(C_tt_multi_opt_ncv.CM, 'matrixLabels', 1);
title('Confusion Matrix, losorelli_500sweep, train_opt()/predict(), singleFold, SVM, 20 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainOptCM_SVM_ncv.jpg']);
close


%% Pairwise Classification

% PCA in fold
C_pairs_LDA_inFold = RSA.Classification.crossValidatePairs(X_shuf, Y_shuf, 'PCA', .99,...
    'classifier', 'LDA', 'PCAinFold', 1, 'permutations', 30, 'nFolds', 3);

RSA.Visualization.plotMatrix(C_pairs_LDA_inFold.AM, 'matrixLabels', 1);
title(['Pairwise accuracy, losorelli_500sweep, crossValidatePairs(), LDA, '...
    'PCA in Folds'], 'Interpreter', 'none');
caxis([0 1])
colorbar('Ticks', 0:.1:1)
saveas(gcf,[date '/cvPairsAccuracy_LDA(PCAinFolds).jpg']);
close

figure
RSA.Visualization.plotMatrix(C_pairs_LDA_inFold.pValMat, 'matrixLabels', 1);
title(['Pairwise p-val, losorelli_500sweep, crossValidatePairs(), LDA, '...
    ' PCA in Folds, 30 perms'], 'Interpreter', 'none');
caxis([0 1])
colorbar('Ticks', 0:.1:1)
saveas(gcf,[date '/cvPairsPVals_LDA(PCAinFolds).jpg']);
close

%% 
%PCA out of folds

C_pairs_LDA_outFold = RSA.Classification.crossValidatePairs(X_shuf, Y_shuf, 'PCA', .99,...
    'classifier', 'LDA', 'PCAinFold', 0, 'permutations', 0, 'nFolds', 3);
%%
RSA.Visualization.plotMatrix(C_pairs_LDA_outFold.AM, 'matrixLabels', 1);
title(['Pairwise accuracy, losorelli_500sweep, crossValidatePairs(), LDA, '...
    'PCA not in Folds'], 'Interpreter', 'none');
caxis([0 1])
colorbar('Ticks', 0:.1:1)
saveas(gcf,[date '/cvPairsAccuracy_LDA(PCAnotInFolds).jpg']);
close

figure
RSA.Visualization.plotMatrix(C_pairs_LDA_outFold.pValMat, 'matrixLabels', 1);
title(['Pairwise p-val, losorelli_500sweep, crossValidatePairs(), LDA, '...
    ' PCA not in Folds, 30 perms'], 'Interpreter', 'none');
caxis([0 1])
colorbar('Ticks', 0:.1:1)
saveas(gcf,[date '/cvPairsPVals_LDA(PCAnotInFolds).jpg']);
close


%%

C_pairs_RF = RSA.Classification.crossValidatePairs(X_shuf, Y_shuf, 'PCA', 0.99,...
    'classifier', 'RF', 'permutations', 30, 'nFolds', 3);

RSA.Visualization.plotMatrix(C_pairs_RF.AM, 'matrixLabels', 1);
title('Pairwise accuracy, losorelli_500sweep, crossValidatePairs(), RF', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvPairsAccuracy_RF.jpg']);
close

figure
RSA.Visualization.plotMatrix(C_pairs_RF.pValMat, 'matrixLabels', 1);
title('Pairwise p-val, losorelli_500sweep, crossValidatePairs(), RF, 30 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvPairsPVals_RF.jpg']);
close


%% Optimized Pairwise Classification
%% SVM (PCA; slow)

C_pairs_opt = RSA.Classification.crossValidatePairs_opt(X_shuf(1:100, :), Y_shuf(1:100), ...
    'PCA', .99, 'classifier', 'SVM', 'PCAinFold', false, 'permutations', 2, ...
    'nFolds', 3);

%% SVM (no PCA; fast)

C_pairs_opt = RSA.Classification.crossValidatePairs_opt(X_shuf, Y_shuf, ...
    'PCA', 0.99, 'classifier', 'SVM', 'permutations', 10, 'nFolds', 3, 'PCAinFold', false);

RSA.Visualization.plotMatrix(C_pairs_opt.AM, 'matrixLabels', 1);
title('Pairwise accuracy, losorelli_500sweep, crossValidatePairs_opt(), SVM(fast)', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvPairsOptAccuracy.jpg']);
close

figure
RSA.Visualization.plotMatrix(C_pairs_opt.pValMat, 'matrixLabels', 1);
title('Pairwise p-val, losorelli_500sweep, crossValidatePairs_opt(), SVM(fast), 20 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/cvPairsOptPVals.jpg']);
close


%%

C_pairs_opt = RSA.Classification.crossValidatePairs_opt(X_shuf, Y_shuf, ...
    'PCA', 0, 'classifier', 'SVM', 'permutations', 2, 'nFolds', 3, 'PCAinFold', false);

%% Pairwise Train/Test

[M_tt_pairs_LDA, permTestData] = RSA.Classification.trainPairs( trainData, trainLabels, ...
    'classifier', 'LDA', 'PCA', 0.99, 'randomSeed', 1);

C_tt_pairs_LDA = RSA.Classification.predict( M_tt_pairs_LDA, testData, ...
    'actualLabels', testLabels, 'permutations', 0, 'permTestData', permTestData);
%%
[M_tt_pairs_RF, permTestData] = RSA.Classification.trainPairs( trainData, trainLabels, ...
    'classifier', 'RF', 'PCA', .99, 'randomSeed', 1);

C_tt_pairs_RF = RSA.Classification.predict( M_tt_pairs_RF, testData, ...
    'actualLabels', testLabels, 'permutations', 0, 'permTestData', permTestData);
%%
figure
RSA.Visualization.plotMatrix(C_tt_pairs_LDA.pValMat, 'matrixLabels', 1);
title('Pairwise p-val, losorelli_500sweep, crossValidatePairs(), LDA, 100 perms', 'Interpreter', 'none');
colorbar
saveas(gcf,[date '/ttPairsPVals_LDA.jpg']);
close

figure
RSA.Visualization.plotMatrix(C_tt_pairs_LDA.AM, 'matrixLabels', 1);
title('Pairwise accuracy matrix, losorelli_500sweep, crossValidatePairs(), LDA, 100 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/ttPairsAccMat_LDA.jpg']);
close
%%
figure
RSA.Visualization.plotMatrix(C_tt_pairs_RF.pValMat, 'matrixLabels', 1);
title('Pairwise p-val, losorelli_500sweep, trainPairs()/predict(), RF, 100 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/ttPairsPVals_RF.jpg']);
close
%%
figure
RSA.Visualization.plotMatrix(C_tt_pairs_RF.AM, 'matrixLabels', 1);
title('Pairwise accuracy matrix, losorelli_500sweep, trainPairs()/predict(), RF, 100 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/ttPairsAccMat_RF.jpg']);
close

%% Optimized Pairwise Train/Test
%% SVM (PCA)

[M_tt_pairs_opt, permTestData] = RSA.Classification.trainPairs_opt( trainData , trainLabels, ...
    'classifier', 'SVM', 'PCA', .99, 'randomSeed', 1 , 'permutations', 3);

C_tt_pairs_opt = RSA.Classification.predict( M_tt_pairs_opt, testData, testLabels, 'permutations', 10);
%%

RSA.Visualization.plotMatrix(C_tt_pairs_opt.AM, 'matrixLabels', 1);
title('Pairwise accuracy, losorelli_500sweep, trainPairs_opt()/predict(), SVM(fast)', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainPairsOptAccuracy.jpg']);
close

figure
RSA.Visualization.plotMatrix(C_tt_pairs_opt.pValMat, 'matrixLabels', 1);
title('Pairwise p-val, losorelli_500sweep, trainPairs_opt()/predict(), SVM(fast), 10 perms', 'Interpreter', 'none')
colorbar
saveas(gcf,[date '/trainPairsOptPVals.jpg']);
close

%%

M_tt_pairs_opt2 = RSA.Classification.trainPairs_opt( trainData , trainLabels, ...
    'classifier', 'SVM', 'PCA', 0, 'randomSeed', 1. , 'permutations', 3);
%%

C_tt_pairs_opt2 = RSA.Classification.predict( M_tt_pairs_opt, testData, testLabels, 'permutations', 10);

