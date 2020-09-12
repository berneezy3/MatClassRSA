%%
%
%
%
%
%

% S06.mat should be in UnitTests directory
load('../S06.mat');

[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

%%
% UNBALANCED, SCALED, WEIGHED

[r c] = size(X_2D);

gamma = 1/c;

d = pdist(X_2D, 'squaredeuclidean');
d = squareform(d);

D = gamma * d;

K = exp( (- gamma) * d );


%%

% indx = [(labels6 == 3) + (labels6 == 4)];
indx = find(ismember(labels6, [3 4]));
subsetX = X_2D(indx, :) ;

K(indx, indx);

imagesc(K(indx, indx));
colorbar

title('K for trials of Classes 3 and 4')

%%

fold = 4000;

min_val = -1;
max_val = 1;

[X_2D_Scaled, shift1, shift2, scaleFactor] = scaleDataInRange(X_2D, [min_val, max_val]);

trainX = X_2D(1:fold, :);
testX = X_2D(fold + 1:end, :);

trainXScaled = X_2D_Scaled(1:fold, :);
testXScaled = X_2D_Scaled(fold + 1:end, :);

trainY = labels6(1:fold);
testY = labels6(fold + 1:end);

mdl = classifyTrain(trainX, trainY, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 0);

P = classifyPredict(mdl, testX, testY);

figure
plotMatrix(P.CM)
title('Unbalanced classes, scaled, weighed')
colorbar
ylabel('predicted class');
xlabel('actual class');

%%

P2 = classifyPredict(mdl, trainX, trainY);

figure
plotMatrix(P2.CM)
title('Train Data: Unbalanced classes, scaled, weighed')
colorbar
ylabel('predicted class');
xlabel('actual class');


%%

C_noCenterScale = classifyCrossValidate(X_2D, labels6, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 1, 'C', 1000000000, 'center', 0);
figure
plotMatrix(C_noCenterScale.CM)
title('W/o Data Centering')
colorbar
%%

C = classifyCrossValidate(X_2D, labels6, 'PCA', .99, 'classifier', 'SVM', 'PCAinFold', 1, 'C', 1000000000);
figure
plotMatrix(C.CM)
title('With Data Centering')
colorbar

%%

C_plus100nocenter = classifyCrossValidate(X_2D + 100, labels6, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 1, 'center', 0);
figure
plotMatrix(C_plus100nocenter.CM)
title('S06 + 100 w/o data centering')
colorbar

%%

C_plus100center = classifyCrossValidate(X_2D + 100, labels6, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 1, 'center', 1);
figure
plotMatrix(C_plus100center.CM)
title('S06 + 100 w/ data centering')
colorbar