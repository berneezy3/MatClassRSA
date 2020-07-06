%  5/18/2020 MatClassRSA test script for code restucture
%  Bernard Wang

load ../S06.mat

% create instance of MatClassRSA class
RSA = MatClassRSA;

%% Preprocessing
% shuffle data
[X, Y] =  RSA.preprocess.shuffleData(X, labels6);
% average trials with a group size of 5
[X, Y] =  RSA.preprocess.averageTrials(X, Y, 5);

%% Classification
% generate confusion matrix via cross validation
C = RSA.classify.crossValidateMulti(X, Y);

%% Convert CM to RDM
RDM = RSA.computeRDM.computeClassificationRDM(C.CM, 'CM');

%% VISUALIZATION
RSA.visualize.plotMatrix(RDM);
%%
RSA.visualize.plotDendrogram(RDM);
%%
RSA.visualize.plotMDS(RDM);
%%
RSA.visualize.plotMST(RDM);


%%  Train model and predict labels separately
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

M = RSA.classify.trainMulti( X_2D(1:floor(dim3/5), :) , Y(1:floor(dim3/5)), 'classifier', 'LDA');
C = RSA.classify.predict( M, X_2D(floor(dim3/5)+1:dim3, :),  Y(floor(dim3/5)+1:dim3));