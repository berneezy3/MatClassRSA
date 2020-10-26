% test classifyCrossValidateMulti
clear
load 'losorelli_500sweep_epoched.mat'

functionName = {'crossValidateMulti_opt/predict'; 'crossValidate_opt/predict'};
accuracy = zeros(2, 1);
dataset = {'Steven_500'; 'S06'};
classifier = {'LDA'; 'LDA'};
optimization = {'NA'; 'NA'};
shuffle = {'on'; 'on'};
averageTrials = {'off'; 'on'};
dataSplit = {'N/A'; 'N/A'};
PCA = {'0'; '.99'};

RSA = MatClassRSA;

[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, Y);

%%
tic
C_multi = RSA.Classification.crossValidateMulti(X_shuf, Y_shuf, 'PCA', 0, 'classifier', 'LDA', 'PCAinFold', 0);
toc
accuracy(1) = C_multi.accuracy;

%%

C_multi = RSA.Classification.crossValidateMulti(X, Y, 'PCA', 0, 'classifier', 'RF', 'PCAinFold', 0);


%% test permutation testing

C_multi = RSA.Classification.crossValidateMulti(X, Y, 'PCA', 0, 'classifier', 'LDA', 'PCAinFold', 0, 'permutations', 200);


%% S06 

load 'S06.mat'
RSA = MatClassRSA;
[dim1, dim2, dim3] = size(X);
X = reshape(X, [dim1*dim2, dim3]);
X = X';
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, labels6);
[X_avg,Y_avg] = RSA.Preprocessing.averageTrials(X_shuf,Y_shuf, 5);
[r c] = size(X_avg);
C = RSA.classify.crossValidateMulti(X_avg, Y_avg, 'PCA', .99, 'classifier', 'LDA');
accuracy(2) = C.accuracy;

%%

C = RSA.Classification.crossValidateMulti(X_avg, Y_avg, 'PCA', 0, 'classifier', 'RF');


%%

T = table(functionName, dataset, accuracy, shuffle, classifier, optimization, averageTrials, dataSplit);
logResults(T, 'crossValidateMulti');