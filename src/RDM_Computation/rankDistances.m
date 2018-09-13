function xOut = rankDistances(xIn, rankType)
%-------------------------------------------------------------------
% xOut = rankDistances(xIn, rankType)
% --------------------------------------------------------
% Blair - February 22, 2017
%
% This function ranks distances in a symmetric distance matrix.
%
% Inputs:
% - xIn: The square distance matrix. Note that this function operates over
%   only the lower triangle of the matrix, so any symmetrization steps
%   should already have been performed. 
% - rankType
%   - Rank ('rank', 'r'): This procedure ranks the elements of the lower
%   triangle, adjusting for ties (uses tiedrank), and then copies those
%   elements to the upper triangle to produce a symmetric distance matrix.
%   - Percent rank ('percentrank', 'p'): This procedure computes percentile
%   ranks by first computing the ranks of the elements of the lower
%   triangle, adjusting for ties, and then dividing the output by the
%   number of elements in the lower triangle. Note that by operating on the
%   lower triangle only, the number of elements is the number of unique
%   pairs across the set of classes.
%   - None ('none', 'n'): No ranking is performed.
%
% There is no default rank type, as rank type is assumed to be decided
% prior to calling this function. If none of the above rankType options
% are specified, the function returns an error.
%
% Output:
% - xOut: The ranked matrix (same size as the input, and symmetric whether
%   or not the input matrix was symmetric, unless no ranking was 
%   performed).

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

rankType = lower(rankType);

switch rankType
    case {'none', 'n'}
        disp('Rank distance: none')
        xOut = xIn;
    case {'rank', 'r', 'percentrank', 'p'}
        if sum(unique(xIn - xIn') == 0) ~= numel(unique(xIn - xIn'))
            warning('Input matrix is not symmetric. Ranking values on lower diagonal only.')
        end
        trilM = tril(ones(size(xIn)), -1);
        distV = xIn(trilM == 1);
        trV = tiedrank(distV);
        switch rankType
            case{'rank', 'r'}
                disp('Rank distance: rank ')
                theRanks = trV;
            case{'percentrank', 'p'}
                disp('Rank distance: percentrank')
                theRanks = trV / length(trV);
        end
        outM = zeros(size(xIn));
        outM(trilM == 1) = theRanks;
        xOut = outM + outM';
    otherwise
        error('Distance type not recognized.')
        
end