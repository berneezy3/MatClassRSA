function y = endswith(a, b)
%-------------------------------------------------------------------
% y = endswith(a, b)
% --------------------------------
%
% Checks if char vector a ends with char vector b
% 
% INPUT ARGS:
%   - a: char vector, must be as long as b
%   - b: char vector, must be at most as long as a
%
% OUTPUT ARGS:
%   - y:  1 or 0

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

    if (length(a) < length(b))
        y = 0;
        return
    elseif (length(a) == length(b))
        if strcmp(a,b)
            y = 1;
            return
        else
            y=0;
            return
        end
    end

    for i=1:length(b)
        if a(length(a)-(length(b)-i)) ~= b(i)
            y = 0;
            return
        end
    end
    
    y=1;
end