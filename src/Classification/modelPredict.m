function predictions = modelPredict(X, mdl)
    
    classifier = class(mdl);
    
    switch classifier
        case 'struct'  
            [r c] = size(X);
            Y = zeros(r,1);
            [predictions, acc, prob_estimates] = svmpredict(Y, X, mdl);
            predictions = predictions';
        case 'ClassificationDiscriminant'
            predictions = predict(mdl,X);
            predictions = predictions(:,end);
            predictions = predictions';
        case 'TreeBagger'
            predictions = oobPredict(mdl);
            [rows, cols] = size(predictions);
            if (rows>cols)
                predictions = reshape(predictions,[cols rows]);
            end
            predictions = str2num(cell2mat(predictions));
        otherwise
            error(['mdl must be of class TreeBagger, ClassificationDiscriminant' ...
                'or TreeBagger']);
    end
    
end