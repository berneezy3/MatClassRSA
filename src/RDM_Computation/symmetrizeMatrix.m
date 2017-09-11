function xOut = symmetrizeMatrix(xIn, symmType)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
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