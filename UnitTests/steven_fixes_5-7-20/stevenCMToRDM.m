function [RDM, params] = stevenCMToRDM(CM)
% [RDM, params] = stevenCMToRDM(CM)
% -------------------------------------------
% Blair - July 10, 2020
%
% Convert multicategory CM to RDM by hand. Will swap with MatClassRSA
% function once it is completed. 
% - Normalization: Sum (not diagonal bc off-diagonal elements may be
%   largest in the row). --> estimate of conditional probability.
% - Symmetrization: Arithmetic (not geometric, since poorly behaved CMs may
%   have notable asymmetries).
% - Distance: Linear (this performs as intended now that all values after
%   symmetrization are between 0 and 1 (no negative distances)).
%
% Input:
% - CM: Square multicategory confusion matrix.
%
% Ouputs:
% - RDM: The RDM
% - params: What was done.

% Normalize the CM
rowSumMatrix = repmat(sum(CM, 2), 1, size(CM, 2));
CM_norm = CM ./ rowSumMatrix

% Symmetrize the CM
CM_sym = (CM_norm + CM_norm .') / 2

% Compute distance
CM_dist = 1 - CM_sym

% Zero out the diagonal
RDM = CM_dist - diag(diag(CM_dist))

params.normalize = 'sum';
params.symmetrize = 'arithmetic';
params.distance = 'linear';
params.distpower = 1;
params.rankdistance = 'none';
params.zerodiag = true;