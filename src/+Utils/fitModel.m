function [mdl, scale] = fitModel(X, Y, ip, gamma, C)
%-------------------------------------------------------------------
% [mdl, scale] = fitModel(X, Y, ip, gamma, C)
% ------------------------------------------------------------------
%
% Given the classifier and training data specified in another 
% function, this function returns a classifcation model.  The output object 
% mdl is to be passed into the predict stage.  The purpose of this class is 
% to provide a unified interface towards training a model, because the 
% function calls to the different classifiers (SVM, RF, and LDA etc) are 
% all different.
% 
% INPUT ARGS:
%   - X: 2D trial by feature training data matrix
%   - Y: label vector
%   - ip: input parser parameters from classification function
%   - gamma: Hyperparameter for SVM classifications
%   - C: Hyperparameter for SVM classifications
%
% OUTPUT ARGS:
%   - mdl: an object that contains the classification model
%   - scale: If classifier is SVM, this output is a struct specifying that 
%       scaling was performed and also stores the shift and scale 
%       parameters. For LDA and RF classifiers, scale is NaN. 
  
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

    switch upper(ip.Results.classifier)
        case 'SVM'
            [rx cx] = size(X);
            [ry cy] = size(Y);
            if (cy> ry)
                Y = Y';
            end
            
            % data scaling
            [xScaled, shift1, shift2, scaleFactor] = Utils.scaleDataInRange(X, [-1,1]);
            X = xScaled;
            scale = struct();
            scale.needScale = 1;
            scale.shift1 = shift1;
            scale.shift2 = shift2;
            scale.scaleFactor = scaleFactor;
            
%             gamma = ip.Results.gamma;
%             C = ip.Results.C;         
            
            switch ip.Results.kernel
                case 'linear'
                    kernelNum = 0;
                case 'polynomial'
                    kernelNum = 1;
                case 'rbf'
                    kernelNum = 2;
                case 'sigmoid'
                    kernelNum = 3;
            end
            
            
            %%%%%%%%%%%%%
            % Formatting hyperparameter input to libsvm
            %%%%%%%%%%%%%
            
            % SVM kernel
            kernel_input = ['-t ' num2str(kernelNum) ' '];
            
            % SVM class weights
            % figure
            h = histogram(Y, 'BinMethod', 'integers');
            hw = h.Values(1) ./ h.Values ;
            clf
            close
            nw  = length(hw);
            weights = [' -q '];
            for i = 1:nw
                weights = [weights '-w' num2str(i) ' ' num2str(hw(i)) ' '];
            end
            
            % SVM gamma hyperparameter
            gamma_input = 0;
            if ( ischar(gamma) )
                if ( strcmp(gamma, 'default') )
                    gamma_input = '';
                end
            else
                gamma_input = [' -g ' num2str(gamma, '%.20f\n')];
            end
            
            % C hyperparameter
            C_input = [' -c ' num2str(C, '%.20f\n')];
            %mdl = svmtrain(Y, X, ['-t ' num2str(kernelNum) ' -q ' weights  ' -c ' num2str(1000000000)] );
            mdl = svmtrain(Y, X, [kernel_input weights gamma_input C_input]);           
        case 'LDA'
            mdl = fitcdiscr(X, Y', 'DiscrimType', 'diagLinear');
            scale = NaN;
            
        case 'RF'
            mdl = TreeBagger(ip.Results.numTrees, X, Y, ...
                'OOBPrediction', 'on', 'minLeafSize', ip.Results.minLeafSize);
%             mdl = fitcensemble(X, Y, 'OptimizeHyperparameters','auto');
            scale = NaN;

    end
    

end