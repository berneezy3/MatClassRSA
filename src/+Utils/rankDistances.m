function xOut = rankDistances(xIn, rankType)
%-------------------------------------------------------------------
% xOut = rankDistances(xIn, rankType)
% --------------------------------------------------------
%
% This function ranks distances in a symmetric distance matrix.
%
% Inputs:
% - xIn: The square confusion matrix, possibly normlized
% - rankType
%   - Rank ('rank', 'r')
%   - Percent rank ('percentrank', 'p')
%   - None ('none', 'n')
%
% Outputs:
% - xOut: a symmetric matrix of ranks
%
% Ranking is based on the values in the lower triangle (under the diagonal)
% of the matrix only. If a non-symmetric matrix is input, the function
% issues a warning and proceeds to compute ranks only on the lower-triangle
% values, returning a symmetric matrix.
%
% There is no default rank type, as rank type is assumed to be decided
% prior to calling this function. If none of the above rankType options
% are specified, the function returns an error.

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

rankType = lower(rankType);

switch rankType
    case {'none', 'n'}
        disp('Rank type: none')
        xOut = xIn;
    case {'rank', 'r', 'percentrank', 'p'}
        if sum(unique(xIn - xIn') == 0) ~= numel(unique(xIn - xIn'))
            warning('Input matrix is not symmetric. Returning symmetric matrix based on lower-triangle ranks only.')
        end
        trilM = tril(ones(size(xIn)), -1);
        distV = xIn(trilM == 1);
        trV = tiedrank(distV);
        switch rankType
            case{'rank', 'r'}
                disp('Rank type: rank ')
                theRanks = trV;
            case{'percentrank', 'p'}
                disp('Rank type: percentrank')
                theRanks = trV / length(trV) * 100;
        end
        outM = zeros(size(xIn));
        outM(trilM == 1) = theRanks;
        xOut = outM + outM';
    otherwise
        error('Distance type not recognized.')
        
end