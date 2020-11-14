function y = processRDM(RDM)

    [r c] = size(RDM);
    if (r ~= c)
        error('Input matrix must be square matrix.')
    end
    
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
    
    %RDM = RDM .* (tril(true(size(RDM)),-1));
    y = RDM;

end