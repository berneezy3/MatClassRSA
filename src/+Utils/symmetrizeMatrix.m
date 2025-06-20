function xOut = symmetrizeMatrix(xIn, symmType)
%-------------------------------------------------------------------
% xOut = symmetrizeMatrix(xIn, symmType)
% --------------------------------------------------------
%
% This function symmetrizes a matrix by operating on the matrix and its
% transpose.
% Inputs:
% - xIn: The square confusion matrix, possibly normlized
% - symmType:
%   - Arithmetic ('arithmetic', 'a', 'mean')
%   - Geometric ('geometric', 'geom', 'geo', 'g')
%   - Harmonic ('harmonic', 'harm', 'h')
%   - None ('none', 'n')
% Output: Symmetrized matrix
%
% There is no default symmetrization approach, as symmetrization type is
% assumed to be decided prior to calling this function. If none of the
% above symmType options are specified, the function returns an error.
% Currently if the input matrix contains zeros on the diagonal and symmType
% 'harmonic' is selected, a warning will be returned.

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

symmType = lower(symmType);

switch symmType
    case{'arithmetic', 'a', 'mean'}
        disp('Symmetrize: arithmetic')
        xOut = (xIn + xIn') / 2;
    case{'geometric', 'geom', 'geo', 'g'}
        disp('Symmetrize: geometric')
        xOut = sqrt(xIn .* xIn');
    case{'harmonic', 'harm', 'h'}
        disp('Symmetrize: harmonic')
        if ismember(0, diag(xIn))
            warning('Zero values on diagonal of input matrix are now NaN.')
        end
        xOut = 2 * xIn .* xIn' ./ (xIn + xIn');
    case{'none', 'n'}
        disp('Symmetrize: none')
        xOut = xIn;
    otherwise
        error('Symmetrize type not recognized.')
end