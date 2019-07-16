function RDM = computeCM_RDM(CM, varargin)
%-------------------------------------------------------------------
% RDM = cm2rdm(CM, varargin)
% ------------------------------------------------
% Blair - January 31, 2017
%
% RDM = cm2rdm(CM) converts confusion matrix CM into distance matrix RDM.
%
% Required inputs:
% - CM: A square confusion matrix
%
% Optional inputs:
% - distpower: Integer > 0 (if using 'power' or 'log' distance)
%
% Optional name-value pairs:
% - 'normalize': 'diagonal' (default), 'sum', 'none'
% - 'symmetrize': 'average' (default), 'geometric', 'harmonic', 'none'
% - 'distance': 'linear' (default), 'power', 'logarithmic', 'none'
% - 'rankdistances': 'none' (default), 'rank', 'percentrank'
%
% Outputs:
% - DM: The distance matrix
%
% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers: https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers

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

% Initialize the input parser
ip = inputParser;
ip.CaseSensitive = false;

% Specify default values
defaultDistpower = 1;
defaultNormalize = 'diagonal';
defaultSymmetrize = 'arithmetic';
defaultDistance = 'linear';
defaultRankdistances = 'none';

% Specify expected values
expectedNormalize = {'diagonal', 'sum', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};

% Required inputs
addRequired(ip, 'CM', @isnumeric)

% Optional inputs
addOptional(ip, 'distpower', defaultDistpower, @isnumeric);

% Optional name-value pairs
% NOTE: Should use addParameter for R2013b and later.
if verLessThan('matlab', '8.2')
    addParamValue(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParamValue(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParamValue(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParamValue(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
else
    addParameter(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParameter(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParameter(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParameter(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
end


% Parse
parse(ip, CM, varargin{:});

% Verify the confusion matrix is square
if size(CM, 1) ~= size (CM, 2)
    error('The input confusion matrix should be square.')
end

disp('Computing distance matrix...')

% NORMALIZE
NM = normalizeMatrix(CM, ip.Results.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, ip.Results.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, ip.Results.distance, ip.Results.distpower);

% RANKDISTANCES
RDM = rankDistances(DM, ip.Results.rankdistances);
