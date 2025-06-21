function [W, nSpace, nFeature, nTrials] = subsetTrainTestMatrices(X, spaceUse, timeUse, featureUse)
%-------------------------------------------------------------------
% [W, nSpace, nFeature, nTrials] = subsetTrainTestMatrices(X, spaceUse, timeUse, featureUse)
% ------------------------------------------------
%
% This function subsets the input Matrix X according to parameters
% spaceUse, timeUse and featureUse, defined by the user during the function
% call. spaceUse and timeUse operate on 3D [space x time x trial] input
% matrices, subsetting along the 1st and/or 2nd dimensions, respectively.
% featureUse operates on 2D [trial x feature] input matrices, subsetting
% along the 2nd dimension. The function returns a 2D trial-by-feature
% matrix whether a 2D or 3D matrix was input. 
%
% INPUT ARGS:
%   X - The input data matrix. Can be 2D or 3D. 
%   spaceUse - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the space dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       space dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   timeUse - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the time dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       time dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   featureUse - If X is a 2D, trials-by-features matrix, then this
%       option will subset X along the features dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       feature dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 3D,
%       space-by-time-by-trials matrix.
%
% OUTPUT ARGS:
% - W: The subset matrix. This will always be a 2D trial-by-feature matrix,
%   even if a 3D matrix was input. 
% - nSpace: The size of the space dimension of the output matrix (i.e., the
%   length of spaceUse). Will be NaN if input matrix was 2D. 
% - nFeature: The size of the feature dimension of the output matrix (i.e.,
%   the length of featureUse). This will report the size of the time
%   dimension (i.e., length of timeUse) if a 3D matrix was input.
% - nTrials: The number of trials of the output matrix.

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

    if ndims(X) == 3
        [nSpace, nFeature, nTrials] = size(X);
        disp(['Input data matrix size: ' num2str(nSpace) ' space x ' ...
                num2str(nFeature) ' time x ' num2str(nTrials) ' trials'])
    elseif ndims(X) == 2
        nSpace = nan;
        [nTrials, nFeature] = size(X);
        warning(['2D input data matrix. Assuming '...
            num2str(nTrials) ' trials x ' num2str(nFeature) ' features.'])
    else
        error('Input data matrix should be 3D or 2D matrix.')
    end
%     %%% Check the input labels vector Y
%     if ~isvector(Y)
%         error('Input labels vector must be a vector.')
%     elseif length(Y) ~= nTrials
%         error(['Length of input labels vector must correspond '...
%             'to number of trials (' num2str(nTrials) ').'])
%     end
%     % Convert to column vector if needed
%     if ~iscolumn(Y)
%        warning('Transposing input labels vector to column.') 
%        Y = Y(:);
%     end
%     
        %%%%% INPUT DATA SUBSETTING (doing)
    % Default chanUse, timeUse, featureUse = [ ]
%     spaceUse = ip.Results.spaceUse;
%     timeUse = ip.Results.timeUse;
%     featureUse = ip.Results.featureUse;
    
    %%% 3D input matrix
    X_subset = X; % This will be the next output; currently 3D or 2D
    if ndims(X) == 3
        % Message about ignoring 'featureUse' input
       if ~isempty(featureUse)
           warning('Ignoring ''featureUse'' for 3D input data matrix.')
           warning('Use ''spaceUse'' and ''timeUse'' for 3D input data matrix.')
       end

       % If the user did specify a spatial or temporal subset...
       if ~isempty(spaceUse) || ~isempty(timeUse)
           % Confirm that spaceUse and timeUse are vectors
           if (~isempty(spaceUse) && ~isvector(spaceUse)) ||...
                   (~isempty(timeUse) && ~isvector(timeUse))
               error('Enter a vector to specify spatial and/or temporal subsets.')
           end

           % Confirm that spaceUse and timeUse fit dimensions of data matrix
           if ~isempty(spaceUse) && ~all(ismember(spaceUse, 1:nSpace))
               error('''spaceUse'' input is not contained in the input data matrix.')
           elseif ~isempty(timeUse) && ~all(ismember(timeUse, 1:nFeature))
               error('''timeUse'' input is not contained in the input data matrix.')
           end

           % Do the subsetting
           if ~isempty(spaceUse)
               X_subset = X_subset(spaceUse, :, :);
           end
           if ~isempty(timeUse)
               X_subset = X_subset(:, timeUse, :);
           end

           % Update nSpace and nFeature
           nSpace = size(X_subset, 1);
           nFeature = size(X_subset, 2);
       end
       % Reshape the X_subset matrix
       X_subset = Utils.cube2trRows(X_subset); % NOW IT'S 2D

    %%% 2D input matrix
    elseif ndims(X) == 2
        % Messages about ignoring 'spaceUse' and/or 'timeUse' inputs
        if ~isempty(spaceUse) || ~isempty(timeUse)
           if ~isempty(spaceUse)
               warning('Ignoring ''spaceUse'' for 2D input data matrix.')
           end
           if ~isempty(timeUse)
               warning('Ignoring ''timeUse'' for 2D input data matrix.')
           end
           warning('Use ''featureUse'' for 2D input data matrix.')
        end

        % If the user specified a featureUse subset...
        if ~isempty(featureUse)
            % Confirm it's a vector
            if ~isvector(featureUse)
               error('Enter a vector to specify feature subsets.') 
            end

           % Confirm that featureUse is contained in the data matrix
           if ~all(ismember(featureUse, 1:nFeature))
              error('''featureUse'' input is not contained in the input data matrix.') 
           end

           % Do the subsetting
           X_subset = X_subset(:, featureUse);  % WAS ALREADY 2D

           % Update nFeature
           nFeature = size(X_subset, 2);
        end  
    end
    W = X_subset;

end
