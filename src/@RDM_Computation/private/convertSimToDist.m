function xOut = convertSimToDist(xIn, distType, distPower)
%-------------------------------------------------------------------
% xOut = computeDistances(xIn, distType)
% --------------------------------------------------------
% Blair - February 22, 2017
%
% This function converts a proximity matrix to distances.
% Inputs:
% - xIn: The square confusion matrix, possibly normlized
% - distType:
%   - Linear ('linear', 'lin)
%   - Power ('power', 'p')
%   - Logarithmic ('logarithmic', 'log')
%   - Pairwise ('pairwise', 'pw')
%   - None ('none', 'n')
% - distPower:
%   - Distance power (used in power and logarithmic computations)
%
% Outputs
%   xOut: distance matrix
%
% There is no default distance computation, as distance type is
% assumed to be decided prior to calling this function. If none of the
% above distType options are specified, the function returns an error.

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

distType = lower(distType);
if exist('distPower')
    if distPower <= 0 || floor(distPower) ~= distPower
        error('Input ''distPower'' must be a positive integer.');
    end
end

switch distType
    case {'linear', 'lin'}
        disp('Distance: linear')
        if nargin > 2 && distPower ~= 1
           warning('Ignoring non-unity distance power for Linear computation.') 
        end
        xOut = 1 - xIn;
    case {'power', 'p'}
        disp('Distance: power')
        if nargin < 3
            error('Third argument (distance power) needed for Power computation.')
        end
        disp(['Distance power: ' num2str(distPower)])
        xOut = 1 - xIn .^ distPower;
    case {'logarithmic', 'log'}
        disp('Distance: logarithmic')
        if nargin < 3
            error('Third argument (distance power) needed for Logarithmic computation.')
        end
        disp(['Distance power: ' num2str(distPower)])
        xOut = 1 - log2(distPower * xIn + 1) ./ log2(distPower + 1);
    case {'pairwise', 'pw'}
        disp('Distance: pairwise')
        xOut = 0.5 - xIn;
    case {'none', 'n'}
        disp('Distance: none')
        xOut = xIn;
    otherwise
        error('Distance type not recognized.')
end