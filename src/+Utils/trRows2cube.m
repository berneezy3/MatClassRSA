function xOut = trRows2cube(xIn, N)
% ------------------------------------
% xOut = trRows2cube(xIn, N)
% ------------------------------------
% 
% This function takes a 2D trials x concat electrodes 
% matrix and reshapes it into a 3D electrodes x time x trials 
% cube.
% Inputs
%  xIn: Trials x concatenated electrodes matrix
%  N: Number of time samples per trial
% Outputs
%  xOut: Electrodes x time x trials cube
%
% Note that the input should have N*nElectrodes columns. The 
% function will return an error if the number of columns in 
% the input matrix is not integer-divisible by N.

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

% Check to see that the number of columns in the input makes sense.
if rem(size(xIn, 2)/N, 1) ~= 0
    error('Number of columns in input is not integer divisible by N.');
end

% Initialize output matrix
nCh = size(xIn, 2)/N; % Number of electrodes
nTr = size(xIn, 1); % Number of trials
xOut = nan(nCh, N, nTr);

% Reshape each trial (row) into electrodes x time matrix
for i = 1:nTr
   xOut(:,:,i) = reshape(xIn(i,:), N, [])'; 
end
