function mdl = fitModel(X, Y, classifier, ip)
%-------------------------------------------------------------------

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

    switch classifier
        case 'SVM'
            Y = Y';
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
            currpath = pwd;
            [libsvmpath,name,ext] = fileparts(which('matlab/svmtrain'));
            cd(libsvmpath);
            [funcOutput mdl] = evalc('svmtrain(Y, X, [''-t '' num2str(kernelNum)])');
            cd(currpath);
            
        case 'LDA'

            mdl = fitcdiscr(X, Y, 'DiscrimType', 'linaer'); 
            
            
        case 'RF'
%             for i=1:structLength
%                 switch char(params(i))
%                     case 'numTrees'
%                         assert(isnumeric(cell2mat(values(i))) & ...
%                             ceil(cell2mat(values(i))) == floor(cell2mat(values(i))), ...
%                             'numTrees must be a numeric integer');
%                         assert(cell2mat(values(i))>0, 'numTrees must be positive');
%                         numTrees = cell2mat(values(i));
%                     case 'minLeafSize'
%                         assert(isnumeric(cell2mat(values(i))) & ...
%                             ceil(cell2mat(values(i))) == floor(cell2mat(values(i))), ...
%                             'minLeafSize must be a numeric integer');
%                         assert(cell2mat(values(i))>0, 'minLeafSize must be positive');
%                     otherwise
%                         error([char(params(i)) ' not a real input parameter to Random Forest Function. '])
%                 end
%             end
            mdl = TreeBagger(ip.Results.numTrees, X, Y, ...
                'OOBPrediction', 'on', 'minLeafSize', ip.Results.minLeafSize);
    end
    

end

