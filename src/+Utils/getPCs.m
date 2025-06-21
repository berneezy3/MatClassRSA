function [y, V, nPC] = getPCs(X, PCs)
%-------------------------------------------------------------------
% [y, V, nPC] = getPCs(X, PCs)
% --------------------------------
% 
% Function to extract principal componenets via singular value
% decomposition
%
% INPUT ARGS:
%   X - training data matrix
%   PCs - if value is a positive integer, this specifies the number of PCs 
%     to extract based on significance. If a value between 0 and 1, this 
%     specifies the desired proportion of variance explained and the number
%     of PCs will be computed accordingly.
%
% OUTPUT ARGS:
%   y - training data matrix with only principal compenents
%   V - SVD parameter
%   nPC - number of PCs extracted

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
    elseif (PCs>=1)
        nPC = round(PCs);
    elseif (PCs == 0)
        [r c] = size(X);
        V = 1;
        nPC = c;
    end

    xPC = X * V;
    y = xPC(:,1:nPC);
    
    disp(['Got ' num2str(nPC) ' PC(s)']);

end