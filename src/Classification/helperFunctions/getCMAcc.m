function y = getCMAcc(CM)

    [r c] = size(CM);
    numCorrect = sum(diag(CM));
    allPredictions = sum(sum(CM));
    
    y = numCorrect / allPredictions;

end