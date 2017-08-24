classdef cvData
% cvDataObj = cvpart(n,k)
% --------------------------------
% Bernard Wang, August 17, 2017
% 
% This class is an alternative to the matlab cvcvPart class.  It
% cvParts cross validation folds without randomization.
% 
% INPUT ARGS:
%   - n: number of training samples
%   - k: number of folds
%
% OUTPUT ARGS:
%   - obj:  ann object of the cvpart class
    
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
            %parpool;
            % DO PCA
            if (PCA >0)
                % (outside of folds)
                if (PCAinFold == 0)
                    X = getPCs(X, PCA);
                    
                    for i = 1:cvPart.NumTestSets
%                     parfor i = 1:cvPart.NumTestSets
                        trainX = bsxfun(@times, cvPart.training{i}, X);
                        trainX = trainX(any(trainX~=0,2),:);
                        trainY = bsxfun(@times, cvPart.training{i}', Y);
                        trainY = trainY(trainY ~=0);
                        testX = bsxfun(@times, cvPart.test{i}, X);
                        testX = testX(any(testX~=0, 2),:);
                        testY = bsxfun(@times, cvPart.test{i}', Y);
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
%                     parfor i = 1:cvPart.NumTestSets
                        trainX = bsxfun(@times, cvPart.training{i}, X);
                        trainX = trainX(any(trainX~=0,2),:);
                        trainY = bsxfun(@times, cvPart.training{i}', Y);
                        trainY = trainY(trainY ~=0);
                        testX = bsxfun(@times, cvPart.test{i}, X);
                        testX = testX(any(testX~=0, 2),:);
                        testY = bsxfun(@times, cvPart.test{i}', Y);
                        testY = testY(testY ~=0);

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
                    trainY = bsxfun(@times, cvPart.training{i}', Y);
                    trainY = trainY(trainY ~=0);
                    testX = bsxfun(@times, cvPart.test{i}, X);
                    testX = testX(any(testX~=0, 2),:);
                    testY = bsxfun(@times, cvPart.test{i}', Y);
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
            
            delete(gcp('nocreate'));
     
      
      end
      
      
   end
end