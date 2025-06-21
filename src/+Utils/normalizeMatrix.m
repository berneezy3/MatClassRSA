function xOut = normalizeMatrix(xIn, normType)
%-------------------------------------------------------------------
% xOut = normalizeMatrix(xIn, normType)
% --------------------------------------------------------
%
% This function normalizes a matrix by dividing each row by either its sum,
% or the value on the diagonal.
% Inputs: 
% - xIn: The square confusion matrix
% - normType: 
%   - Diagonal ('diagonal', 'diag', 'd')
%   - Sum ('sum', 's')
%   - None ('none', 'n')
%   - Subtract 0.5 and then divide by 0.5 ('zeroToOne', 'z')
%
% There is no default normalization approach, as normalization type is
% assumed to be decided prior to calling this function. If none of the
% above normType options are specified, the function returns an error. 
% Currently if the divisor is zero, the function returns an error and it 
% is up to the user to adjust the input matrix.

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

normType = lower(normType);

switch normType
    case {'diagonal', 'diag', 'd'}
        disp('Normalize: diagonal')
        if ismember(0, diag(xIn))
            error('Cannot divide by zero on the diagonal. Suggest using ''sum'' rather than ''diagonal'' for normalization.')
        else
            xOut = xIn ./ repmat(diag(xIn), 1, size(xIn, 2));
        end
    case {'sum', 's'}
        disp('Normalize: sum')
        xOut = xIn ./ repmat(sum(xIn, 2), 1, size(xIn, 2));
        if ismember(0, sum(xIn, 2))
            warning('Input matrix contains at least one zero-sum row. These output rows will be rows of zeros.')
            zeroRows = find(sum(xIn,2) == 0);
            xOut(zeroRows,:) = 0;
        end
    case {'none', 'n'}
        disp('Normalize: none')
        xOut = xIn;
    case {'zeroToOne', 'z'}
        disp('Normalize: zeroToOne')
        xOut = (xIn - 0.5) / 0.5;
    otherwise
        error('Normalize type not recognized.')
end