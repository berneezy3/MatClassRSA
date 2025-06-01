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

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%

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
