function xOut = rankDistances(xIn, rankType)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% xOut = rankDistances(xIn, rankType)
% --------------------------------------------------------
% Blair - February 22, 2017
%
% This function ranks distances in a symmetric distance matrix.
% Inputs:
% - xIn: The square confusion matrix, possibly normlized
% - rankType
%   - Rank ('rank', 'r')
%   - Percent rank ('percentrank', 'p')
%   - None ('none', 'n')
%
% There is no default rank type, as rank type is assumed to be decided 
% prior to calling this function. If none of the above rankType options 
% are specified, the function returns an error.

rankType = lower(rankType);

if sum(unique(xIn - xIn') == 0) ~= numel(unique(xIn - xIn'))
    warning('Input matrix is not symmetric. Ranking values on lower diagonal only.')
end

switch rankType
    case {'none', 'n'}
        disp('Rank distance: none')
        xOut = xIn;
    case {'rank', 'r', 'percentrank', 'p'}
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