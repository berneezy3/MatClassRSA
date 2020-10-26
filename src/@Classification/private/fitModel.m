function [mdl, scale] = fitModel(X, Y, ip, gamma, C)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% mdl = fitModel(X, Y, ip)
% --------------------------------
% Bernard Wang, Sept 28, 2019
%
% Given the classifier and training data specified in classifyCrossValidate(), 
% fitModel() of returns a classifcation model.  The output object mdl is to
% be passed into modelPredict.  The purpose of this class is to provide a
% unified interface towards training a model, because the function calls to 
% the different classifiers (SVM, RF, and LDA etc) are all different.
% 
% INPUT ARGS:
%   - X: 2D trial by feature training data matrix
%   - Y: label vector
%   - ip: input parser parameters from classifyCrossValidate()
%
% OUTPUT ARGS:
%   - mdl: an object that contains the classification model
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

    switch upper(ip.Results.classifier)
        case 'SVM'
            [rx cx] = size(X);
            [ry cy] = size(Y);
            if (cy> ry)
                Y = Y';
            end
            
            % data scaling
            [xScaled, shift1, shift2, scaleFactor] = scaleDataInRange(X, [-1,1]);
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
            %figure
            h = histogram(Y, 'BinMethod', 'integers');
            hw = h.Values(1) ./ h.Values ;
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
            mdl = fitcdiscr(X, Y', 'DiscrimType', 'linear');
            scale = NaN;
            
        case 'RF'
            mdl = TreeBagger(ip.Results.numTrees, X, Y, ...
                'OOBPrediction', 'on', 'minLeafSize', ip.Results.minLeafSize);
%             mdl = fitcensemble(X, Y, 'OptimizeHyperparameters','auto');
            scale = NaN;

    end
    

end

