
% Illustrative_5_compareRDMs_withSave.m
% -----------------------------------------
% Illustrative example code visualizing various RDM constructs within the toolkit
% Modified to save all figures using filenames matching LaTeX figure references.

% Setup Workspace
clear all; close all; clc
rng(4);

% Load Data
load('S06.mat');

rgb6 = {[0.1216 0.4667 0.7059], [1.0000 0.4980 0.0549], ...
        [0.1725 0.6275 0.1725], [0.8392 0.1529 0.1569], ...
        [0.5804 0.4039 0.7412], [0.7373 0.7412 0.1333]};
catLabels = {'HB','HF','AB','AF','FV','IO'};

% Preprocess
[xShuf, yShuf] = Preprocessing.shuffleData(X, labels6, 'rngType', 4);
xNorm = Preprocessing.noiseNormalization(xShuf, yShuf);
[xAvg, yAvg] = Preprocessing.averageTrials(xNorm, yShuf, 20, 'handleRemainder','newGroup');

% Multi-class vs Pairwise RDM
MMC = Classification.crossValidateMulti(xAvg, yAvg, 'classifier','LDA','PCA',0.99);
MPW = Classification.crossValidatePairs(xAvg, yAvg, 'classifier','LDA','PCA',0.99);
[RDMmc, ~] = RDM_Computation.computeCMRDM(MMC.CM);
RDMpm = RDM_Computation.shiftPairwiseAccuracyRDM(MPW.AM);

figure;
set(gcf, 'Position', [150,300,1200,1200]);
subplot(3,2,1); Visualization.plotMatrix(RDMmc,'axisLabels',catLabels,'axisColors',rgb6);
title('Multi-class Classification RDM'); set(gca,'fontsize',16)
subplot(3,2,2); Visualization.plotMatrix(RDMpm,'axisLabels',catLabels,'axisColors',rgb6);
title('Pairwise Classification RDM'); set(gca,'fontsize',16)
subplot(3,2,3); Visualization.plotMDS(RDMmc,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Multi-class Classification MDS'); set(gca,'fontsize',16)
subplot(3,2,4); Visualization.plotMDS(RDMpm,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Pairwise Classification MDS'); set(gca,'fontsize',16)
subplot(3,2,5); Visualization.plotDendrogram(RDMmc,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Multi-class Classification Dendrogram'); set(gca,'fontsize',16)
subplot(3,2,6); Visualization.plotDendrogram(RDMpm,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Pairwise Classification Dendrogram'); set(gca,'fontsize',16)
sgtitle('Multi-class vs Pairwise Classification on Same Dataset');
saveas(gcf, 'Figs/fig24_pairwise_vs_multiclass_rdms.jpg');

% Pearson vs Euclidean at Electrode
singleElectrodeX = squeeze(X(96,:,:));
PearsonRDM = RDM_Computation.computePearsonRDM(singleElectrodeX, labels6);
EuclidRDM = RDM_Computation.computeEuclideanRDM(singleElectrodeX, labels6);
figure;
subplot(2,2,1); Visualization.plotMatrix(PearsonRDM.RDM,'axisLabels',catLabels,'axisColors',rgb6);
title('Pearson RDM'); subplot(2,2,2); Visualization.plotMatrix(EuclidRDM.RDM,'axisLabels',catLabels,'axisColors',rgb6);
title('Euclidean RDM'); subplot(2,2,3); Visualization.plotMST(PearsonRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Pearson MST'); subplot(2,2,4); Visualization.plotMST(EuclidRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Euclidean MST'); sgtitle('Single Electrode 96: Pearson and Euclidean RDMs');
saveas(gcf, 'Figs/fig25_pearson_vs_euclidean_electrode.jpg');

% Pearson vs Euclidean at Timepoint
singleTimePointX = squeeze(X(:,17,:));
PearsonRDM = RDM_Computation.computePearsonRDM(singleTimePointX, labels6);
EuclidRDM = RDM_Computation.computeEuclideanRDM(singleTimePointX, labels6);
figure;
subplot(3,2,1); Visualization.plotMatrix(PearsonRDM.RDM,'axisLabels',catLabels,'axisColors',rgb6);
title('Pearson RDM'); subplot(3,2,2); Visualization.plotMatrix(EuclidRDM.RDM,'axisLabels',catLabels,'axisColors',rgb6);
title('Euclidean RDM'); subplot(3,2,3); Visualization.plotMDS(PearsonRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Pearson MDS'); subplot(3,2,4); Visualization.plotMDS(EuclidRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Euclidean MDS'); subplot(3,2,5); Visualization.plotMST(PearsonRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Pearson MST'); subplot(3,2,6); Visualization.plotMST(EuclidRDM.RDM,'nodeLabels',catLabels,'nodeColors',rgb6);
title('Euclidean MST'); sgtitle('Timepoint 144 ms: Pearson vs Euclidean RDM');
saveas(gcf, 'Figs/fig26_pearson_vs_euclidean_timepoint.jpg');
