function pVal = pbinom(Y, nFolds, accuracy)
% pbinom.m
% -----------
% Blair
% January 30 2012

classes = unique(Y);
classCount = sum(Y == classes(1));
foldSize = floor(length(Y)/nFolds);

if (length(Y)) < 100
    error('To use binomial CDF to computer P-value, number of observatons must > 100.')
end

if foldSize < length(Y)/10
    error(['To use binomial CDF to computer P-value, the size of each fold ' ...
        'should be greater than the number of observations/10. Make sure number ' ...
        'of folds is <= 10'])
end

% check to make sure the amount of each class is equal
for i = 1:length(classes)
    if classCount ~= sum(Y == classes(i))
        error(' number of classes must be equal to one another.');
    end
end

%rate = 13.16;  % number between 0-100
chance = 1/length(classes);
trialsPerFold = floor(length(Y)/nFolds);


pVal = 1-binocdf(floor(trialsPerFold*accuracy/100), trialsPerFold, chance)