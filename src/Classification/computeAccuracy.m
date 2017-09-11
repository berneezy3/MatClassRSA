function acc = computeAccuracy(actualY, predictedY)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------

    assert(length(actualY) == length(predictedY), 'length of vectors must be the same');

    correctPredictions = 0;
    for i = 1:length(actualY)
        if actualY(i) == predictedY(i)
            correctPredictions = correctPredictions + 1;
        end
    end

    acc = (correctPredictions/length(actualY));
    
end