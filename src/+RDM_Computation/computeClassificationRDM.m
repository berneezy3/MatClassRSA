function [RDM, params] = computeClassificationRDM(M, varargin)
%-------------------------------------------------------------------
% [RDM, params] = RDM_Computation.computeClassificationRDM(M, varargin)
% ------------------------------------------------------------------
% Blair - January 31, 2017, revised September 2019; Ray - revised April
% 2024
%
% This function transforms and scales a generalized square proximity 
%   matrix. The default specifications assume a square multicategory 
%   confusion matrix as input, but the function can be used on other types 
%   of square proximity matrices as well (e.g., matrices of pairwise 
%   similarity ratings, or un-ranked RDMs). See the MatClassRSA manual for 
%   more information and examples.
%
% REQUIRED INPUTS
% M -- A square matrix, typically thought to be a multicategory confusion 
%   matrix but could also be a matrix of e.g., pairwise correlations or 
%   distances if using custom name-value input specifications. If inputting 
%   a confusion matrix, the matrix should be arranged such that rows 
%   represent actual labels and columns represent predicted labels (e.g., 
%   element (3, 1) denotes the number of observations actually from class 3 
%   that were predicted to be from class 1) -- this is the orientation 
%   output by the MatClassRSA classification functions.
%
% OPTIONAL NAME-VALUE PAIRS
% 'normalize' -- 'sum' (default), 'diagonal', 'none'
%   Matrix normalization refers to dividing each element of the matrix by 
%   some value.
%   --- options ---
%   'sum' (default) - divide each matrix element by the sum of the 
%       respective row, so that each row sums to 1. Assuming that confusion 
%       matrices arrange actual labels as rows and predicted labels as 
%       columns, this procedure computes the estimated conditional 
%       probabilities: P(predicted|actual) (Shepard, 1958b). 
%       NOTE: If the sum of any row is zero, the normalization subfunction 
%       will print a warning and the outputs of all elements in those rows 
%       will be zeros (not NaNs).
%   'diagonal' - divide each matrix element by the diagonal value 
%       in the respective row. For confusion matrices, this produces 
%       self-similarity of one (Shepard, 1958a). 
%       NOTE: If any element along the diagonal is zero, this option will 
%       introduce NaNs in the output; in this case the normalization 
%       subfunction will issue an error and advise the user to use 'sum' 
%       normalization instead.
%       NOTE: If any off-diagonal element in a matrix row exceeds the
%       diagonal value in that row (which would produce off-diagonal values
%       greater than 1 after normalization), the the function will print a
%       warning and advise the suer to use 'sum' normalization instead.
%   'none' - do not perform any normalization of the matrix. 
%
% 'symmetrize' -- 'arithmetic' (default), 'geometric', 'harmonic', 'none'
%   Symmetrizing the matrix ensures that the the distance between i,j
%   equals the distance between j,i. There are options to compute 
%   the arithmetic, geometric, or harmonic mean of the input matrix and its 
%   transpose. 
%   --- options ---
%   'arithmetic' (default) - for input matrix M, compute (M + M.') / 2.
%   'geometric' - for input matrix M, compute sqrt(M .* M.').
%   'harmonic' - for input matrix M, compute 2 * M .* M.' ./ (M + M.'). 
%       NOTE: In this case, any zeros on the diagonal will be converted to 
%       NaNs, and the symmetrize subfunction will print a warning.
%   'none' - do not symmetrize the matrix (e.g., if the input is already
%       symmetric).
%
% 'distance' -- 'linear' (default), 'power', 'logarithmic', 'none'
%   The distance option converts similarities to distances. Similarities 
%   are assumed to already be in the range of -1 to 1 (or 0 to 1 for non-
%   negative distances only).
%   --- options ---
%   'linear' (default) - computes distance D = 1 - S.
%   'power' - computes distance D = 1 - S.^distpower (see below for 
%       specification of distpower).
%   'logarithmic' - computes distance 
%       D = log2(distPower*M + 1) ./ log2(distPower + 1) (see below for
%       specification of distpower).
%   'pairwise' - computed distace D = 0.5(chance) - S.
%   
% 'distpower' -- Integer > 0 (default 1)
%   Distpower is used in the 'power' and 'logarithmic' options of the
%   distance computations (see above). The default value is 1. If the 
%   parameter is not input as a positive integer, the function will 
%   override it with 1 and issue a warning.
%
% 'rankdistances' -- 'none' (default), 'rank', 'percentrank'
%   The distances of an RDM are sometimes transformed to ranks or
%   percentile ranks for visualizing the data. MatClassRSA rank operations
%   assume a symmetric input matrix, and operate on the lower triangle of
%   the input (not including the diagonal).
%   --- options ---
%   'none' (default) - do not rank the matrix elements. 
%   'rank' - return the ranked values, adjusted for ties. If the input 
%       matrix is not symmetric, the subfunction will issue a warning and 
%       operate only on the lower triangle of the matrix, returning a 
%       symmetric matrix.
%   'percentrank' - return the ranked distances, adjusted for ties and 
%       divided by the number of unique pairs represented in the matrix 
%       (i.e., the number of elements in the lower triangle of the matrix,
%       excluding the diagonal). If the input matrix is not symmetric, the 
%       subfunction will issue a warning and operate only on the lower 
%       triangle of the matrix, returning a symmetric matrix.
%
%  'matrixtype' - 'auto' (default), 'cm', 'pairwise'
%   typically thought to be a multicategory confusion 
%   Input matrix could be a confusion matrix or a matrix of pairwise 
%   correlations. The script will default to autodetect which matrix type
%   is being used. The user may override this autodection, by
%   explicitly specifying the matrixType.
%   --- options ---
%   'auto' (default) - autodetect matrix type, by destinguishing between 
%   whole number and non-whole number containing matrices.
%   'cm' - to specify input matrix is a confusion matrix of observations
%   'pairwise' - to specify input matrix is a matrix of pairwise accuracies
%
% OUTPUTS
% RDM -- The Representational Dissimilarity (distance) Matrix. RDM is a
%   square matrix of the same size as the input matrix M.
%
% params -- RDM computation parameters. It is a struct whose fields contain
%   the normalization, symmetrization, distance measure, distance power, 
%   and ranking specifications.

% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers:
%   https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers
% - Shepard RN (1958a). Stimulus and response generalization: Deduction of 
%   the generalization gradient from a trace model. Psychological Review 
%   65(4):242?256. doi: 10.1037/h0043083
% - Shepard RN (1958b). Stimulus and response generalization: Tests of a 
%   model relating generalization to distance in psychological space. 
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

% Specify input parser defaults
defaultNormalize = 'sum';
defaultSymmetrize = 'arithmetic';
defaultDistance = 'linear';
defaultDistpower = 1;
defaultRankdistances = 'none';
defaultMatrixtype = 'auto';

% Specify expected values
expectedNormalize = {'diagonal', 'sum', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};
expectedMatrixtype = {'auto', 'cm', 'pairwise'};

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
    addParamValue(ip, 'matrixtype', defaultMatrixtype,...
        @(x) any(validatestring(x, expectedMatrixtype)));
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
    addParameter(ip, 'matrixtype', defaultMatrixtype,...
        @(x) any(validatestring(x, expectedMatrixtype)));
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
params.matrixtype = ip.Results.matrixtype;

if ip.Results.matrixtype == 'auto'
    isPairwise = any(mod(M(:), 1) ~= 0);

elseif ip.Results.matrixtype == 'pairwise'
    isPairwise = true;

elseif ip.Results.matrixtype == 'cm'
    isPairwise = false;   
end

if isPairwise
    RDM_Computation.shiftPairwiseAccuracy(M)
    params.matrixtype = 'pairwise';
else
    RDM_Computation.computeCMRDM(M, ip.Results)
    params.matrixtype = 'cm';
end


