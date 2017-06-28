function mdl = fitModel(X, Y, classifier, classifyOptionsStruct)

   

    % initialize variable to parse classifyOptionsStruct
    structLength = length(fieldnames(classifyOptionsStruct));
    params = fieldnames(classifyOptionsStruct);
    values = fields(classifyOptionsStruct);
    

    switch classifier
        case 'SVM'
            kernel = 'rbf';
            kernelNum = 2;
            Y = Y';
            for i=1:structLength
                switch params(i)
                    case 'kernel'
                        expectedKernels = {'linear', 'polynomial', 'rbf', 'sigmoid'};
                        validatestring(values(i), expectedkernels);
                        kernel = values(i);
                        switch kernel
                            case 'linear'
                                kernelNum = 0;
                            case 'polynomial'
                                kernelNum = 1;
                            case 'rbf'
                                kernelNum = 2;
                            case 'sigmoid'
                                kernelNum = 3;
                        end
                    otherwise
                        error([params(i) 'not a real input parameter to SVM function.'])
                    end
            end
            mdl = svmtrain(Y, X, ['-t ' kernelNum]);
            
            
        case 'LDA'
            discrimType = 'linear';
            for i=1:structLength
                switch params(i)
                    case 'DiscrimType' 
                        expectedDiscrimTypes = {'linear', 'quadratic', 'diagLinear', ... 
                            'diagQuadratic', 'pseudoLinear', 'pseudoLinear'}
                         validatestring(values(i), expectedDiscrimTypes);
                         discrimType = values(i);
                    otherwise
                         error([params(i) 'not a real input parameter to LDA function. '])
                end
            end
            mdl = fitcdiscr(X, Y, 'DiscrimType', discrimType); 
            
            
        case 'RandomForest'
            numTrees = 10;
            for i=1:structLength
                switch params(i)
                    case 'numTrees'
                        assert(isnumeric(values(i)) & ...
                            ceil(values(i)) ~= floor(values(i)), ...
                            "numTrees must be a numeric integer");
                        numTrees = values(i)
                    otherwise
                        error([params(i) 'not a real input parameter to Random Forest Function. '])
                end
            end
            mdl = TreeBagger(numTrees, X, Y, 'OOBPrediction', 'on');
    end
    

end

