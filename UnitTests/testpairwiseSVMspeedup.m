% October 26th, 2020
% Bernard Wang
% Addressing the following reviewer comment:
%
% "Since libsvm outputs all decision values based on pairwise classification 
% when entering more than two labels, it is not necessary to iterate through 
% all pairs separately. This can lead to a drastic speed improvement for 
% pairwise classification.?
%
% We want to test if splitting the labels into pairs outside of the libsvm
% function actually results in a significant slowdown.  If not, then we
% have evidence that such an optimization may not be necessary, as doing so
% compliates the logic of our code.


clear
load 'losorelli_500sweep_epoched.mat'

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, Y);

gamma_opt = 0.0032;
C_opt =  316.2278
%%



tic
    C_los_fast = RSA.Classification.crossValidatePairs_fast(X_shuf, Y_shuf, 'PCA', 0, ...
        'classifier', 'SVM');
runtime_los_fast = toc

RSA.Visualization.plotMatrix(C_los_fast.AM, 'matrixLabels', 1)
colorbar
title('losorelli\_500sweep\_epoched pairwise SVM diagonal accuracy matrix (fast method)');
xlabel('Class 1');
ylabel('Class 2');
% saveas(gcf, '/Users/berneezy/Documents/research/MatClassRSA\ Updates/11-2/losorelli\_500sweep\_epoched pairwise SVM diagonal accuracy matrix (fast method)');

%%

tic
    C_los_slow = RSA.Classification.crossValidatePairs_slow(X_shuf, Y_shuf, 'PCA', 0, ...
        'classifier', 'SVM');
runtime_los_slow = toc
figure
figure
RSA.Visualization.plotMatrix(C_los_slow.AM, 'matrixLabels', 1)
colorbar
title('losorelli\_500sweep\_epoched pairwise SVM accuracy matrix (slow method)');

%%%%%%%%%%%%%%%%%%%
%% Blair S06 data
%%%%%%%%%%%%%%%%%%%
load 'S06.mat'

RSA = MatClassRSA;
[X_shuf,Y_shuf] = RSA.Preprocessing.shuffleData(X, labels72);
%%
tic
    C_s06_fast = RSA.Classification.crossValidatePairs_fast(X_shuf, Y_shuf, 'PCA', 0, ...
        'classifier', 'SVM');
runtime_s06_fast = toc

RSA.Visualization.plotMatrix(C_s06_fast.AM, 'matrixLabels', 0)
colorbar
title('S06 pairwise SVM diagonal accuracy matrix (fast method)');
xlabel('Class 1');
ylabel('Class 2');
% saveas(gcf, '/Users/berneezy/Documents/research/MatClassRSA\ Updates/11-2/losorelli\_500sweep\_epoched pairwise SVM diagonal accuracy matrix (fast method)');
%%
tic
    C_s06_slow = RSA.Classification.crossValidatePairs_slow(X_shuf, Y_shuf, 'PCA', 0, ...
        'classifier', 'SVM');
runtime_s06_slow = toc
figure
RSA.Visualization.plotMatrix(C_s06_slow.AM, 'matrixLabels', 0)
colorbar
title('S06 pairwise SVM accuracy matrix (slow method)');
xlabel('Class 1');
ylabel('Class 2');