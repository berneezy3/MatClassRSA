function xShift = shiftPairwiseAccuracyRDM(xIn, varargin)
% RSA = MatClassRSA;
% xShift = RSA.RDM_Computation.shiftPairwiseAccuracyRDM(xIn, pairScale)
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
%
% OUTPUTS
%
% xShift -- A matrix the same size as xIn, with the shift amount subtracted
%   out. Values along the diagonal will be output as NaNs if any diagonal
%   values in the input were NaN; and otherwise will be output as zeros.

ip = inputparser;

addRequired(ip, 'xIn', @isnumeric)
addParameter(ip, 'pairScale', 1, @(x) assert(isnumeric(x), ...
    'pairScale must be a numeric value of 1 or 100'));

parse(ip, xIn, varargin{:})

if any(xIn > 1) || pairScale == 100
    xIn = xIn/100;
end

xShift = xIn - 0.5;
