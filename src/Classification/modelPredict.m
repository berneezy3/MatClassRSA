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
            predictions = str2num(cell2mat(predict(mdl,X)))';
        otherwise
            error(['mdl must be of class TreeBagger, ClassificationDiscriminant' ...
                'or TreeBagger']);
    end
    
end