load 'S06.mat'
RSA = MatClassRSA;
[dim1, dim2, dim3] = size(X);
X = reshape(X, [dim1*dim2, dim3]);
X = X';
[X_shuf,Y_shuf] = RSA.preprocess.shuffleData(X, labels6);
[X_avg,Y_avg] = RSA.preprocess.averageTrials(X_shuf,Y_shuf, 5);
[r c] = size(X_avg);
C = RSA.classify.crossValidateMulti_opt(X_avg, Y_avg, 'PCA', .99, ...
    'classifier', 'LDA', 'gammaSpace', logspace(-10,10,10));
