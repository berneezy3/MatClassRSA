function [RDM, params] = computeClassificationRDM(M, varargin)
%-------------------------------------------------------------------
% [RDM, params] = computeClassification_RDM(M, varargin)
% ------------------------------------------------
% Blair - January 31, 2017, revised July 2019
%
% [RDM, params] = computeClassification_RDM(M, varargin) converts
% classifier output (multicategory confusion matrix or matrix of pairwise
% accuracies) into an RDM.
%
% Required inputs:
% - M: A square confusion matrix or matrix of pairwise accuracies.
% - matrixType: String specifying the type of input matrix. 
%   - Enter 'p', 'pair', 'pairs', or 'pairwise' if inputting a matrix of 
%     pairwise accuracies (values between 0 and 1.0).
%   - Enter 'm', 'multi', 'multiclass', or 'multicategory' if inputting a
%     confusion matrix from multicategory classification.
%
% Optional name-value pairs:
% - 'normalize': 'diagonal', 'sum', 'none'
%   - For 'multiclass' input matrix M, the default is 'diagonal', but any
%     of the three options may be specified.
%   - For 'pairwise' input matrix M, the default and only specification is 
%     'none'. If 'diagonal' and 'sum' is specified with this input type,
%     the function will override it with 'none' and print a warning.
% - 'symmetrize': 'arithmetic', 'geometric', 'harmonic', 'none'
%   - For 'multiclass' input matrix M, the default is 
% - 'distance': 'linear' (default), 'power', 'logarithmic', 'none'
% - 'distpower': Integer > 0 (if using 'power' or 'log' distance)
% - 'rankdistances': 'none' (default), 'rank', 'percentrank'
%
% Outputs:
% - RDM: The Representational Dissimilarity (distance) Matrix. RDM is a
%   square matrix of the same size as the input variable CM.
% - params: RDM computation parameters. It is a struct whose fields specify
%   normalization, symmetrization, distance computation, and distance
%   ranking.
%
% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers: 
%   https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers

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
parse(ip, M, varargin{:});

% Verify the confusion matrix is square
if size(M, 1) ~= size (M, 2)
    error('The input confusion matrix should be square.')
end

disp('Computing distance matrix...')

% NORMALIZE
NM = normalizeMatrix(M, ip.Results.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, ip.Results.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, ip.Results.distance, ip.Results.distpower);

% RANKDISTANCES
RDM = rankDistances(DM, ip.Results.rankdistances);

% params
params.normaliize = ip.Results.normalize;
params.symmetrize = ip.Results.symmetrize;
params.distance = ip.Results.distance;
params.distpower = ip.Results.distpower;
params.rankdistances = ip.Results.rankdistances;
