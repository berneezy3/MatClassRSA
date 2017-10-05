function p = permTestPVal(value, permVector, direction)
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
