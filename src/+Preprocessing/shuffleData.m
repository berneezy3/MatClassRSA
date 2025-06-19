function [randX, randY, randP, randIdx] = shuffleData(X, Y, varargin)
%-------------------------------------------------------------------
% [randX, randY, randP, randIdx] = Preprocessing.shuffleData(X, Y, P, rngType)
%-------------------------------------------------------------------
%
% This function randomizes, in tandem, ordering of trials in data matrix X,
% labels vector Y, and, optionally, participants vector P. Therefore,
% ordering is disrupted, but mappings between trials, stimulus labels, and
% participants are preserved. The function can be used in cases where users
% wish to distribute trials across the course of a recording session or 
% across participants, prior to trial averaging or cross-validation.
%
% REQUIRED INPUTS:
%   X: Data matrix. Data can be in 3D (space x time x trial) or 2D
%       (trial x feature) form.
%   Y: Labels vector (numeric). The length of Y must correspond to the 
%       length of the trial dimension of X.
%
% OPTIONAL INPUTS:
%   P: Participant vector. The length of P must correspond to
%       the length of Y and the length of the trial dimension of X. If P
%       is not entered or is empty, the function will return NaN as 
%       randomized P. P can be a numeric vector, string array, or cell 
%       array.
%
% OPTIONAL NAME-VALUE INPUTS: 
%   rngType - Random number generator specification. Here you can set the
%       the rng seed and the rng generator, in the form {'rngSeed','rngGen'}.
%       If rngType is not entered, or is empty, rng will be assigned as 
%       rngSeed: 'shuffle', rngGen: 'twister'. Where 'shuffle' generates a 
%       seed based on the current time.
%       --- Acceptable specifications for rngType ---
%           - Single-argument specification, sets only the rng seed
%               (e.g., 4, 0, 'shuffle'); in these cases, the rng generator  
%               will be set to 'twister'. If a number is entered, this number will 
%               be set as the seed. If 'shuffle' is entered, the seed will be 
%               based on the current time.
%           - Dual-argument specifications as either a 2-element cell 
%               array (e.g., {'shuffle', 'twister'}, {6, 'twister'}) or string array 
%               (e.g., ["shuffle", "philox"]). The first argument sets the
%               The first argument set the rng seed. The second argument
%               sets the generator to the specified rng generator type.
%           - rng struct as previously assigned by rngType = rng.
%
% OUTPUTS
%   randX: Data matrix with its trials reordered (same size as X).
%   randY: Labels vector with its trials reordered (same size as Y).
%   randP: Participants vector with its trials reordered (same size as P).
%   randIdx: Randomized ordering applied to all inputs.

% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

ip = inputParser;
ip.FunctionName = 'shuffleData';
ip.addRequired('X', @isnumeric);
ip.addRequired('Y', @isvector);

%parse optional participants vector
defaultP = zeros(size(Y));
addOptional(ip, 'P', defaultP);

% parse optional inputs
defaultRandomSeed = {'shuffle', 'twister'}; 
if verLessThan('matlab', '8.2')
    addParamValue(ip, 'rngType', defaultRandomSeed);
else
    addParameter(ip, 'rngType', defaultRandomSeed);
end

parse(ip, X, Y, varargin{:});

Utils.setUserSpecifiedRng(ip.Results.rngType);

% Make sure data matrix X is a 2D or 3D matrix
assert(ndims(X) == 2 | ndims(X) == 3,...
    'Input data matrix must be a 2D or 3D matrix.');

% Make sure labels input Y is a vector
assert(isvector(Y), 'Input labels must be a vector.');

% Make sure length of Y matches length of trial dimension of X
if ndims(X) == 3, [~, ~, nTrial] = size(X);
else, [nTrial, ~] = size(X); end
assert(length(Y) == nTrial, ...
    'Length of input labels vector must equal length of trial dimension of input data.');

% Compute randomization index
randIdx = randperm(nTrial);

% Randomize data and labels
if ndims(X) == 3, randX = X(:, :, randIdx);
else, randX = X(randIdx,:);
end
randY = Y(randIdx);

% Handle participants randomization if specified as output
if nargout > 2
    if nargin < 3 || isempty(ip.Results.P), randP = NaN;
    elseif ~isvector(ip.Results.P)
        error('Input participant identifiers must be a vector.');
    elseif length(ip.Results.P) ~= length(Y)
        error('Input labels vector and input participants vector must be the same length.');
    else
        randP = ip.Results.P(randIdx);
    end
end

end