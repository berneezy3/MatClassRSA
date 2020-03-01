function [xScaled, inputRange, outputRange] = scaleDataMinMax(xIn, inputRange, outputRange)
% [xScaled, inputRange, outputRange] = scaleDataMinMax(xIn, inputRange, outputRange)
% -------------------------------------------------------------------------
% Blair - Jan 9, 2020
%
% This function takes in the data matrix xIn plus optional inputs
% specifying input and output data ranges, and scales the values of xIn 
% according to these specified ranges or default values. This function is 
% used, for example, to scale training data in the range of [0, 1] prior to
% training an SVM classifier, and to apply those same scaling parameters to
% test data that will be run through the model.
% 
% INPUTS
%   xIn: Input numeric data matrix.
%   inputRange (optional): Two-element, ordered vector specifying min and 
%       max values of the data prior to scaling. This is specified, for 
%       example, when we want to scale test data according to the range of 
%       values of training data. 
%       - If not specified or empty, this parameter will be set to 
%         [min(xIn(:)) max(xIn(:))]. 
%       - If this input is specified (e.g., from a separate set of training
%         data), the range of values in xScaled may not fall exactly 
%         between the values specified by outputRange.
%   outputRange (optional): Two-element, ordered vector specifying the 
%       min and max values to which inputRange should be scaled. If not 
%       specified or empty, this parameter will default to [0, 1].
%
% OUTPUTS
%   xScaled: The scaled data. This variable will be a data matrix the same 
%       size as the input variable xIn.
%   scaledRange: Two-element vector specifying the min and max values by 
%       which the input data were scaled. The vector will be equal to
%       inputRange if that was specified as an input; otherwise, it will
%       contain the min and max values of the input data xIn.

% **********LICENSE GOES HERE************

% If outputRange was specified AND is not empty, 
if exist('outputRange', 'var') && ~isempty(outputRange)
    % verify that it is a 2-element vector
    if ~isvector(outputRange) || length(outputRange) ~= 2
        error('Input ''outputRange'' should be a vector of length 2.'); end
    % verify that its second element is strictly greater than the first.
    if outputRange(2) <= outputRange(1)
        error('Second element (max) of input ''outputRange'' must be strictly greater than first element (min).'); end
% Otherwise, if empty or not specified, set to [0, 1] and print warning message.
else
    warning('Output data scaling range not specified. Setting to [0, 1].');
    outputRange = [0 1];   
end
disp(['outputRange = ' mat2str(outputRange)]) % For debugging

% If inputRange was specified AND is not empty,
if exist('inputRange', 'var') && ~isempty(inputRange)
    % verify that it is a 2-element vector
    if ~isvector(inputRange) || length(inputRange) ~= 2
        error('Input ''inputRange'' should be a vector of length 2.'); end
    % verify that its second element is strictly greater than the first.
    if inputRange(2) <= inputRange(1)
        error('Second element (max) of input ''inputRange'' must be strictly greater than first element (min).'); end
else
   inputRange = [min(xIn(:)) max(xIn(:))];
end
disp(['inputRange = [' sprintf('%.2f %.2f', inputRange) ']']) % For debugging

%%% OUTPUTS %%%
% Scaled data
xScaled = outputRange(1) + ...
    ((xIn - inputRange(1)) * (outputRange(2) - outputRange(1))) / ...
    (inputRange(2) - inputRange(1));
