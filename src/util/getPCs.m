function [y, V, nPC] = getPCs(X, PCs)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% [xTickVec yTickVec] = getTickCoord()
% --------------------------------
% Bernard Wang, Sept 28, 2019
% 
% INPUT ARGS:
%
% OUTPUT ARGS:
%   - xTickVec 
%   - yTickVec
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

% TODO:
%   Retrieve the indices of the principal componenets
% 

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
    end

    xPC = X * V;
    y = xPC(:,1:nPC);
    
    disp(['got ' num2str(nPC) ' PCs']);

end