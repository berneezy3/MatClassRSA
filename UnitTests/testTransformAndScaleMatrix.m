% testComputeClassificationRDM.m

% General checks: Try out different parameter configurations when inputting
% a confusion-type matrix and a pairwise accuracy-type matrix

% In addition to general checks please try the following conditions:
% - Check the params output when inputting (1) multiclass and (2) pairwise
% matrices with no name-value pairs to make sure they are the correct 
% defaults for each case
% - If inputting a pairwise matrix and calling the function with defaults,
% the output should be the same as the input. (Maybe this doesn't make
% sense, design-wise? If so we could change the ranking default to compute 
% ranks or percentile ranks)
% - Check cases where the user input a pairwise matrix along with not-allowed
% specifications for normalize and distance name-value pairs.
% - when specifying pairwise input, try inputting a non-symmetric matrix
% and asking the function to rank distances, and see if the output is
% symmetric and ranked based on the lower triangle only