function y = processRDM(RDM)
% y = processRDM(RDM)
% ----------------------------
% For a given input RDM, this function (1) ensures the RDM is square; (2)
% ensures the RDM is symmetric (if not, will print a warning and use the
% lower triangle); and (3) ensures the diagonal is zero (if not, will print
% a warning and set diagonal to zero). 
%
% INPUT
% - RDM: Input RDM
%
% OUTPUT
% - RDM with the three conditions enforced. If input RDM was already
% square, symmetric, and zero-diagonal, the output will be the same as the
% input. 

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

    % make sure RDM is square
    [r c] = size(RDM);
    if (r ~= c)
        error('Input matrix must be square matrix.')
    end
    
    % make sure RDM is symmetric, or else use lower triangle
    numPairs = nchoosek(r ,2);
    classPairs = nchoosek(1:r, 2);
    for k = 1:numPairs

        % class1 class2
        class1 = classPairs(k, 1);
        class2 = classPairs(k, 2);
        
        if RDM(class1, class2) ~= RDM(class2, class1)
            warning(['Input matrix should be symmetrical across the diagonal.'...
                'Using lower triangle results only. '])
            RDM(class2, class1) = RDM(class1, class2)
        end
            
    end
    
    % make sure diagonal is zero
    if (sum(find(diag(RDM))) ~= 0)
        warning('non-zero value on diagonal detected.  Setting RDM diagonal values to be zero');
        for i = 1:r
            RDM(i,i) = 0;
        end
    end
    
    %RDM = RDM .* (tril(true(size(RDM)),-1));
    y = RDM;

end