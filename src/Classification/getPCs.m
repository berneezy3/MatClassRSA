function [y, V, nPC] = getPCs(X, PCs)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% y = getPCs(X, PCs)
%-------------------------------------------------------------------
% Function to extract principal componenets via singular value
% decomposition
%
% INPUT ARGS:
%       X - training data matrix
%       PCs - if value is a positive integer, either number of PCs to extract based on significance , or variance explained by PCs if value
%       between 0 and 1
%
% OUTPUT ARGS:
%       y - training data matrix with only principal compenents
%
% EXAMPLES:
%
% TODO:
%   Retrieve the indices of the principal componenets
% 
    
    [U,S,V] = svd(X);

    % This graph shows how many PCs explain 
    diagS = diag(S);
    diagS = diagS.^2;
    diagS = diagS/sum(diagS);
    %find first variable in cumsumDiagS that is above explThresh, 
    %arbitrarily set explThresh to .9
    if (PCs < 1 && PCs >0)
        explThresh = PCs;
        cumsumDiagS = cumsum(diagS);
        nPC = find(cumsumDiagS>=explThresh, 1);
    elseif (PCs>1)
        nPC = round(PCs);
    end

    xPC = X * V;
    y = xPC(:,1:nPC);
    
    disp(['got ' num2str(nPC) ' PCs']);

end