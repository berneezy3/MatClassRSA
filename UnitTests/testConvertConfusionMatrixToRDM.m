% testConvertConfusionMatrixToRDM.m
% --------------------------------------
% Blair - November 13, 2020
%
% Testing various calls to the function to compute RDM, after function has
% been updated with new default normalization (sum) and error/warning
% scenarios.

clear all; close all; clc

MCR = MatClassRSA;


      
%% Confirm defaults with good CM

goodCM = [55 40 5; 
          40 50 10;
          7  8 85]

% Default: Norm = sum, sym = arith, dist = 1-sim
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM)

% By hand
tempRowSum = repmat(sum(goodCM, 2), 1, size(goodCM, 2));
tempNorm = goodCM ./ tempRowSum;
tempSym = (tempNorm + tempNorm.') / 2;
tempDist = 1 - tempSym
assert(isequal(tempOut, tempDist))

%% Confirm sum norm alone with good CM

clear temp*
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM,...
    'normalize', 'sum', 'symmetrize', 'none', 'distance', 'none')
tempRowSum = repmat(sum(goodCM, 2), 1, size(goodCM, 2));
tempNorm = goodCM ./ tempRowSum
assert(isequal(tempOut, tempNorm))

%% Confirm diag norm alone with good CM

clear temp* 
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM, ...
    'normalize', 'diagonal', 'symmetrize', 'none', 'distance', 'none')
tempDiagMatrix = repmat(diag(goodCM), 1, size(goodCM, 2));
tempNorm = goodCM ./ tempDiagMatrix
assert(isequal(tempOut, tempNorm))

%% Confirm no norm with good CM

clear temp*
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM, ...
    'normalize', 'none', 'symmetrize', 'none', 'distance', 'none')
assert(isequal(goodCM, tempOut))

%% Confirm arithmetic symmetrize with good CM (sum norm)

clear temp*
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM, ...
    'normalize', 'sum', 'symmetrize', 'arithmetic', 'distance', 'none')
tempRowSum = repmat(sum(goodCM, 2), 1, size(goodCM, 2));
tempNorm = goodCM ./ tempRowSum;
tempSym = (tempNorm + tempNorm.') / 2
assert(isequal(tempOut, tempSym))

%% Confirm geometric symmetrize with good CM (sum norm)

clear temp*
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(goodCM, ...
    'normalize', 'sum', 'symmetrize', 'geometric', 'distance', 'none')
tempRowSum = repmat(sum(goodCM, 2), 1, size(goodCM, 2));
tempNorm = goodCM ./ tempRowSum;
tempSym = sqrt((tempNorm .* tempNorm.'))
assert(isequal(tempOut, tempSym))


%% Confirm that large off-diagonal will flag warning in diagonal normalization

clear temp*
offDiagCM = [45 55 0;
             42 50 8;
             7  8  85]
 
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(offDiagCM, ...
    'normalize', 'diagonal')
         
%% Confirm that zero row sum will flag warning in row normalization
         
clear temp*
zeroRowCM = [0 0 0;
             0 5 2; 
             1 2 7]
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(zeroRowCM)

% Note that the final output of this main function doesn't have a row of
% zeros, bc of the subsequent steps

%% Confirm that zero diag will flag error in diag normalization
zeroDiagCM = [0 10 0;
              5 5  0;
              1 2  8]
clear temp*
tempOut = MCR.RDM_Computation.convertConfusionMatrixToRDM(zeroDiagCM,...
    'normalize', 'diagonal')