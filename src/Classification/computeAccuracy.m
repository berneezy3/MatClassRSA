function acc = computeAccuracy(actualY, predictedY)

    assert(length(actualY) == length(predictedY), 'length of vectors must be the same');

    correctPredictions = 0;
    for i = 1:length(actualY)
        if actualY(i) == predictedY(i)
            correctPredictions = correctPredictions + 1;
        end
    end

    acc = (correctPredictions/length(actualY));
    
end