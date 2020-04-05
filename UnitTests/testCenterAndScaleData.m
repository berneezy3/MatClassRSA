% testPlotMatrix.m
% ---------------------
% Blair/Bernard - April 5, 2020
%
% Testing data centering and scaling for PCA


load('./losorelli_500sweep_epoched.mat');

%% Add 100 to Data Matrix, don't center, and classify.  
% We expect the classification to perform poorly in this case.


C_plus100nocenter = classifyCrossValidate(X+100, Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', false);
figure
plotMatrix(C_plus100nocenter.CM)
title(' + 100 w/o data centering')
colorbar

%% Add 100 to Data Matrix, center, and classify.  
% The classification should perform well now

C_plus100center = classifyCrossValidate(X + 100 , Y, 'PCA', .99, 'classifier', 'LDA', 'PCAinFold', 0, 'center', true);
figure
plotMatrix(C_plus100center.CM)
title(' + 100 w/ data centering')
colorbar