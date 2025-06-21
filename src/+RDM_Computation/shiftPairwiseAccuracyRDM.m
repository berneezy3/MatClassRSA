function [xShift] = shiftPairwiseAccuracyRDM(xIn, varargin)
%----------------------------------------------------------------------------------
% [xShift] = RDM_Computation.shiftPairwiseAccuracyRDM(xIn, pairScale)
% -----------------------------------------------------------------------------
%
% This function subtracts 0.5 from the accuracies stored in a matrix of 
%   pairwise classification accuracies so that the pairwise classification 
%   accuracies are easier to interpret as distances (i.e., a classification 
%   accuracy at chance level of 0.5 implies a distance of zero).
%
% REQUIRED INPUTS:
%   xIn -- A matrix of pairwise classification accuracies (typically square).
%       Values are assumed to range from 0 to 1, but the function can also
%       accommodate inputs whose values range from 0 to 100
%
% OPTIONAL INPUTS:
%   pairScale -- 1 (default), 100
%       Specification of whether the input matrix is on a 0-to-1 scale, or a
%       0-to-100 scale. If input is missing or empty, will be set to 1.
%       However, if any value of the input matrix xIn is found to be
%       greater than 1, pairScale will then be set to 100. 
%
% OUTPUTS:
%   xShift -- A matrix the same size as xIn, with shift amount 0.5 subtracted
%       out. Any NaNs along the diagonal of the input matrix will be output 
%       as NaN; otherwise, values on the diagnoal of the output will be
%       zeros. Regardless of the pairScale of the input, the output matrix
%       will range from -0.5 to 0.5 (i.e., pairScale 100 matrices will have
%       been divided by 100 prior to subtracting 0.5 from all values). 
%
% MatClassRSA dependencies: None

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ip = inputParser;

addRequired(ip, 'xIn', @isnumeric)
addParameter(ip, 'pairScale', 1, @(x) assert(isnumeric(x), ...
    'pairScale must be a numeric value of 1 or 100'));

parse(ip, xIn, varargin{:})

if any(xIn(:) > 1) || ip.Results.pairScale == 100
    xIn = xIn/100;
end

xShift = xIn - 0.5;
xShift = xShift - diag(diag(xShift));
