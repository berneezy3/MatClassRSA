function accArr = permuteModel(cvDataObj, nFolds, nPerms, classifier, classifyOptions)
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
    % initialize return variable
    accArr = NaN(nPerms, 1);

    % initialize variables to store correct vs. incorrect
    correctPreds = 0;
    incorrectPreds = 0;
    
    %loop same # of times as cross validation
%     parpool;
%     parfor i = 1:nPerms
    for i = 1:nPerms
        correctPreds = 0;
        incorrectPreds = 0;
        for j = 1:nFolds
                        
            disp(['calculating ' num2str((i-1)*nFolds + j) ' of '...
            num2str(nPerms*nFolds) ' fold-permutations']);
            trainX = cvDataObj.trainXall{j};
            trainY = cvDataObj.trainYall{j};
            testX = cvDataObj.trainXall{j};
            testY = cvDataObj.trainYall{j};
            
            % randomize
            [r c] = size(trainX);
            pTrainX = trainX(randperm(r), :);

            %get correctly predicted labels
%             mdl = fitModel(pTrainX, trainY, classifier, ...
%             classifyOptions);
%             [funcOutput mdl] = evalc( ['fitModel(pTrainX, trainY, classifier,' ...
%             'classifyOptions)']);
            mdl =  fitModel(pTrainX, trainY, classifier, classifyOptions);
            predictedY = modelPredict(testX, mdl);


            %store accuracy
            for k = 1:length(predictedY)
                if predictedY(k) == testY(k)
                    correctPreds = correctPreds + 1;
                else
                    incorrectPreds = incorrectPreds + 1;
                end
            end
        
        end
        accArr(i) = correctPreds/(correctPreds + incorrectPreds);

    end
    
%     pVal = correctPreds/(correctPreds + incorrectPreds);
    delete(gcp('nocreate'));

    
end