function [W,Z,nSpace, nFeature, nTrials] = subsetTrainTestMatrices(X, Y, spaceUse, timeUse, featureUse)

    if ndims(X) == 3
        [nSpace, nFeature, nTrials] = size(X);
%         disp(['Input data matrix size: ' num2str(nSpace) ' space x ' ...
%                 num2str(nFeature) ' time x ' num2str(nTrials) ' trials'])
    elseif ndims(X) == 2
        nSpace = nan;
        [nTrials, nFeature] = size(X);
%         warning(['2D input data matrix. Assuming '...
%             num2str(nTrials) ' trials x ' num2str(nFeature) ' features.'])
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
       X_subset = cube2trRows(X_subset); % NOW IT'S 2D

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
    Z = Y;

end
