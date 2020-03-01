function [xScaled, shift1, shift2, scaleFactor] = scaleDataInRange(xIn, desiredMinMax)
% [xScaled, scaledRange] = scaleDataInRange(xIn, desiredMinMax, scaleByMinMax)
% -------------------------------------------------------------------------
% Blair/Bernard - February 25th, 2020
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

desiredMin = desiredMinMax(1);
desiredMax = desiredMinMax(2);

% Shift data by subtracting mean
xVec = xIn(:);
shift1 = min(xVec);
xVec = xVec - shift1;

%%% OUTPUTS %%%
% Scaled data
scaleFactor = (desiredMinMax(2) - desiredMinMax(1)) / ...
            (max(xIn(:)) - min(xIn(:)));

xVec = xVec .* scaleFactor;
shift2 = desiredMinMax(1);

xVec = xVec + shift2;

xScaled = reshape(xVec, size(xIn) );