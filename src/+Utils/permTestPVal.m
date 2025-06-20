function p = permTestPVal(value, permVector, direction)
%-------------------------------------------------------------------
% p = permTestPVal(value, permVector, [direction])
% -------------------------------------------------
% 
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
