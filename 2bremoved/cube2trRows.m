function xOut = cube2trRows(xIn)
% --------------------------------
% xOut = cube2trRows(xIn)
% Blair - July 4, 2016
%
% This function takes in a 3D electrodes x time x trials matrix and
% reshapes it to a 2D trials by concatenated-electrodes matrix. Needs only
% 1 input, so fun!
%
% See also cube2chRows ch2trRows tr2chRows chRows2cube trRows2cube

% Get sizes to initialize the output
nCh = size(xIn, 1); % Number of electrodes
N = size(xIn, 2); % Number of time samples per trial
nTr = size(xIn, 3); % Number of trials

xOut = nan(nTr, nCh*N);

for i = 1:nTr
   xOut(i,:) = reshape(xIn(:,:,i)', 1, []);
end
