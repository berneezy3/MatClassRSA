load 'losorelli_500sweep_epoched.mat'

[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, Y);
[r c] = size(X_shuf);

trainData = X_shuf(1:floor(r*9/10), :);
trainLabels = Y_shuf(1:floor(r*9/10));
testData = X_shuf(floor(r*9/10)+1:end, :);
testLabels = Y_shuf(floor(r*9/10)+1:end);


%% Multiclass Classification

C_multi = RSA.Classification.crossValidateMulti(X_shuf, Y_shuf, 'PCA', 0, 'classifier', 'LDA', 'PCAinFold', 0, 'permutations', 20);


%% Optimized Multiclass Classification

C_multi_opt = RSA.Classification.crossValidateMulti_opt(X_shuf, Y_shuf, 'PCA', 0, 'classifier', 'SVM', 'PCAinFold', 0, 'permutations', 20);

%% Multiclass Train/Test Classification

M_tt_multi = RSA.Classification.trainMulti( trainData , trainLabels, ...
    'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C_tt_multi = RSA.Classification.predict( M_tt_multi, testData, testLabels, 'permutations', 10);

%% Optimized multiclass Train/Test Classification

M_tt_multi_opt = RSA.Classification.trainMulti_opt( trainData , trainLabels, ...
    'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C_tt_multi_opt = RSA.Classification.predict( M_tt_multi_opt, testData, testLabels, 'permutations', 10);


%% Pairwise Classification

C_pairs = RSA.Classification.crossValidatePairs(X_shuf, Y_shuf, 'PCA', .99,...
    'classifier', 'LDA', 'PCAinFold', 0, 'permutations', 100);

%% Optimized Pairwise Classification
%% SVM (PCA)

C_pairs_opt = RSA.Classification.crossValidatePairs_opt(X_shuf, Y_shuf, ...
    'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 1, 'permutations', 20);

%% SVM (no PCA)

C_pairs_opt = RSA.Classification.crossValidatePairs_opt(X_shuf, Y_shuf, ...
    'PCA', 0, 'classifier', 'SVM', 'permutations', 1);

%% Pairwise Train/Test

M_tt_pairs = RSA.Classification.trainPairs( trainData , trainLabels, ...
    'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C_tt_pairs = RSA.Classification.predict( M_tt_pairs, testData, testLabels, 'permutations', 10);


%% Optimized Pairwise Train/Test
%% SVM (PCA)

M_tt_pairs_opt = RSA.Classification.trainPairs_opt( trainData , trainLabels, ...
    'classifier', 'SVM', 'PCA', 0, 'randomSeed', 1);
C_tt_pairs_opt = RSA.Classification.predict( M_tt_pairs_opt, testData, testLabels, 'permutations', 100);


