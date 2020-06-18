
load 'losorelli_100sweep_epoched.mat'
functionName = {'trainMulti_opt/predict', 'trainMulti_opt/predict'};
accuracy = zeros(1, 2);
dataset = {'Steven_500', 'S06'};
classifier = {'SVM', 'SVM'};
optimization = {'on', 'on'};
shuffle = {'on', 'on'};
averageTrials = {'on', 'off'};
dataSplit = {'90/10', '90/10'};
PCA = {'0', '.99'};
%% Steven 500 data

load 'losorelli_500sweep_epoched.mat'
RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, Y);
[r c] = size(X_shuf);
M = RSA.classify.trainMulti_opt( X_shuf(1:floor(r*9/10), :) , Y_shuf(1:floor(r*9/10)), ...
    'classifier', 'SVM', 'PCA', 0, 'randomSeed', 1);
C = RSA.classify.predict( M, X_shuf(floor(r*9/10)+1:end, :) , Y_shuf(floor(r*9/10)+1:end));

accuracy(1) = C.accuracy;

%% S06 

load 'S06.mat'
RSA = MatClassRSA;
[dim1, dim2, dim3] = size(X);
X = reshape(X, [dim1*dim2, dim3]);
X = X';
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, labels6);
[X_avg,Y_avg] = RSA.preprocess.averageTrials(X_shuf,Y_shuf, 5);
[r c] = size(X_avg);

M = RSA.classify.trainMulti_opt( X_avg(1:floor(r*9/10), :) , Y_avg(1:floor(r*9/10)), ...
    'classifier', 'SVM', 'PCA', .99);
C = RSA.classify.predict( M, X_avg(floor(r*9/10)+1:end, :) , Y_avg(floor(r*9/10)+1:end));
accuracy(2) = C.accuracy;

%% log results
% functionName = functionName';
% accuracy =  accuracy';
% dataset = dataset';
% shuffle = shuffle';
% classifier = classifier';
% optimization = optimization';
% averageTrials = averageTrials';
% dataSplit = dataSplit';
T = table(functionName, dataset, accuracy, shuffle, classifier, optimization, averageTrials, dataSplit);
logResults(T);