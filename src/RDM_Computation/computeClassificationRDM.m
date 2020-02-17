function [RDM, params] = computeClassificationRDM(M, matrixType, varargin)
%-------------------------------------------------------------------
% [RDM, params] = computeClassificationRDM(M, matrixType, varargin)
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
% M -- A square matrix, assumed to be a multicategory confusion matrix or 
%   matrix of pairwise accuraciues.
%
% matrixType -- String specifying the type of input matrix.
%   - Enter 'CM' if inputting a multicategory confusion matrix.
%   - Enter 'pairs' if inputting a matrix of pairwise accuracies.
%
% OPTIONAL NAME-VALUE PAIRS
% 'normalize' -- 'diagonal', 'sum', 'subtractPointFive', 'none'
%   Matrix normalization refers to dividing or subtracting each element of 
%   the matrix.
%   --- options ---
%   'diagonal' (default for matrixType 'CM') - divide each matrix element
%       by the diagonal value in the respective row. This produces self-
%       similarity of one. If any element along the diagonal is zero, the 
%       function will print a warning and attempt 'sum' normalization 
%       instead.
%   'sum' - divide each matrix element by the sum of the respective row.
%       For confusion matrices with actual labels as rows and predicted 
%       labels as columns, this procedure computes the estimated
%       conditional probabilities P(predicted|actual) (Shepard, 1958). If
%       the sum of any row is zero, the function will print an error and
%       exit.
%   'subtractPointFive' (default for matrixType 'pairs') - subtract 0.5
%       from each matrix element. For pairwise accuracies, this provides a
%       unitless measure of distance with expected level (at chance-level
%       classification) of zero. 
%   'none' - perform no normalization of the matrix.
%   --- notes ---
%   - For matrixType 'CM', the default normalization is 'diagonal', but
%       'sum', and 'none' can also be specified. If 'subtractPointFive' is 
%       specified, the function will print a warning and override it with 
%       'none'. Users should use caution if calling 'diagonal' or 'sum' on 
%       confusion matrices matrices whose diagonals are undefined or 
%       contain zeros.
%   - For matrixType 'pairs', the default specification is
%       'subtractPointFive', but 'none' can also be specified. If 
%       'diagonal' or 'sum' is specified with this input type, the function 
%       will override it with 'none' and print a warning.
%
% 'symmetrize' -- 'arithmetic', 'geometric', 'harmonic', 'none'
%   Symmetrizing the matrix ensures that the the distance between i,j
%   equals the distance between j,i by computing the arithmetic, geometric,
%   or harmonic mean of the matrix and its transpose. Any
%   zeros on the diagonal will be converted to NaNs; aside from this, if
%   an already symmetric matrix is input to the function, the output will
%   be the same as the input.
%   - For 'similarity' AND 'distance' input matrix M, the default is
%     'arithmetic', but any of the four options may be specified.
%
% 'distance' -- 'linear', 'power', 'logarithmic', 'none'
%   The distance option converts similarities to distances through linear
%   (D = 1 - S), power (D = 1 - S.^distpower), or logarithmic
%   D = log2(distPower*M + 1) ./ log2(distPower + 1) operations.
%   Similarities are assumed to already be in the range of -1 to 1 (or 0
%   to 1 for non-negative distances only).
%   - For 'similarity' input matrix M, the default is 'linear', but any
%     of the four options may be specified.
%   - For 'distance' input matrix M, the default is 'none' since the data
%     are assumed to be already in distance space. If any other option is
%     specified, the functino will override it with 'none' and print a
%     warning.
%
% 'distpower' -- Integer > 0 (if using 'power' or 'log' distance)
%   Distpower is used in the 'power' and 'logarithmic' options of the
%   distance computations.
%   - For 'similarity' input matrix M, the default value is 1. This
%     parameter applies only to 'power' and 'logarithmic' distance
%     specifications; in these cases, if the parameter is not a positive
%     integer, the function will override it with 1 and issue a warning.
%   - For 'distance' input matrix M, this input is ignored since no
%     distance computations can be performed.
%
% 'rankdistances' -- 'none', 'rank', 'percentrank'
%   The distances of an RDM are sometimes transformed to ranks or
%   percentile ranks for visualizing the data.
%   - For 'similarity' AND 'distance' input matrices M, the default is
%     'none'. If 'rank' or 'percentrank' are specified but the input matrix
%     is not symmetric, the subfunction will issue a warning and operate
%     only on the lower triangle of the matrix, returning a symmetric
%     matrix.
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
% - Shepard RN. Stimulus and response generalization: Tests of a model 
%   relating generalization to dis- tance in psychological space. Journal 
%   of Experimental Psychology. 1958; 55(6):509?523. doi: 10.1037/h0042354

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

