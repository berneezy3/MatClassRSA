function verifySVMParameters(ip)
%-------------------------------------------------------------------
% verifySVMParameters(ip)
% --------------------------------
%
% This function is used for the non-optimization classification functions
% to ensure that gamma and C parameters are manually set by the user when
% using the SVM classifier.
%
% INPUT
% - ip: The input parser of the current classification 
%
% OUTPUT
% - There are no outputs. If the gamma and C parameters are not
% appropriately set, the function will return an error with instructions to
% use one of the optimization functions to compute suitables values. 

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

    if (strcmp(ip.Results.classifier, 'SVM'))
        
        if(strcmp(ip.Results.kernel, 'rbf'))
            if any(strcmp(ip.UsingDefaults, 'C')) || any(strcmp(ip.UsingDefaults, 'gamma')) 
                error(['if SVM is selected as classifier with rbf kernel, then "C" and "gamma" ' ...
                'parameters must be manually set by the user.  Suitable values for'...
                ' "C" and "gamma" can determined using the optimization functions '...
                'in the classifiction folder denoted by the "_opt" postscript. ' ...
                'Then "C" and "gamma" can be passed into this function directly"']);
            end
            
        elseif (strcmp(ip.Results.kernel, 'linear'))
            if any(strcmp(ip.UsingDefaults, 'C'))
                error(['if SVM is selected as classifier with linear kernel, then "C"' ...
                'parameter must be manually set by the user.  Suitable values for'...
                ' "C" can determined using the optimization functions '...
                'in the classifiction folder denoted by the "_opt" postscript. ' ...
                'Then "C" can be passed into this function directly"']);
            end
        end
        
    end



end