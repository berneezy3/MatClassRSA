function [xScaled, scaledRange] = scaleDataMinMax(xIn, desiredMinMax, scaleByMinMax)
% [xScaled, scaledRange] = scaleDataMinMax(xIn, desiredMinMax, scaleByMinMax)
% -------------------------------------------------------------------------
% Blair - Jan 9, 2020
%
% This function takes in the data matrix xIn plus an optional vector of
% min and max values, and scales its values so that its values fall 
% between the specified output min and max. If the output min-max vector 
% is not specified or is empty, the function will scale the data to the 
% range [0, 1]. Scaling is based upon the min and max values of the entire
% input data matrix.
% 
% INPUTS
%   xIn: Input numeric data matrix.
%   desiredMinMax (optional): Two-element vector specifying the desired 
%       min and max values (in order) of the scaled data. If not specified 
%       or empty, this will default to [0, 1].
%   scaleByMinMax (optional): Two-element vector specifying min and max
%       data values, in order, by which the data should be scaled. This is 
%       used, for example, when we want to scale test data according to the 
%       scaling parameters of the training data. If not specified or empty, 
%       the input data will be scaled according to its own min and max. 
%       Note that if this input is specified, the range of values in the 
%       output data may not exactly fall between the min and max specified 
%       by desiredMinMax.
%
% OUTPUTS
%   xScaled: The scaled data. This variable will be a data matrix the same 
%       size as the input variable xIn.
%   scaledRange: Two-element vector specifying the min and max values by 
%       which the input data were scaled. The vector will be equal to
%       scaleByMinMax if that was specified as an input; otherwise, it will
%       contain the min and max values of the input data xIn.

% LICENSE GOES HERE

% If desiredMinMax was specified AND is not empty, 
if exist('desiredMinMax', 'var') && ~isempty(desiredMinMax)
    % verify that it is a 2-element vector
    if ~isvector(desiredMinMax) || length(desiredMinMax) ~= 2
        error('Input ''desiredMinMax'' should be a vector of length 2.'); end
    % verify that its second element is strictly greater than the first.
    if desiredMinMax(2) <= desiredMinMax(1)
        error('Second element (max) of input ''desiredMinMax'' must be strictly greater than first element (min).'); end
% Otherwise, if empty or not specified, set to [0, 1] and print warning message.
else
    warning('Output data scaling range not specified. Setting to [0, 1].');
    desiredMinMax = [0 1];   
end
disp(['desiredMinMax = ' mat2str(desiredMinMax)]) % For debugging

% If scaleByMinMax was specified AND is not empty,
if exist('scaleByMinMax', 'var') && ~isempty(scaleByMinMax)
    % verify that it is a 2-element vector
    if ~isvector(scaleByMinMax) || length(scaleByMinMax) ~= 2
        error('Input ''scaleByMinMax'' should be a vector of length 2.'); end
    % verify that its second element is strictly greater than the first.
    if scaleByMinMax(2) <= scaleByMinMax(1)
        error('Second element (max) of input ''scaleByMinMax'' must be strictly greater than first element (min).'); end
else
   scaleByMinMax = [min(xIn(:)) max(xIn(:))];
end
disp(['scaleByMinMax = [' sprintf('%.2f %.2f', scaleByMinMax) ']']) % For debugging

%%% OUTPUTS %%%
% Scaled data
xScaled = desiredMinMax(1) + ...
    ((xIn - scaleByMinMax(1)) * (desiredMinMax(2) - desiredMinMax(1))) / ...
    (scaleByMinMax(2) - scaleByMinMax(1));
% Scaled range that was used
scaledRange = scaleByMinMax;
