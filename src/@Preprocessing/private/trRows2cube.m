function xOut = trRows2cube(xIn, N)
% ------------------------------------
% xOut = trRows2cube(xIn, N)
% Blair - July 4, 2016
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

% See also tr2chRows ch2trRows chRows2cube cube2trRows cube2chRows

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2016 Blair Kaneshiro
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
