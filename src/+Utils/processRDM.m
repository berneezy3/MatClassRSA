function y = processRDM(RDM)

    % make sure RDM is square
    [r c] = size(RDM);
    if (r ~= c)
        error('Input matrix must be square matrix.')
    end
    
    % make sure RDM is symmetric, or else use lower triangle
    numPairs = nchoosek(r ,2);
    classPairs = nchoosek(1:r, 2);
    for k = 1:numPairs

        % class1 class2
        class1 = classPairs(k, 1);
        class2 = classPairs(k, 2);
        
        if RDM(class1, class2) ~= RDM(class2, class1)
            warning(['Input matrix should be symmetrical across the diagonal.'...
                'Using lower triangle results only. '])
            RDM(class2, class1) = RDM(class1, class2)
        end
            
    end
    
    % make sure diagonal is zero
    if (sum(find(diag(RDM))) ~= 0)
        warning('non-zero value on diagonal detected.  Setting RDM diagonal values to be zero');
        for i = 1:r
            RDM(i,i) = 0;
        end
    end
    
    %RDM = RDM .* (tril(true(size(RDM)),-1));
    y = RDM;

end