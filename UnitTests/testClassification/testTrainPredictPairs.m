% test classifyCrossValidateMulti
clear
load 'losorelli_500sweep_epoched.mat'

functionName = {'crossValidateMulti_opt/predict'; 'crossValidate_opt/predict'};
accuracy = zeros(2, 1);
dataset = {'Steven_500'; 'S06'};
classifier = {'LDA'; 'LDA'};
optimization = {'on'; 'on'};
shuffle = {'on'; 'on'};
averageTrials = {'off'; 'on'};
dataSplit = {'N/A'; 'N/A'};
PCA = {'0'; '.99'};

%%

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, Y);
[r c] = size(X_shuf);
trainData = X_shuf(1:floor(r*9/10), :);
trainLabels = Y_shuf(1:floor(r*9/10));
testData = X_shuf(floor(r*9/10)+1:end, :);
testLabels = Y_shuf(floor(r*9/10)+1:end);

%% LDA
M_tt_pairs = RSA.Classification.trainPairs( trainData , trainLabels, ...
    'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C_tt_pairs = RSA.Classification.predict(M_tt_pairs, testData, testLabels);

%% SVM (PCA)
gamma_opt = 0.0032;
C_opt =  316.2278;

M = RSA.Classification.trainPairs( trainData , trainLabels, 'classifier', 'SVM', ...
    'PCA', .99, 'randomSeed', 1, 'gamma', gamma_opt, 'C', C_opt);
C = RSA.Classification.predict( M, testData, testLabels);

%% SVM (no PCA)
gamma_opt = 0.0032;
C_opt =  316.2278;

M = RSA.Classification.trainPairs( trainData , trainLabels, ...
    'classifier', 'SVM', 'PCA', 0, 'gamma', gamma_opt, 'C', C_opt);
C = RSA.Classification.predict( M, testData, testLabels);

%% RF

M = RSA.Classification.trainPairs( trainData , trainLabels, ...
    'classifier', 'RF', 'PCA', 0, 'randomSeed', 1);
C = RSA.Classification.predict(M, testData, testLabels);

