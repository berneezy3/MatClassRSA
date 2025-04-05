function xOut = cube2trRows(xIn)
%-------------------------------------------------------------------
% xOut = cube2trRows(xIn)
%-------------------------------------------------------------------
% Blair - July 4, 2016
%
% This function takes in a 3D electrodes x time x trials matrix and
% reshapes it to a 2D trials by concatenated-electrodes matrix. Needs only
% 1 input, so fun!
%
% See also cube2chRows ch2trRows tr2chRows chRows2cube trRows2cube

% REQUIRED INPUTS:
%   - xIn:  a 3D electrodes x time x trials matrix
%
% OUTPUTS:
%   - xOut: a 2D trials by concatenated-electrodes matrix


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

% Get sizes to initialize the output
nCh = size(xIn, 1); % Number of electrodes
N = size(xIn, 2); % Number of time samples per trial
nTr = size(xIn, 3); % Number of trials

xOut = nan(nTr, nCh*N);

for i = 1:nTr
   xOut(i,:) = reshape(xIn(:,:,i)', 1, []);
end
