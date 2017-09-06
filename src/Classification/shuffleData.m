function [shuffledX, shuffledY, shuffledInd] = shuffleData(X,Y)
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