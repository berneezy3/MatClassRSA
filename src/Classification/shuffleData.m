function [shuffledX, shuffledY, shuffledInd] = shuffleData(X,Y)
%-------------------------------------------------------------------
% [shuffledX, shuffledY] = shuffleData(X,Y)
% -------------------------------------------------------------
% Bernard Wang - April. 30, 2017
%
% The function to shuffle training data before cross validating
%
% INPUT ARGS:
%       X - training data
%       Y - labels
%
% OUTPUT ARGS:
%       shuffledX - X after shuffling
%       shuffledY - Y after shuffling (ordering still consistent 
%                   w/ shuffledX)
%
% EXAMPLES:
%
% TODO:

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



    numTrials = length(Y);
    
    % initalize return params
    [r c] = size(X);
    shuffledX = NaN(r,c);
    shuffledY = NaN(1,numTrials);
    
    % create shuffled indecies 
    shuffledInd = randperm(numTrials);
    
    % catch error if height of X and length of Y are not equal
    try 
        for i = 1:numTrials
            shuffledX(i,:) = X(shuffledInd(i),:);
            shuffledY(i) = Y(shuffledInd(i));
        end
    catch ME
        switch ME.identifier
        case 'MATLAB:badsubscript'
            warning(['Index exceedsmax dimensions,' ...
            'X height must equal Y length' ]);
            [shuffledX, shuffledY] = [NaN NaN];
        otherwise
            rethrow(ME);
        end
    end


end