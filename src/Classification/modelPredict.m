function predictions = modelPredict(X, mdl)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------

    classifier = class(mdl);
    
    switch classifier
        case 'struct'  
            [r c] = size(X);
            Y = zeros(r,1);
            [funcoutput predictions, acc, prob_estimates] = evalc('svmpredict(Y, X, mdl)');
            predictions = predictions';
        case 'ClassificationDiscriminant'
            predictions = predict(mdl,X);
            predictions = predictions(:,end);
            predictions = predictions';
        case 'TreeBagger'
            predictions = predict(mdl,X);
            [rows, cols] = size(predictions);
            predictions = str2num(cell2mat(predictions));
            if (rows>cols)
                predictions = reshape(predictions,[cols rows]);
            end
        otherwise
            error(['mdl must be of class TreeBagger, ClassificationDiscriminant' ...
                'or TreeBagger']);
    end
    
end