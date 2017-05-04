function y = getPCs(X, PCs)
%-------------------------------------------------------------------
% function to average extract principle componenets via singular value
% decomposition
%
% Input Args:
%       X - training data matrix
%       PCs - either number of PCs to extract based on significance if
%       value is a positive integer, or variance explained by PCs if value
%       < 0 and > 1.



    disp('getting PCs');
    
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