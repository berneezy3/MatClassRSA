classdef cvData
% cvDataObj = cvData(X,Y, partition, PCA, PCAinFold);
% --------------------------------
% Bernard Wang, August 17, 2017
% 
% cvData is an object that stores data to be used for cross validation.  It
% takes as input the X, Y data matrices, the cvpart object, then the PCA
% parameters specificed in the classifyCrossValidate() function call.  It
% formats the data into partitions to enable convineint cross validation
% later.  
% 
% INPUT ARGS:
%   - X: training data (2D)
%   - Y: labels
%   - partition: object of class cvpart
%   - PCA: ip.Results.PCA parameter specified in classifyCrossValidate() 
%   - kPCAinFold: ip.Results.PCAinFold specified in classifyCrossValidate() 
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
    
	properties
        trainXall 
        testXall 
        trainYall
        testYall 
    end
    methods
        function obj = cvData(X, Y, cvPart, PCA, PCAinFold)
            
            trainXall = {};
            testXall = {};
            trainYall = {};
            testYall = {};
            
%             if min(size(Y)) ~= min(size())
            
            %parpool;
            % DO PCA
            if (PCA >0)
                % (outside of folds)
                if (PCAinFold == 0)
                    %disp('Extracting principal components');
                    X = getPCs(X, PCA);
                    
                    for i = 1:cvPart.NumTestSets
%                     parfor i = 1:cvPart.NumTestSets
                        trainX = bsxfun(@times, cvPart.training{i}, X);
                        trainX = trainX(any(trainX~=0,2),:);
                        trainY = bsxfun(@times, cvPart.training{i}, Y);
                        trainY = trainY(trainY ~=0);
                        testX = bsxfun(@times, cvPart.test{i}, X);
                        testX = testX(any(testX~=0, 2),:);
                        testY = bsxfun(@times, cvPart.test{i}, Y);
                        testY = testY(testY ~=0);
                    
                        trainXall = [trainXall {trainX}];
                        testXall = [testXall {testX}];
                        trainYall = [trainYall {trainY}];
                        testYall = [testYall {testY}];
                    end
                % inside folds    
                else
                    [r c] = size(X);

                    for i = 1:cvPart.NumTestSets
                        disp(['conducting PCA on fold ' num2str(i) ' of ' num2str(cvPart.NumTestSets)]);
                       % Here, we separate the training and testing
                       % instances for each fold
                        
                        % Separaate test data from training data
                        % trainX will now store training data for this fold
                        trainX = bsxfun(@times, cvPart.training{i}, X);
                        trainX = trainX(any(trainX~=0,2),:);
                        % And testX will now store test data for this fold
                        testX = bsxfun(@times, cvPart.test{i}, X);
                        testX = testX(any(testX~=0, 2),:);
                        
                        % Separate test labels from training labels
                        % trainY will now store training labels for this
                        % fold
                        trainY = bsxfun(@times, cvPart.training{i}, Y);
                        trainY = trainY(trainY ~=0);
                        % And testY will now store test labels for this
                        % fold
                        testY = bsxfun(@times, cvPart.test{i}, Y);
                        testY = testY(testY ~=0);

                        % 
                        if (PCAinFold == 1)
                            [trainX, V, nPC] = getPCs(trainX, PCA);
                            testX = testX*V;
                            testX = testX(:,1:nPC);
                        end
                        trainXall = [trainXall {trainX}];
                        testXall = [testXall {testX}];
                        trainYall = [trainYall {trainY}];
                        testYall = [testYall {testY}];
                    end

                end
            % DONT DO PCA
            else

                for i = 1:cvPart.NumTestSets
%                 parfor i = 1:cvPart.NumTestSets
                    trainX = bsxfun(@times, cvPart.training{i}, X);
                    trainX = trainX(any(trainX~=0,2),:);
                    trainY = bsxfun(@times, cvPart.training{i}, Y);
                    trainY = trainY(trainY ~=0);
                    testX = bsxfun(@times, cvPart.test{i}, X);
                    testX = testX(any(testX~=0, 2),:);
                    testY = bsxfun(@times, cvPart.test{i}, Y);
                    testY = testY(testY ~=0);

                    trainXall = [trainXall {trainX}];
                    testXall = [testXall {testX}];
                    trainYall = [trainYall {trainY}];
                    testYall = [testYall {testY}];
                end
                
            end
            
            obj.trainXall = trainXall;
            obj.testXall = testXall;
            obj.trainYall = trainYall;
            obj.testYall = testYall;
            
            %delete(gcp('nocreate'));
     
      
      end
      
      
   end
end