function xOut = convertSimToDist(xIn, distType, distPower)
%-------------------------------------------------------------------
% xOut = convertSimToDist(xIn, distType, distPower)
% --------------------------------------------------------
%
% This function converts a proximity matrix to distances.
% Inputs:
%   - xIn: The square confusion matrix, possibly normlized
%   - distType:
%       - Linear ('linear', 'lin)
%       - Power ('power', 'p')
%       - Logarithmic ('logarithmic', 'log')
%       - Pairwise ('pairwise', 'pw')
%       - None ('none', 'n')
%   - distPower:
%       - Distance power (used in power and logarithmic computations)
%
% Outputs
%   xOut: distance matrix
%
% There is no default distance computation, as distance type is
% assumed to be decided prior to calling this function. If none of the
% above distType options are specified, the function returns an error.

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