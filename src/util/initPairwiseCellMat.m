function pairwiseCellMat = initPairwiseCellMat(numClasses)

    
    pairwiseCellMat = cell(numClasses);
    for cat1 = 1:numClasses-1
        for cat2 = (cat1+1):numClasses
            tempStruct = struct();
            tempStruct.CM = zeros(2);
            tempStruct.classBoundary = [num2str(cat1) ' vs. ' num2str(cat2)];
            tempStruct.accuracy = NaN;
            tempStruct.dataPoints = NaN;
            tempStruct.predictions = NaN;
            pairwiseCellMat{cat1, cat2} = tempStruct;
            pairwiseCellMat{cat2, cat1} = tempStruct;
        end
    end

    for i = 1:numClasses
         pairwiseCellMat{i,i} = NaN;
    end



end
