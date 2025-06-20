function obj = trainDevTestPart(X, nFolds, trainDevTestSplit)
%-------------------------------------------------------------------
% obj = trainDevTestPart(X, nFolds, trainDevTestSplit)
% --------------------------------
% 
% This class stores a cross-validation partition.  This constructor
% of this class takes in the number of train samples n and number of
% train k folds, then creates k partitions in the data.  This object is
% to be passed into the constructor cvData() later.
%
% This class is an alternative to the matlab cvpartition class.  The reason
% this class is used instead of the matlab cvpartition class is because the
% matlab class uses randomization to assign partitions.  In MatClassRSA, 
% data shuffling is handled in the preprocessing step, we choose to assign
% partitions sequentially.  
% 
% INPUT ARGS:
%   - trainDevTestSplit: %   'trainDevTestSplit' - This determines the size 
%       of the train, developement (AKA validation) and test set sizes 
%       for each fold of cross validation.  
%   - X: input data matrix
%   - nFolds: number of folds
%
% OUTPUT ARGS:
%   - obj:  an object of the cvpart class

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

if ndims(X) == 3
    % add reshape data to 2D
    X = Utils.cube2trRows(X);
end


[numTrials c] = size(X);

    
assert(numTrials >= nFolds, 'first parameter, k, must be larger than second parameter, n');


obj.optimize = 1;


if length(trainDevTestSplit) == 2
%     trainDevTestSplit = [trainDevTestSplit(1) 0 trainDevTestSplit(2)];
%     obj.optimize = 0;
    if (nFolds > 1) 
        trainSplit = (1 - 1/nFolds) * trainDevTestSplit(1);
        devSplit = (1 - 1/nFolds) * trainDevTestSplit(2);
        testSplit = 1/nFolds;
        trainDevTestSplit = [trainSplit devSplit testSplit];
    else % for trainMulti_opt, trainPairs_opt, there is only a single fold
        trainSplit = trainDevTestSplit(1);
        devSplit = trainDevTestSplit(2);
%         testSplit = 1/nFolds;
        trainDevTestSplit = [trainSplit devSplit 0];
    end
end


trainDevTestSplit = Utils.processTrainDevTestSplit(trainDevTestSplit, X);

obj.train = {};
obj.dev = {};
obj.test = {};

%initialize indices list
obj.folds = {};

%initialize number of sets
obj.NumTestSets = nFolds;

%get size of train/dev/test sets
trainSize = trainDevTestSplit(1);
devSize = trainDevTestSplit(2);
testSize = trainDevTestSplit(3);

%get remainder
remainder = rem(numTrials, nFolds);

% foldSize is the number of trials each test fold
foldSize = floor(numTrials/nFolds);

%case divisible
if remainder == 0
    for i = 1:nFolds
        
        testIndices = zeros( numTrials,1 );
        
        for j = 1:testSize
            testIndices(j+(i-1)*testSize) = 1;
        end
        
        % the train/dev indices indices should consist of the
        % non-test indices
        trainDevIndices = find(testIndices == 0);
        trainIndices = testIndices == 0;
        % clear dev indices in train indices
        trainIndices(trainDevIndices(trainSize + 1:trainSize + devSize)) = 0;
        % create dev indices
        devIndices = ((testIndices == 0) .* (trainIndices==0));
 
        obj.train{end+1} = trainIndices;
        obj.dev{end+1} = devIndices;
        obj.test{end+1} = testIndices;
    end
%case indivisible
else   
    indexlocation = 0;
        
    for i = 1:nFolds
        
        testIndices = zeros( numTrials,1 );
        if (i ~= nFolds) % handle non-remainders here
            for j = 1:testSize
                testIndices(j+(i-1)*testSize) = 1;
                indexlocation = indexlocation + 1;
            end   
            trainDevIndices = find(testIndices == 0);
            trainIndices = (testIndices == 0);
            trainIndices(trainDevIndices(trainSize + 1:trainSize + devSize)) = 0;
            devIndices = ((testIndices == 0) .* (trainIndices==0));
        elseif  (i == nFolds) % handle remainders here
            for j = 1:testSize+remainder
                testIndices(j+(i-1)*testSize) = 1;
                indexlocation = indexlocation + 1;
            end
            trainDevIndices = find(testIndices == 0);
            trainIndices = (testIndices == 0);
            trainIndices(trainDevIndices(end-devSize:end)) = 0;
            devIndices = ((testIndices == 0) .* (trainIndices==0));
        end

        % the train/dev indices indices should consist of the
        % non-test indices

        
        obj.train{end+1} = trainIndices;
        obj.dev{end+1} = devIndices;
        obj.test{end+1} = testIndices;
        
    end
    %{
    % handle remainders
    disp("numTrials not divisible by nFolds.  Putting remainder trials within the last fold");
    testIndices = zeros( numTrials,1 );
    testIndices(nFolds * testSize + 1:end) = 1;

    trainIndices = testIndices == 0;
    trainIndices = trainIndices(1:trainSize);
    devIndices = devIndices(end - devSize: end);
    testIndices = testIndices == 1;

    trainDevIndices = find(testIndices == 0);
    trainIndices = testIndices == 0;
    trainIndices(trainDevIndices(trainSize + 1:trainSize + devSize)) = 0;
    devIndices = testIndices == 0;
    trainIndices(trainDevIndices(1:trainSize)) = 0;

    obj.train{end+1} = trainIndices;
    obj.dev{end+1} = devIndices;
    obj.test{end+1} = testIndices;
    %}
%     obj.NumTestSets = obj.NumTestSets+1;
end

end



