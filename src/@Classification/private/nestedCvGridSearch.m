function [gamma_opt, C_opt] = nestedCvGridSearch(X, Y, gammas, Cs, kernel)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2020.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% mdl = gridSearch(X, Y, gammaRange, cRange)
% --------------------------------
% Bernard Wang, April 5, 2020
%
% Given training data matrix X, label vector Y, and a vector of gamma's 
% and C's to search over, this function runs cross validation over a grid 
% of all possible combinations of gammas and C's.
% 
% INPUT ARGS:
%   - gammas: 2D trial by feature training data matrix
%   - Cs: label vector
%   - kernel:  SVM classification kernel
%
% OUTPUT ARGS:
%   - gamma_opt: gamma value that produces the highest cross validation
%   accuracy
%   - C_opt: C value that produces that highest cross validation accuracy
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

    accGrid = zeros(length(Cs), length(gammas));
    cGrid = cell(length(Cs), length(gammas));

    RSA = MatClassRSA;
    for i = 1:length(Cs)
        for j = 1:length(gammas)
            tempC = RSA.Classification.crossValidateMulti(X, Y, 'PCA', -1, ...
                'classifier', 'SVM','C', Cs(i), 'gamma', gammas(j), 'kernel', kernel);
            accGrid(i,j) = tempC.accuracy;
            cGrid{i,j} = tempC;
        end
    end
    
    % get maximum accuracy, and return the gamma and C value for the
    % maximum accuracy
    
    
    [maxVal, maxIdx] = max(accGrid(:));
    [xInd yInd] = ind2sub(size(accGrid), maxIdx);
    
    gamma_opt = gammas(yInd);
    C_opt = Cs(xInd);
    

end