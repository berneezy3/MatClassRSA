function [RDM, params] = convertConfusionMatrixToRDM(obj, M, varargin)
%-------------------------------------------------------------------
% RSA = MatClassRSA;
% [RDM, params] = RSA.computeRDM.computeClassificationRDM(M, varargin)
% ------------------------------------------------------------------
% Blair - January 31, 2017, revised September 2019
%
% [RDM, params] = transformAndScaleMatrix(M, matrixType, varargin)
% transforms and scales generalized proximity matrices (e.g., multicategory
% confusion matrix, matrix of pairwise classifier accuracies, RDMs).
%
% NOTE: The default specifications of this function are based upon the
% matrices that are output by MatClassRSA classificationfunctions:
% Multicategory confusion matrices as similarity matrices, and matrices of
% pairwise accuracies as distance matrices. However, this function can be
% used on other types of proximity matrices as well (e.g., matrices of
% similarity ratings, or un-ranked RDMs). See the MatClassRSA manual for
% more information and examples.
%
% REQUIRED INPUTS
% M -- A square matrix, typically thought to be a confusion matrix but 
%   could also be a matrix of correlations or other distances if using 
%   custom name-value specifications. If inputting a confusion matrix, the
%   matrix should be oriented so that rows represent actual labels and
%   columns represent predicted labels (e.g., element (3, 1) denotes the
%   number of observations actually from class 3 that were predicted to be
%   from class 1.
%
% OPTIONAL NAME-VALUE PAIRS
% 'normalize' -- 'diagonal' (default), 'sum', 'none'
%   Matrix normalization refers to dividing each element of the matrix by 
%   some value.
%   --- options ---
%   'diagonal' (default) - divide each matrix element
%       by the diagonal value in the respective row. For confusion 
%       matrices, this produces self-similarity of one (Shepard, 1958a). 
%       If any element along the diagonal is zero, this option will 
%       introduce NaNs in the output; thus the function will print a 
%       warning and advise the user to use 'sum' instead.
%   'sum' - divide each matrix element by the sum of the respective row.
%       For confusion matrices with actual labels as rows and predicted 
%       labels as columns, this procedure computes the estimated
%       conditional probabilities P(predicted|actual) (Shepard, 1958b). If
%       the sum of any row is zero, the normalization subfunction will 
%       print a warning and the outputs of all elements in those rows will
%       be zeros.
%   'none' - perform no normalization of the matrix. 
%
% 'symmetrize' -- 'arithmetic' (default), 'geometric', 'harmonic', 'none'
%   Symmetrizing the matrix ensures that the the distance between i,j
%   equals the distance between j,i by computing the arithmetic, geometric,
%   or harmonic mean of the matrix and its transpose. If computing the 
%   harmonic mean, any zeros on the diagonal will be converted to NaNs, and 
%   the symmetrize subfunction will print a warning.
%
% 'distance' -- 'linear' (default), 'power', 'logarithmic', 'none'
%   The distance option converts similarities to distances through linear
%   (D = 1 - S), power (D = 1 - S.^distpower), or logarithmic
%   D = log2(distPower*M + 1) ./ log2(distPower + 1) operations.
%   Similarities are assumed to already be in the range of -1 to 1 (or 0
%   to 1 for non-negative distances only).
%
TODO IS THIS A NAME-VALUE PAIR OR A VALUE?
% 'distpower' -- Integer > 0 (if using 'power' or 'log' distance)
%   Distpower is used in the 'power' and 'logarithmic' options of the
%   distance computations. The default value is 1. This parameter applies 
%   only to 'power' and 'logarithmic' distance specifications; in these 
%   cases, if the parameter is not a positive integer, the function will 
%   override it with 1 and issue a warning.
%
% 'rankdistances' -- 'none' (default), 'rank', 'percentrank'
%   The distances of an RDM are sometimes transformed to ranks or
%   percentile ranks for visualizing the data. The default is 'none'. If 
%   'rank' or 'percentrank' are specified but the input matrix is not 
%   symmetric, the subfunction will issue a warning and operate only on 
%   the lower triangle of the matrix, returning a symmetric matrix.
%
% OUTPUTS
% RDM -- The Representational Dissimilarity (distance) Matrix. RDM is a
%   square matrix of the same size as the input matrix M.
%
% params -- RDM computation parameters. It is a struct whose fields specify
%   normalization, symmetrization, distance measure, distance power, and
%   ranking of distances.

% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers:
%   https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers
% - Shepard RN (1958a). Stimulus and response generalization: Deduction of 
%   the generalization gradient from a trace model. Psychological Review 
%   65(4):242?256. doi: 10.1037/h0043083
% - Shepard RN (1958b). Stimulus and response generalization: Tests of a 
%   model relating generalization to dis- tance in psychological space. 
%   Journal of Experimental Psychology 55(6):509?523. doi: 10.1037/h0042354

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin input parser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the input parser
ip = inputParser;
ip.CaseSensitive = false;

if nargin < 1
    error('Function requires at least one input: Square confusion matrix.');
end
matrixType = lower(matrixType); % Convert to lowercase

% Specify input parser defaults
defaultNormalize = 'diagonal';
defaultSymmetrize = 'arithmetic';
defaultDistance = 'linear';
defaultDistpower = 1;
defaultRankdistances = 'none';

% Specify expected values
expectedNormalize = {'diagonal', 'sum', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};

% Required inputs
addRequired(ip, 'M', @isnumeric)

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
    addParamValue(ip, 'distpower', defaultDistpower,...
        @(x) floor(x)==x);
else
    addParameter(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParameter(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParameter(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParameter(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
    addParameter(ip, 'distpower', defaultDistpower,...
        @(x) floor(x)==x);
end

% Parse
parse(ip, M, varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End input parser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify the confusion matrix is square
if size(M, 1) ~= size (M, 2)
    error('The input confusion matrix should be square.')
end

disp('Computing RDM...')

% Initialize the 'params' output
params.normalize = ip.Results.normalize;
params.symmetrize = ip.Results.symmetrize;
params.distance = ip.Results.distance;
params.distpower = ip.Results.distpower;
params.rankdistances = ip.Results.rankdistances;

% NORMALIZE
NM = normalizeMatrix(M, params.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, params.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, params.distance, params.distpower);

% RANKDISTANCES
RDM = rankDistances(DM, params.rankdistances);


