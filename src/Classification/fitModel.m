function mdl = fitModel(X, Y, classifier, ip)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
  
    % initialize variable to parse ip
%     structLength = length(fieldnames(ip));
%     params = fieldnames(ip);
%     values = cell(1,structLength);
%     
%     for i=1:structLength
%         values{1, i} = getfield(classifyOptionsStruct, params{i});
%     end
%     

    switch classifier
        case 'SVM'
            Y = Y';
            switch ip.Results.kernel
                case 'linear'
                    kernelNum = 0;
                case 'polynomial'
                    kernelNum = 1;
                case 'rbf'
                    kernelNum = 2;
                case 'sigmoid'
                    kernelNum = 3;
            end
            currpath = pwd;
            [libsvmpath,name,ext] = fileparts(which('matlab/svmtrain'));
            cd(libsvmpath);
            [funcOutput mdl] = evalc('svmtrain(Y, X, [''-t '' num2str(kernelNum)])');
            cd(currpath);
            
        case 'LDA'

            mdl = fitcdiscr(X, Y, 'DiscrimType', 'linaer'); 
            
            
        case 'RF'
%             for i=1:structLength
%                 switch char(params(i))
%                     case 'numTrees'
%                         assert(isnumeric(cell2mat(values(i))) & ...
%                             ceil(cell2mat(values(i))) == floor(cell2mat(values(i))), ...
%                             'numTrees must be a numeric integer');
%                         assert(cell2mat(values(i))>0, 'numTrees must be positive');
%                         numTrees = cell2mat(values(i));
%                     case 'minLeafSize'
%                         assert(isnumeric(cell2mat(values(i))) & ...
%                             ceil(cell2mat(values(i))) == floor(cell2mat(values(i))), ...
%                             'minLeafSize must be a numeric integer');
%                         assert(cell2mat(values(i))>0, 'minLeafSize must be positive');
%                     otherwise
%                         error([char(params(i)) ' not a real input parameter to Random Forest Function. '])
%                 end
%             end
            mdl = TreeBagger(ip.Results.numTrees, X, Y, ...
                'OOBPrediction', 'on', 'minLeafSize', ip.Results.minLeafSize);
    end
    

end