if nargin < 2
    error('Must input at least a matrix M and similarity/distance specification.');
end
matrixType = lower(matrixType); % Convert to lowercase

% Specify input parser parameters based in similarity or distance
if any(strcmp(matrixType, {'d', 'dist', 'distance'}))
    disp('Operating on input distance matrix.')
    defaultNormalize = 'subtractPointFive';
    defaultSymmetrize = 'arithmetic';
    defaultDistance = 'none';
elseif any(strcmp(matrixType, {'s', 'sim', 'similarity'}))
    disp('Operating on input similarity matrix.')
    defaultNormalize = 'diagonal';
    defaultSymmetrize = 'arithmetic';
    defaultDistance = 'linear';
else
    error(['Specified matrix type is not in the allowable set of values. '...
        'See function documentation for more information.'])
end
% Here are the parameters that are the same for similarity and distance
defaultDistpower = 1;
defaultRankdistances = 'none';

% Specify expected values
expectedMatrixType = {'d', 'dist', 'distance',...
    's', 'sim', 'similarity'};
expectedNormalize = {'diagonal', 'sum', 'subtractPointFive', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};

% Required inputs
addRequired(ip, 'M', @isnumeric)
addRequired(ip, 'matrixType',...
    @(x) any(validatestring(x, expectedMatrixType)))

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
parse(ip, M, matrixType, varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End input parser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify the confusion matrix is square
if size(M, 1) ~= size (M, 2)
    error('The input matrix M should be square.')
end

disp('Computing distance matrix...')

% Initialize the 'params' output
params.normalize = ip.Results.normalize;
params.symmetrize = ip.Results.symmetrize;
params.distance = ip.Results.distance;
params.distpower = ip.Results.distpower;
params.rankdistances = ip.Results.rankdistances;

% Verify inappropriate parms not specified with 'distance' input matrix
if any(strcmp(matrixType, {'d', 'dist', 'distance'}))
    % Check: 'normalize' should NOT be 'diagonal' or 'sum'
    if any(strcmp(params.normalize, {'diagonal', 'sum'}))
        warning(['Normalize was specified as ''' params.normalize ''' but '...
            'must be set to ''subtractPointFive'' or ''none'' for ''distance'' input matrix. '...
            'Overriding user input and setting to ''none''.'])
        params.normalize = 'none';
    end
    % Check: 'distance' can only be 'none'
    if ~strcmp(params.distance, 'none')
        warning(['Distance was specified as ''' params.distance ''' but '...
            'must be set to ''none'' for ''distance'' input matrix. Overriding '...
            'user input and setting to ''none''.'])
        params.distance = 'none';
    end
end
% Verify inappropriate parms not specified with 'similarity' input matrix
if any(strcmp(matrixType, {'s', 'sim', 'similarity'}))
    % Check: 'normalize' should NOT be 'subtractPointFive'
    if strcmp(params.normalize, 'subtractPointFive')
        warning(['Normalize was specified as ''' params.normalize ''' but '...
            'this specification cannot be used for ''similarity'' input matrix. '...
            'Overriding user input and setting to ''none''.'])
        params.normalize = 'none';
    end
end

% NORMALIZE
NM = normalizeMatrix(M, params.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, params.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, params.distance, params.distpower);

% RANKDISTANCES
RDM = rankDistances(DM, params.rankdistances);


