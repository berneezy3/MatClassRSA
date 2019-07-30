function xOut = symmetrizeMatrix(xIn, symmType)
%-------------------------------------------------------------------
% xOut = symmetrizeMatrix(xIn, symmType)
% --------------------------------------------------------
% Blair - February 22, 2017
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
%
% There is no default symmetrization approach, as symmetrization type is
% assumed to be decided prior to calling this function. If none of the
% above symmType options are specified, the function returns an error.
% Currently if the input matrix contains zeros on the diagonal and symmType
% 'harmonic' is selected, a warning will be returned.

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