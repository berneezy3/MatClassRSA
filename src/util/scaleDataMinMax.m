function [xScaled, inputMinMax] = scaleDataMinMax(xIn, outputMinMax)
% [xScaled, inputMinMax] = scaleDataMinMax(xIn, outputMinMax)
% ----------------------------------------------------------------------
% Blair - Jan 9, 2020
%
% This function takes in the data matrix xIn, and the optional vector of
% min and max values, and scales the data so that its values fall between
% the specified min and max, inclusive. If the min-max vector is not
% specified, the function will scale the data to the range [0, 10].

