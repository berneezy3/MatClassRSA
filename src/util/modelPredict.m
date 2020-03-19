function [predictions decision_values] = modelPredict(X, mdl, scale)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% modelPredict(X, mdl)
% --------------------------------
% Bernard Wang, Sept 28, 2019
%
% This function takes a classification produced by fitModel(), and predicts
% the labels of newly passed in data.
% 
% INPUT ARGS:
%   - X: 2D trial by feature test data matrix
%   - mdl: output obejct from fitModel()
%
% OUTPUT ARGS:
%   - predictions: predicted values of 
%   - decision_values: decision values are returned if SVM is the
%   classifier
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
    classifier = class(mdl);
    decision_values = NaN;
    
    switch classifier
        case 'struct'  %libsvm
            [r c] = size(X);
            Y = round(rand(r,1)*6);
%             if (isstruct(scale))
%                 X = scaleDataShiftDivide(X, scale.shift1, scale.shift2, scale.scaleFactor);
%             end
            
            [predictions, ~, decision_values] = svmpredict(Y, X, mdl, ['-q']);
            
            % handle ties
            for i=1:r
                [indOfWinner tallies tie] = SVMhandleties(decision_values(i, :), mdl.Label');
                if (tie ~= 0)
%                     disp(['libsvm''s winner: ' num2str(predictions(i)) ', bernard''s tie broken winner: ' num2str(mdl.Label(indOfWinner))]);
%                     disp(['label order: ' num2str(mdl.Label')]);
                    predictions(i) = mdl.Label(indOfWinner);
                end
            end
            
            % implement pairwise
            %pairwiseMat = cell(1, length(decision_values));
            pairwiseMat = zeros(2,2, length(decision_values));
            
            
            predictions = predictions';
        case 'ClassificationECOC' % multi-class SVM
            [r c] = size(X);
            [predictions, score] = predict(mdl, X);
            predictions = predictions';
        case 'ClassificationDiscriminant'
            predictions = predict(mdl,X);
            predictions = predictions(:,end);
            predictions = predictions';
        case 'TreeBagger'
            predictions = predict(mdl,X);
            [rows, cols] = size(predictions);
            predictions = str2num(cell2mat(predictions));
            if (rows>cols)
                predictions = reshape(predictions,[cols rows]);
            end
        otherwise
            error(['mdl must be of class struct, ClassificationDiscriminant ' ...
                'or TreeBagger']);
    end
    
end