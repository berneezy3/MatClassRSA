load '../losorelli_500sweep_epoched.mat'


%% test CV once to get a good idea of runtime for single iteration

C = classifyCrossValidate(X, Y, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 0, 'gamma', 'default','C', .000000001);
plotMatrix(C.CM)
colorbar

%%

Cs = logspace((-5), 5, 10);
gammas = logspace((-5), 5, 10);

accGrid = zeros(10, 10);
cGrid = cell(10, 10);

[r c] = size(accGrid)

for i = 1:r
    for j = 1:c
        tempC = classifyCrossValidate(X, Y, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 0, 'C', Cs(i), 'gamma', gammas(j));
        accGrid(i,j) = tempC.accuracy;
        cGrid{i,j} = tempC;
    end
end
%%

c_noOpt = classifyCrossValidate(X, Y, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 0);

%%

c_LDA = classifyCrossValidate(X, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0);

%%

c_RF = classifyCrossValidate(X, Y, 'PCA', .99, 'classifier', 'RF', 'PCAinFold', 0);
