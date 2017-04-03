function xOut = normalizeMatrix(xIn, normType)
% xOut = normalizeMatrix(xIn, normType)
% --------------------------------------------------------
% Blair - February 22, 2017
%
% This function normalizes a matrix by dividing each row by either its sum,
% or the value on the diagonal.
% Inputs: 
% - xIn: The square confusion matrix
% - normType: 
%   - Diagonal ('diagonal', 'diag', 'd')
%   - Sum ('sum', 's')
%   - None ('none', 'n')
%
% There is no default normalization approach, as normalization type is
% assumed to be decided prior to calling this function. If none of the
% above normType options are specified, the function returns an error. 
% Currently if the divisor is zero, the function returns an error and it 
% is up to the user to adjust the input matrix.

normType = lower(normType);

switch normType
    case {'diagonal', 'diag', 'd'}
        disp('Normalize: diagonal')
        if ismember(0, diag(xIn))
            error('Cannot divide by zero on the diagonal.')
        else
            xOut = xIn ./ repmat(diag(xIn), 1, size(xIn, 2));
        end
    case {'sum', 's'}
        disp('Normalize: sum')
        if ismember(0, sum(xIn, 2))
            error('Cannot divide by zero row sum.')
        else
            xOut = xIn ./ repmat(sum(xIn, 2), 1, size(xIn, 2));
        end
    case {'none', 'n'}
        disp('Normalize: none')
        xOut = xIn;
    otherwise
        error('Normalize type not recognized.')
end