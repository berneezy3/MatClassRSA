function [predictions, decision_values] = modelPredict(X, mdl, scale)
% [predictions, decision_values] = modelPredict(X, mdl, scale)
%-------------------------------------------------------------------
%
% This function takes a classification produced by fitModel(), and predicts
% the labels of newly passed in data.
% 
% INPUT ARGS:
%   - X: 2D trial by feature test data matrix
%   - mdl: output obejct from fitModel()
%   - scale: shift and scale factors for libsvm
%
% OUTPUT ARGS:
%   - predictions: predicted labels
%   - decision_values: decision values are returned if SVM is the
%   classifier

% This software is released under the MIT License, as follows:
%
% Copyright (c) 2025 Bernard C. Wang, Raymond Gifford, Nathan C. L. Kong, 
% Feng Ruan, Anthony M. Norcia, and Blair Kaneshiro.
% 
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files (the 
% "Software"), to deal in the Software without restriction, including 
% without limitation the rights to use, copy, modify, merge, publish, 
% distribute, sublicense, and/or sell copies of the Software, and to 
% permit persons to whom the Software is furnished to do so, subject to 
% the following conditions:
% 
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    classifier = class(mdl);
    decision_values = NaN;
    
    switch classifier
        case 'struct'  %libsvm
            [r c] = size(X);
            Y = round(rand(r,1)*6);
            if (isstruct(scale))
                X = Utils.scaleDataShiftDivide(X, scale.shift1, scale.shift2, scale.scaleFactor);
            end
            
            [predictions, ~, decision_values] = svmpredict(Y, X, mdl, ['-q']);
            
            % handle ties
            for i=1:r
                [indOfWinner, tallies, tie] = Utils.SVMhandleties(decision_values(i, :), mdl.Label');
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