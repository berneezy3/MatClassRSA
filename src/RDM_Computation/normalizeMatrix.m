function xOut = normalizeMatrix(xIn, normType)
%-------------------------------------------------------------------
% xOut = normalizeMatrix(xIn, normType)
% --------------------------------------------------------
% Blair - February 22, 2017
%
% This function normalizes a matrix by dividing each row by either its sum,
% or the value on the diagonal. 
%
% This function is most useful for multi-category confusion 
% matrices, where self-similarity is not already assumed (in contrast to 
% correlation matrices, where self-similarity is always 1; or matrices of 
% pairwise classifier accuracies, where it is undefined). In the case of 
% multi-category confusion matrices, rows are assumed to represent actual 
% labels, and columns predicted labels (as output by the classifyEEG 
% function).
%
% Inputs: 
% - xIn: The square input matrix (need not be symmetric).
% - normType: 
%   - Diagonal ('diagonal', 'diag', 'd'): This procedure divides each
%       matrix element by the respective diagonal entry of its row (e.g.,
%       all elements of Row 1 are divided by element (1,1); all elements of
%       Row 2 are divided by element (2,2); etc.). This brings about
%       self-similarity of 1 for each stimulus category (row). See Shepard
%       (1958a) for more information.
%   - Sum ('sum', 's'): This procedure divides each matrix element by the
%       sum of its respective row. As a result, each row will sum to 1 and
%       the values of the matrix can be treated as estimated conditional
%       probabilities: X_ij = P(predicted=j | actual=i). See Shepard 
%       (1958b) for further discussion.
%   - None ('none', 'n'): Perform no normalization of the matrix.
%
% There is no default normalization approach, as normalization type is
% assumed to be decided prior to calling this function. If none of the
% above normType options are specified, the function returns an error. 
% Currently if the divisor is zero, the function returns an error and it 
% is up to the user to adjust the input matrix.
%
% Output: 
% - xOut: The normalized matrix (same size as the input matrix).
%
% References:
% Shepard RN. Stimulus and response generalization: Deduction of the 
%   generalization gradient from a trace model. Psychological Review. 
%   1958a; 65(4):242?256. doi: 10.1037/h0043083 PMID: 13579092
%
% Shepard RN. Stimulus and response generalization: Tests of a model 
%   relating generalization to dis- tance in psychological space. Journal of 
%   Experimental Psychology. 1958b; 55(6):509?523. doi: 10.1037/ h0042354 
%   PMID: 13563763

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

normType = lower(normType);

switch normType
    case {'diagonal', 'diag', 'd'}
        disp('Normalize: diagonal')
        if ismember(0, diag(xIn))
            error('Cannot divide by zero on the diagonal.')
        else
            xOut = xIn ./ repmat(diag(xIn), 1, size(xIn, 2));
        end
    case {'sum', 's'}
        disp('Normalize: sum')
        if ismember(0, sum(xIn, 2))
            error('Cannot divide by zero row sum.')
        else
            xOut = xIn ./ repmat(sum(xIn, 2), 1, size(xIn, 2));
        end
    case {'none', 'n'}
        disp('Normalize: none')
        xOut = xIn;
    otherwise
        error('Normalize type not recognized.')
end