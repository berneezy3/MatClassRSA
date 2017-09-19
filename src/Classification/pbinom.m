function pVal = pbinom(Y, nFolds, accuracy)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% pVal = pbinom(Y, nFolds, accuracy)
% -----------
% Bernard Wang
% January 30 2012
%
% This function computes the p-value via binomial CDF (cumutalive
% Distribution Function)
%
% INPUT ARGS:
%   - Y: the labels for the training data
%   - nFolds: the number of folds 
%   - accuracy: the actual accuracy of the classifier
%
% OUTPUT ARGS:
%   - pVal: P-value

classes = unique(Y);
classCount = sum(Y == classes(1));
foldSize = floor(length(Y)/nFolds);

% make sure nObs > 100, so we have at least the minimal amount of trials
if (length(Y)) < 100
    warning('To use binomial CDF to compute P-value, number of observatons must > 100.')
end

% make sure N > nObs/10, to prevent going over maximum amount of folds
if nFolds > 10
    warning(['To use binomial CDF to compute P-value, the size of each fold ' ...
        'should be greater than the number of observations/10. Make sure number ' ...
        'of folds is <= 10'])
end

% check to make sure the amount of each class is equal
for i = 1:length(classes)
    if classCount ~= sum(Y == classes(i))
        warning('Should have equal amount of trials of each class');
        break;
    end
end

%rate = 13.16;  % number between 0-100
chance = 1/length(classes);
trialsPerFold = round(length(Y)/nFolds);

pVal = 1-binocdf(trialsPerFold*accuracy, trialsPerFold, chance);