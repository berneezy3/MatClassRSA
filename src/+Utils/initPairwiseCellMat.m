function pairwiseCellMat = initPairwiseCellMat(numClasses)
%-------------------------------------------------------------------
% pairwiseCellMat = initPairwiseCellMat(numClasses)
% ------------------------------------------------------------------
%
% Given the number of classes numClasses, this function initializes a
% {numClasses x numClasses} cell array, each element of which will store
% the confusion matrix, class labels, and accuracy of each pairwise
% classification. 
% 
% INPUT ARGS:
%   - numClasses: number of classes in pairwise classification
%
% OUTPUT ARGS:
%   - pairwiseCellMat: A {numClasses x numClasses} cell array. Off-diagonal
%   elements i, j of the cell array will store output for pairwise
%   classifications of i, j in the following fields:
%   - CM: 2 x 2 confusion matrix (initialized as all zeros)
%   - classBoundary: Label of the pair, e.g., '1 vs. 2'
%   - accuracy: Classification accuracy of the pair (initialized as NaN)

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
    
    pairwiseCellMat = cell(numClasses);
    for cat1 = 1:numClasses-1
        for cat2 = (cat1+1):numClasses
            tempStruct = struct();
            tempStruct.CM = zeros(2);
            tempStruct.classBoundary = [num2str(cat1) ' vs. ' num2str(cat2)];
            tempStruct.accuracy = NaN;
%             tempStruct.dataPoints = NaN;
%             tempStruct.predictions = NaN;
            pairwiseCellMat{cat1, cat2} = tempStruct;
            pairwiseCellMat{cat2, cat1} = tempStruct;
        end
    end

    for i = 1:numClasses
         pairwiseCellMat{i,i} = NaN;
    end



end
