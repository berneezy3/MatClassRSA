function [reliabilities] = computeSpaceTimeReliability(X, Y, varargin)
%------------------------------------------------------------------------------------------
%  [reliabilities] = Reliability.computeSpaceTimeReliability(X, Y, ...
%                    numPermutations, rngType)
%------------------------------------------------------------------------------------------
%
% This function returns split-half reliabilities computed for each 
% component across time. With the resulting data matrix, one can take the 
% mean along the components (space) axis and this will tell you the 
% average reliability across components at each time point. On the other 
% hand, if one takes the mean across the time axis, one will be able to see 
% how reliable each component is across time (on average). Since split-half 
% reliability is computed, the Spearman-Brown correction is applied.
%
% REQUIRED INPUTS:
%   X - The data matrix. Can be a 3D matrix (space x time x trial)
%       or a 2D matrix (trial x feature).
%   Y - labels vector. Length should match the length of the trials
%       dimension of X.
%
% OPTIONAL NAME-VALUE INPUTS:
%   numPermutations - how many permutations to split the trials 
%       for split-half reliability. If numPermutations is not entered or is 
%       empty, this defaults to 10.
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
% OUTPUTS:
%   reliabilities - reliability for each electrode across time. The 
%       dimensions of this matrix are nSpace x nTime x nPermutations if a 
%       3D matrix was provided. If a 2D matrix was provided, the 
%       dimensions of the results are nTime x nPermutations. You would 
%       typically average across the permutations dimension.

% This software is licensed under the 3-Clause BSD License (New BSD License),
% as follows:
% -------------------------------------------------------------------------
% Copyright 2019 Bernard C. Wang, Nathan C. L. Kong, Anthony M. Norcia, 
% and Blair Kaneshiro
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
%
% MatClassRSA dependencies: Utils.setUserSpecifiedRng(),
% Utils.computeReliability()
%
% See also Reliability.computeSampleSizeReliability()

% parse inputs
ip = inputParser;
addRequired(ip, 'X');
addRequired(ip, 'Y');
addParameter(ip, 'numPermutations', 10);
addParameter(ip, 'rngType', 'default');
parse(ip, X, Y, varargin{:})

% If 3D matrix entered, dimensions are: space x time x trial
% We will permute so that it becomes space x trial x time
if length(size(X)) == 3
    X = permute(X, [1,3,2]); % space x trial x time
% If 2D matrix entered, dimensions are: trial x time
% We add
% a singleton dimension in the front for space.
elseif length(size(X)) == 2
    temp = X; clear X; % X is trial x feature
    X(1,:,:) = temp; clear temp; % space (1) x trial x feature
else
    error('Input data should be a 2D or 3D matrix.');
end


% Set random number generator
if any(strcmp(ip.UsingDefaults, 'rngType')), Utils.setUserSpecifiedRng();
else, Utils.setUserSpecifiedRng(ip.Results.rngType);
end

num_components = size(X, 1);
num_timepoints = size(X, 3);

reliabilities = zeros(num_timepoints, ip.Results.numPermutations, num_components);
for t=1:num_timepoints
    fprintf('Timepoint %d\n', t);
    curr_data = squeeze(X(:,:,t));
    rels = Utils.computeReliability(curr_data, Y, ip.Results.numPermutations);
    assert(isequal(size(rels), [ip.Results.numPermutations, num_components]));
    reliabilities(t,:,:) = rels;
end

% This means a 3D data matrix was provided. Permute the results matrix 
% so that the dimensions are: space x time x permutations
if num_components > 1
    reliabilities = permute(reliabilities, [3,1,2]);
end

end


