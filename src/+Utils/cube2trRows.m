function xOut = cube2trRows(xIn)
%-------------------------------------------------------------------
% xOut = cube2trRows(xIn)
%-------------------------------------------------------------------
%
% This function takes in a 3D electrodes x time x trials matrix and
% reshapes it to a 2D trials by concatenated-electrodes matrix. Only 1
% input is needed since all possible dimensions of the data can be inferred
% from the 3D input matrix. 

% REQUIRED INPUTS:
%   - xIn:  a 3D electrodes x time x trials matrix
%
% OUTPUTS:
%   - xOut: a 2D trials by concatenated-electrodes matrix

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

% Get sizes to initialize the output
nCh = size(xIn, 1); % Number of electrodes
N = size(xIn, 2); % Number of time samples per trial
nTr = size(xIn, 3); % Number of trials

xOut = nan(nTr, nCh*N);

for i = 1:nTr
   xOut(i,:) = reshape(xIn(:,:,i)', 1, []);
end
