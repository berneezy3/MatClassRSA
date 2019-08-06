function [winnerIndex, tallies, tieFlag] = SVMhandleties(dec_vals, labels)

    if length(dec_vals) ~= length(labels) * (length(labels) -1) /2
        error("Number of decision values must equal nLabels * (nLabels-1) /m2");
    end

    tallies = zeros(1, length(labels));
    tieFlag = 0;

    for i = 1:length(dec_vals)
        firstInd = i;
        % get the first index
        for j = (length(labels)-1):-1:1
            if (firstInd - j <= 0)
                secondInd = length(labels) + firstInd - j;
                firstInd = length(labels)-j; 
                break;
            else
                firstInd = firstInd -j;
            end
        end
        
        % add tallies
        if dec_vals(i) > 0
           tallies(firstInd) =  tallies(firstInd) + 1;
        elseif dec_vals(i) < 0
           tallies(secondInd) =  tallies(secondInd) + 1;
        else % equal distance!!!!!!
            if rand(1) > .5
                tallies(firstInd) =  tallies(firstInd) + 1;
            else
                tallies(secondInd) =  tallies(secondInd) + 1;
            end
        end
        
        %disp(['i: ' num2str(i) ', 1st val: ' num2str(firstInd)  ', 2nd val: ' num2str(secondInd)]);
       
         
    end
    
    %return class index of highest tallies
    winnerIndex = find(tallies == max(tallies));    
    
    % if there is a tie, we randomly select the class
    if length(winnerIndex) > 1
        tieFlag = 1;
        disp(['Ties between classes: ' num2str(labels([winnerIndex])) '.  Randomizing winner']);
        randIdx=randperm(length(winnerIndex),1);
        winnerIndex = winnerIndex(randIdx);
    end
    

end
