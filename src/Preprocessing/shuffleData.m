function [randX, randY, randP, randIdx] = shuffleData(X, Y, P, r)
%-------------------------------------------------------------------
% [randX, randY, randP, randIdx] = shuffleData(X,Y,P)
% -------------------------------------------------------------
% Bernard Wang - April 30, 2017
% Revised by Blair Kaneshiro, August 9 2019
%
% This function randomizes, in tandem, ordering of trials in data matrix X,
% labels vector Y, and, optionally participants vector P. Therefore,
% ordering is disrupted, but mapping of trials to stimulus labels and
% participants is preserved. The function may be used in cases where users
% wish to mix trials across the course of a recording session or across
% participants prior to trial averaging or cross-validation.
%
% INPUT ARGS:
%   X: Data matrix. Data can be in 3D (space x time x trial) or 2D
%       (trial x feature) form.
%   Y: Labels vector. The length of Y must correspond to the length of the
%       trial dimension of X.
%   P: Participant vector (optional). The length of P must correspond to
%       the length of Y and the length of the trial dimension of X. If not
%       entered, the function will return NaN as randomized P (randP).
%   r: Random number generator specification. If not entered, defaults to
%       'shuffle'. If specifying a dual-argument random number generator
%       (e.g., ('shuffle', 'twister'), it should be entered as elements of
%       a cell array (e.g., {'shuffle', 'twister'}).
%
% OUTPUT ARGS:
%   randX: Data matrix with its trials reordered (same size as X).
%   randY: Labels vector with its trials reordered (same size as Y).
%   randP: Participants vector with its trials reordered (same size as P).
%   randIdx: Randomization applied to all inputs.
%
% EXAMPLES:
%
% TODO:

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% Set random number generator
if nargin < 4 || isempty(r), rng('shuffle');
elseif length(r) == 2, rng(r{1}, r{2});
elseif ischar(r) || length(r) == 1, rng(r);
else, error('Input r should be a single value or cell array of length 2.');
end

% Make sure data matrix X is a 2D or 3D matrix
assert(ndims(X) == 2 | ndims(X) == 3,...
    'Input data matrix must be a 2D or 3D matrix.');

% Make sure labels input Y is a vector
assert(isvector(Y), 'Input labels must be a vector.');

% Make sure length of Y matches the trial length of X
if ndims(X) == 3, [~, ~, nTrial] = size(X);
else, [nTrial, ~] = size(X); end
assert(length(Y) == nTrial, ...
    'Length of input labels vector must equal length of trial dimension of input data.');

% Compute randomization index
randIdx = randperm(nTrial);

% Randomize data and labels
if ndims(X) == 3, randX = X(:, :, randIdx);
else randX = X(randIdx,:); 
end
randY = Y(randIdx);

% Handle participants randomization if specified as output
if nargout > 2
    if nargin < 3 || isempty(P), randP = NaN;
    elseif ~isvector(P)
        error('Input participant identifiers must be a vector.');
    elseif length(P) ~= length(Y)
        error('Input labels vector and input participants vector must be the same length.');
    else
        randP = P(randIdx);
    end
end

end