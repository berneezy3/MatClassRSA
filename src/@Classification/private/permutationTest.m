function y = permutationTest(M, Y, perms)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% y = permutationTest(M, P)
% --------------------------------
% Bernard Wang, Sept 16, 2020
%
% The function for conducting permutation tests on previous classification 
% determine the statistical significance of the results.  More info on
% permutation testing can be found here:
%
%
% INPUT ARGS (REQUIRED)
%   M - Classification model(s)
%   Y - labels
%   perms - number of permutations.  Default 200.  
%   
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'timeUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the time dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       time dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.

%
%
% OUTPUT ARGS 
%   C - output object containing all cross validation related
%   information, including confucion matrix, accuracy, prediction results
%   etc.  The structure of C will differ depending on the value of the 
%   input value 'pairwise', which is set to 0 by default.  if 'pairwise' 
%   is set to 1, then C will be a cell matrix of structs, symmetrical along 
%   the diagonal.  If pairwise is 0, then C is a struct containing values:
%   
%   CM - Confusion matrix that summarizes the performance of the
%       classification, in which rows represent actual labels and columns
%       represent predicted labels.  Element i,j represents the number of 
%       observations belonging to class i that the classifier labeled as
%       belonging to class j.
%   accuracy - Classification accuracy
%   predY - predicted label vector
%   modelsConcat - Struct containing the N models used during cross
%   validation.
%
% This function is used to conduct a permutation test of a prior
% classification.  The purpose of this test is to compute the statistical
% significance of the thing.  
%
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

    
    

    
    for i = 1:perms
        
    end





end