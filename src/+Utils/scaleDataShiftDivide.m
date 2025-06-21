function scaledData = scaleDataShiftDivide(data, shift1, shift2, scaleFactor)
% scaledData = scaleDataShiftDivide(data, shift1, shift2, scaleFactor)
% -------------------------------------------------------------------------
%
% This function takes in the data matrix data along with shift and divide
% factors calculated from the function scaleDataInRange(). The function 
% applies the shift and divide factor on the data matrix to bring the data
% to the range specified in scaleDataInRange(). Thus, the function can be
% used to apply precomputed shift and scaled factors to a dataset. 
% 
% INPUTS
% The function takes in the four variables in this equation:
%   (data - shift1).*scaleFactor + shift2
%
% OUTPUTS
%   scaledData:  Data matrix that has undergone the above equation.

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

    scaledData = (data - shift1).*scaleFactor + shift2;

end