function [firstInds, secondInds] = getNChoose2Ind(n)
%-------------------------------------------------------------------
% [firstInds, secondInds] = getNChoose2Ind(n)
% ------------------------------------------------------------------
%
% Given an input length \texttt{n}, this function returns two arrays 
% representing the first and second classes for e.g., pairwise 
% classifications of n classes. This is a utility function intended to be 
% used by decValues2PairwiseAcc().
%
% INPUT ARGS:
%   - n:  number of classes
%
% OUTPUT ARGS:
%   - firstInds: first class
%   - secondInds: second class

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

    nc2 = n * (n-1) / 2;
    nbfirstInds = zeros(1, nc2);
    secondInds = zeros(1, nc2);
    for i = 1:nc2
        temp = i;
        for j = n-1:-1:1
            if (temp - j <= 0)
                secondInds(i) = n + temp - j;
                firstInds(i) = n-j; 
                break;
            else
                temp = temp -j;
            end
        end
    end

end