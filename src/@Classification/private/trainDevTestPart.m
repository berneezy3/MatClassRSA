function obj = trainDevTestPart(X, nFolds, trainDevTestSplit)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% obj = trainDevTestPart(X, nFolds, trainDevTestSplit)
% --------------------------------
% Bernard Wang, June 27, 2017
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

[numTrials c] = size(X);

    
assert(numTrials >= nFolds, 'first parameter, k, must be lager than second parameter, n');


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

trainDevTestSplit = processTrainDevTestSplit(trainDevTestSplit, X);

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
        
        if i==1
            % randomly select indices for test trials, driven by random seed, of
            % number testSize
            randomIndices = randperm(numTrials, testSize);
        else
            % available indices
            availableIndices = setdiff(1:numTrials, randomIndices);

            % update random indices based on those left over
            randomIndices = availableIndices(randperm(length(availableIndices), testSize));
        end
        
        % indices of test trials for this fold
        testIndices = zeros( numTrials,1 );
        
        % set indices to use for testing as 1
        testIndices(randomIndices)=1;
        
        %for j = 1:testSize
            %testIndices(j+(i-1)*testSize) = 1;
       % end
        
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



