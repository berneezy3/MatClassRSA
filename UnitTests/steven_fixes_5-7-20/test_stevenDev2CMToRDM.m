% test_stevenDev2CMToRDM.m
% -----------------
% Blair - July 10, 2020

clear all; close all; clc

MCR = MatClassRSA;

%% Load the 'good' CM - largest values in each row are on diagonal
load losorelli_04_classifyTimeDomainCV_500s_intact_20190326_2004.mat
CM_good = C.CM;
clear C
% CM_good =
% 
%     36    24     0     2     2     1
%     24    33     2     1     3     2
%      0     1    48    16     0     0
%      1     2    10    49     3     0
%      2     1     0     5    57     0
%      0     4     0     0     2    59

%%% Normalize using diagonal values
matrixOfDiagonal = repmat(diag(CM_good), 1, size(CM_good, 2));
CM_good_norm = CM_good ./ matrixOfDiagonal
% CM_good_norm =
% 
%     1.0000    0.6667         0    0.0556    0.0556    0.0278
%     0.7273    1.0000    0.0606    0.0303    0.0909    0.0606
%          0    0.0208    1.0000    0.3333         0         0
%     0.0204    0.0408    0.2041    1.0000    0.0612         0
%     0.0351    0.0175         0    0.0877    1.0000         0
%          0    0.0678         0         0    0.0339    1.0000

%%% Symmetrize using the geometric mean
CM_good_sym_geo = sqrt(CM_good_norm .* CM_good_norm .')
test = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good_norm, ...
    'normalize', 'none', 'symmetrize', 'geometric', 'distance', 'none')
isequal(CM_good_sym_geo, test)

%%% Symmetrize using the arithmetic mean
CM_good_sym_ari = (CM_good_norm + CM_good_norm .') / 2
test2 = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good_norm, ...
    'normalize', 'none', 'symmetrize', 'arithmetic', 'distance', 'none')
isequal(CM_good_sym_ari, test2)

%%% Sim to dist
CM_good_dist_geo = 1 - CM_good_sym_geo
test3 = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good_sym_geo,...
    'normalize', 'none', 'symmetrize', 'none', 'distance', 'linear')
isequal(CM_good_dist_geo, test3)

CM_good_dist_ari = 1 - CM_good_sym_ari
test4 = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good_sym_ari, ...
    'normalize', 'none', 'symmetrize', 'none', 'distance', 'linear')

%%% Plots
MCR.Visualization.plotDendrogram(test3); ylim([0 1])
MCR.Visualization.plotDendrogram(test4); ylim([0 1])

%% Now do row sum normalization

% close all
test5 = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good, ...
    'normalize', 'sum', 'symmetrize', 'geometric', 'distance', 'linear')
test6 = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_good, ...
    'normalize', 'sum', 'symmetrize', 'arithmetic', 'distance', 'linear')

%%% Plots
MCR.Visualization.plotDendrogram(test5); ylim([0 1])
MCR.Visualization.plotDendrogram(test6); ylim([0 1])

%%

close all
% Load the 'bad' CM - rows have largest values off the diagonal
load losorelli_08_classifyFreqDomain_mag_intact_20190326_2009.mat
CM_bad = C.CM;
clear C
% CM_bad =
% 
%     30    25     0     4     3     3
%     37    13     1     5     4     5
%      0     1    46    16     1     1
%      1     2     9    44     4     5
%      0     1     0     7    47    10
%      0     5     1     4     8    47

bad_diag_geom = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_bad, ...
    'normalize', 'diagonal', 'symmetrize', 'geometric', 'distance', 'linear')
MCR.Visualization.plotDendrogram(bad_diag_geom); ylim([-1 1])
title('bad diag geom')

bad_diag_ari = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_bad, ...
    'normalize', 'diagonal', 'symmetrize', 'arithmetic', 'distance', 'linear')
MCR.Visualization.plotDendrogram(bad_diag_ari); ylim([-1 1])
title('bad diag ari')

bad_sum_geom = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_bad, ...
    'normalize', 'sum', 'symmetrize', 'geometric', 'distance', 'linear')
MCR.Visualization.plotDendrogram(bad_sum_geom); ylim([-1 1])
title('bad sum geom')

bad_sum_ari = MCR.RDM_Computation.convertConfusionMatrixToRDM(CM_bad, ...
    'normalize', 'sum', 'symmetrize', 'geometric', 'distance', 'linear')
MCR.Visualization.plotDendrogram(bad_sum_ari); ylim([-1 1])
title('bad sum ari')
