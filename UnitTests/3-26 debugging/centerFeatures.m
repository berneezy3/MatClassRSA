function xOut = centerFeatures(xIn)
% TEMP_centerFeatures.m
% -----------------------
% Blair - March 22, 2020
% Temporary function to center every feature (subtract out the mean) in the
% data matrix. Currently we center all the data (train + test) at once.
% Code under development will do this more properly (center training data
% and apply same parameters to test set).
%
% Input:
% - xIn: 3D (space x time x trial) or 2D (trial x feature) data matrix
%
% Output: 
% - xOut: Matrix of same size

if ndims(xIn) == 3
    in3 = 1;
    [nSpace, nTime, nTrial] = size(xIn);
    xIn = cube2trRows(xIn);
else
    [nTrial, ~] = size(xIn);
    in3 = 0;
end

featMeans = mean(xIn, 1);
xOut = xIn - repmat(featMeans, nTrial, 1);

if in3, xOut = trRows2cube(xOut, nTime); end