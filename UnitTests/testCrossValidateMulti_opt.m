% test classifyCrossValidateMulti_optimize

%% run optimized SVM on Steven's data
clear
load 'losorelli_500sweep_epoched.mat'

functionName = {'crossValidateMulti_opt/predict'; 'crossValidate_opt/predict'};
accuracy = zeros(2, 1);
dataset = {'Steven_500'; 'S06'};
classifier = {'SVM'; 'SVM'};
optimization = {'on'; 'on'};
shuffle = {'on'; 'on'};
averageTrials = {'on'; 'off'};
dataSplit = {'N/A'; 'N/A'};
PCA = {'0'; '.99'};

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, Y);
tic
C_noopt = RSA.classify.crossValidateMulti_opt(X_shuf, Y_shuf, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 0);
toc
accuracy(1) = C_noopt.accuracy;


%% run optimized SVM on Blair's S06 data 

load 'S06.mat'
RSA = MatClassRSA;
[dim1, dim2, dim3] = size(X);
X = reshape(X, [dim1*dim2, dim3]);
X = X';
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, labels6);
[X_avg,Y_avg] = RSA.preprocess.averageTrials(X_shuf,Y_shuf, 5);
[r c] = size(X_avg);
C_opt = RSA.classify.crossValidateMulti_opt(X_avg, Y_avg, 'PCA', .99, 'classifier', 'SVM');
accuracy(2) = C_opt.accuracy;

%%

T = table(functionName, dataset, accuracy, shuffle, classifier, optimization, averageTrials, dataSplit);
logResults(T, 'crossValidateMulti_opt');

%% Results should match this paper:
% https://www.biorxiv.org/content/10.1101/661066v1

tic
C_LDA = classifyCrossValidateMulti(X_avg, Y_avg, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0);
toc
RSA.visualize.plotMatrix(C_LDA.CM)
colorbar