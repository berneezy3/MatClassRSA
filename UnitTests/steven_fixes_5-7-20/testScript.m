load '../losorelli_500sweep_epoched.mat'

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, Y);
[X_avg,Y_avg] =  RSA.preprocess.averageTrials(X_shuf, Y_shuf, 5);


%% test CV once to get a good idea of runtime for single iteration

noPCA_acc = zeros(1,5);
onePCA_acc = zeros(1,5);
tenPCA_acc = zeros(1,5);


for i = 1:5

    [X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, Y);
    
    noC = RSA.classify.crossValidateMulti(X_shuf, Y_shuf, 'PCA', -1, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true, 'scale', true);
    oneC = RSA.classify.crossValidateMulti(X_shuf, Y_shuf, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true, 'scale', true);
    tenC = RSA.classify.crossValidateMulti(X_shuf, Y_shuf, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true, 'scale', true);

    noPCA_acc = zeros(1,5);
    onePCA_acc = zeros(1,5);
    tenPCA_acc = zeros(1,5);
%     plotMatrix(C.CM);
%     colorbar;
%     
    
end


%% test CV once to get a good idea of runtime for single iteration


C = RSA.classify.crossValidateMulti(X_shuf, Y_shuf, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 1, 'center', true, 'scale', true);
plotMatrix(C.CM);
colorbar;


%% test CV once to get a good idea of runtime for single iteration

M = RSA.classify.trainMulti( X_avg(1:50,:), Y_avg(1:50), 'classifier', 'LDA', ...
    'PCA', .99, 'PCAinFold', 0, 'center', true, 'scale', true);
C = RSA.classify.predict( M, X_avg(51:end,:),  Y_avg(51:end));

%%


nParticipants = 13;
X = X_shuf;
Y = Y_shuf;

c = struct('CM', NaN, 'accuracy', NaN, 'modelsConcat', NaN, 'predY', NaN, 'classifierInfo', NaN);
c = repmat(c, nParticipants);


for i = 1:nParticipants
    
    thisTrainX = X_shuf;  thisTrainY = Y_shuf;
    thisTrainX(P == i, :) = [];
    thisTrainY(P == i) = [];
    
    thisTestX = X(P == i, :);
    thisTestY = Y(P==i);
    
    M = RSA.classify.trainMulti( thisTestX, thisTestY, 'classifier', 'LDA', ...
    'PCA', .99, 'PCAinFold', 0, 'center', true, 'scale', true);
    c(i) = RSA.classify.predict( M, thisTestX, thisTestY);
    
end
