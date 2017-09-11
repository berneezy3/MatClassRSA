function xOut = convertSimToDist(xIn, distType, distPower)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
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
%   - None ('none', 'n')
% - distPower:
%   - Distance power (used in power and logarithmic computations)
%
% There is no default distance computation, as distance type is
% assumed to be decided prior to calling this function. If none of the
% above distType options are specified, the function returns an error.

distType = lower(distType);

switch distType
    case {'linear', 'lin'}
        disp('Distance: linear')
        if nargin > 2 & distPower ~= 1
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
    case {'none', 'n'}
        disp('Distance: none')
        xOut = xIn;
    otherwise
        error('Distance type not recognized.')
end