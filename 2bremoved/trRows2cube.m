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
