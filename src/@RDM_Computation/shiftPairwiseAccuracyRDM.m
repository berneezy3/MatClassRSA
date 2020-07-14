function xShift = shiftPairwiseAccuracyRDM(xIn, pairScale, absDist, shiftAmount)
% RSA = MatClassRSA;
% xShift = RSA.computeRDM.shiftPairwiseAccuracyRDM(xIn, shiftAmount)
% --------------------------------------------------------------------
% This function subtracts 0.5 (or some other amount) from  the accuracies 
%   stored in a matrix of pairwise classification accuracies so that
%   the pairwise classification accuracies are easier to interpret as
%   distances (i.e., a classification accuracy at chance level of 0.5
%   implies a distance of zero).
%
% REQUIRED INPUTS
%
% xIn -- A matrix of pairwise classification accuracies (typically square).
%   Values are assumed to range from 0 to 1, but the function can also
%   accommodate inputs whose values range from 0 to 100
%
% OPTIONAL INPUTS
%
% pairScale -- '1' (default), '100'
%   Specification of whether the input matrix is on a 0-to-1 scale, or a
%   0-to-100 scale. If input is missing or empty, will be set to '1'.
%
% absDist -- 'false' (default), 'true'
%   Boolean specification of whether to return the absolute values of the
%   distances (i.e., a classification rate less than chance level would be
%   output as a positive value if this is true). If input is missing or 
%   empty, will be set to 'false'.
%
% shiftAmount -- numeric (default 0.5)
%   Amount to subtract from all matrix elements. If input is missing or
%   empty, will be set to 0.5, which is the chance level for pairwise
%   classification.
%
% OUTPUTS
%
% xShift -- A matrix the same size as xIn, with the shift amount subtracted
%   out. Values along the diagonal will be output as NaNs if any diagonal
%   values in the input were NaN; and otherwise will be output as zeros.