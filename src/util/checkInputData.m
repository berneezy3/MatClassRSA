function checkInputData(X, Y)

    %%% Check the input data matrix X
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
    %%% Check the input labels vector Y
    if ~isvector(Y)
        error('Input labels vector must be a vector.')
    elseif length(Y) ~= nTrials
        error(['Length of input labels vector must correspond '...
            'to number of trials (' num2str(nTrials) ').'])
    end
    % Convert to column vector if needed
    if ~iscolumn(Y)
       warning('Transposing input labels vector to column.') 
       Y = Y(:);
    end

end
