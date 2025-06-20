function [X, Y] = convert2double(X, Y)
%-------------------------------------------------------------------
%  [X, Y] = convert2double(X, Y)
%-------------------------------------------------------------------
%
% This function converts user data into double format
%
% REQUIRED INPUTS:
%       X - data matrix. Can be either a 2D (trial x feature) or
%           3D (space x time x trial) matrix.
%       Y - labels vector. Length should match the length of the trials
%           dimension of X.
%
% OUTPUTS:
%       X - Converted data matrix (double format). Can be either a 2D (trial x feature) or
%           3D (space x time x trial) matrix.
%       Y - Converted labels vector (double format). Length should match the length of the trials
%           dimension of X.

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

   if ~isa(X, 'double')
       warning('X data matrix not in double format.  Converting X values to double.')
       disp('Converting X matrix to double')
       X = double(X); 
   end
   if ~isa(Y, 'double')
       warning('Y label vector not in double format.  Converting Y labels to double.')
       Y = double(Y);
       disp(Y);
   end

end