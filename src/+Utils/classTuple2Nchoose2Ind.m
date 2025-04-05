function y = classTuple2Nchoose2Ind(classTuple, n)
%-------------------------------------------------------------------
% classTuple2Nchoose2Ind(classTuple, n)
% --------------------------------------------------------------------
% Bernard Wang, Sept 28, 2019
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