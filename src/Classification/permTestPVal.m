function p = permTestPVal(value, permVector, direction)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% p = permTestPVal(value, permVector, [direction])
% -------------------------------------------------
% Blair - April 17, 2017
% This function takes in the value of interest, a vector of other values
% (presumably from a permutation test), and computes the percentile value
% of the found value among the permutation test values.
% From: https://www.mathworks.com/matlabcentral/answers/182131-percentile-of-a-value-based-on-array-of-data
%
% Inputs:
% - value: The computed value from intact data
% - permVector: The vector of computed values from permutation tests
% - direction (optional): The direction in which the value is compared.
%   Enter -1 if the computed value is compared to the lower tail of the
%   perm test distribution; enter 1 if to be compared to the upper tail of
%   the perm test distribution. Default: Upper.

if ~exist('direction')
    disp('No direction specified. Doing (default) upper tail calculation.')
    direction = 1;
elseif direction < 0
    disp('Doing lower tail calculation.')
    direction = -1;
elseif direction > 0
    disp('Doing upper tail calculation.')
    direction = 1;
elseif direction == 0
    error('Please specify lower or upper tail calculation, or omit this argument to default to upper.')
end

switch direction
    case 1
        n_out = sum(permVector > value);   
    case -1
        n_out = sum(permVector < value);
end
nequal = sum(permVector == value);
p = (n_out + 0.5*nequal) / length(permVector);
