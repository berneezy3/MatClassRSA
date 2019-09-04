% testComputePearsonRDM.m
% ----------------------------
% Blair - Sep 3, 2019

clear all; close all; clc
load S06.mat

%% Input single electrode, all time, 72 class, no NN

thisX = squeeze(X(96,:,:)); % 40 x 5184
thisD = computePearsonRDM(thisX, labels72, [], 1);
thisMeanD = mean(thisD, 3);
thisRDM = computeClassificationRDM(thisMeanD, 'p', 'rankdistances', 'percentrank');
close all
figure()
imagesc(thisRDM); colorbar
title('Pearson electrode 96, all time, 72-class, no NN')

%% Input single electrode, all time, 72 class, with NN

[X_nn, ~] = noiseNormalization(X, labels72);

clear this*
thisX = squeeze(X_nn(96,:,:)); % 40 x 5184
thisD = computePearsonRDM(thisX, labels72, [], 1);
thisMeanD = mean(thisD, 3);
thisRDM = computeClassificationRDM(thisMeanD, 'p', 'rankdistances', 'percentrank');
figure()
imagesc(thisRDM); colorbar
title('Pearson electrode 96, all time, 72-class, with NN')

%% Input single time, all electrode, 72 class, with NN

[X_nn, ~] = noiseNormalization(X, labels72);

clear this*
thisX = squeeze(X_nn(:,19,:)); % 40 x 5184
thisD = computePearsonRDM(thisX, labels72, [], 1);
thisMeanD = mean(thisD, 3);
thisRDM = computeClassificationRDM(thisMeanD, 'p', 'rankdistances', 'percentrank');
figure()
imagesc(thisRDM); colorbar
title('Pearson all electrode, time 19, 72-class, with NN')

%% Input single electrode, all time, 6 class, with NN

[X_nn, ~] = noiseNormalization(X, labels6);

clear this*
thisX = squeeze(X_nn(96,:,:)); % 40 x 5184
thisD = computePearsonRDM(thisX, labels6, [], 1);
thisMeanD = mean(thisD, 3);
thisRDM = computeClassificationRDM(thisMeanD, 'p', 'rankdistances', 'percentrank');
figure()
imagesc(thisRDM); colorbar
title('Pearson electrode 96, all time, 6-class, with NN')

%% Fail: Input full 3D matrix
close all; clc
d = computePearsonRDM(X, labels6)

%% Fail: Input transposed 2D matrix
X2d = squeeze(X(96,:,:))';
d = computePearsonRDM(X2d, labels6)