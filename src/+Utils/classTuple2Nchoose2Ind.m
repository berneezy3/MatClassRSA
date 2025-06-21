function y = classTuple2Nchoose2Ind(classTuple, n)
%-------------------------------------------------------------------
% y = classTuple2Nchoose2Ind(classTuple, n)
% --------------------------------------------------------------------
%
% Say we are given N choose 2 pairs of classes, and these N choose 2
% classes were sequentially ordered into a vector. This function takes a 
% pair of classes (classTuple) and finds the index of said pair in the 
% vector of pairs. For example, if we are conducting pairwise 
% classification amongst 5 classes, we would have 5 choose 2 tuples of 
% classes.  If we were to run the function call classTuple2Nchoose2Ind((2, 4), 5), 
% the function would return index 6.  
% 
% INPUTS:
%   - classTuple: a pair of classes in array form
%   - n: number of classes
%
% OUTPUTS:
%   - y: index of the class pair
%

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

    if ( classTuple(2) <= classTuple(1) )
        error('second class index must be greater than first');
    end

    firstClass = classTuple(1);
    secondClass = classTuple(2);
    
    temp = n-1;
    y = 0;

    for i = 1:firstClass-1
        y = y + temp;
        temp = temp-1;
    end
    
    y = y + secondClass - firstClass;
    

end