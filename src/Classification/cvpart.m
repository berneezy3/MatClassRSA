classdef cvpart
% partitionObj = cvpart(n,k)
% --------------------------------
% 
    
   properties
      folds
   end
   methods
      function obj = cvpart(n, k)
                  
        %initialize indices list
        obj.folds = {}  
          
        %get remainder
        remainder = rem(length(n), k)
    
        %get quotient
        %this is the number of trials each fold
        quotient = floor(length(n)/k)

        %case divisible
        if remainder == 0
            for i = 1:k
                foldIndices = zeros( length(n),1 )
                for j = 1:quotient
                    foldIndices(j+(i-1)*quotient) = 1
                end
                obj.folds{end+1} = foldIndices
            end
        %case indivisible
        else
            indexlocation = 0;
            for i = 1:k-remainder
                foldIndices = zeros( length(n),1 )
                for j = 1:quotient
                    foldIndices(j+(i-1)*quotient) = 1;
                    indexlocation = indexlocation + 1;
                end
                obj.folds{end+1} = foldIndices
            end
            for i = 1:remainder
                disp('ajhdbfajhsdbfljahsdf')
                disp(indexlocation)
                foldIndices = zeros( length(n),1 )
                for j = 1:quotient+1
                    foldIndices(j+(i-1)*quotient+indexlocation) = 1
                end
                obj.folds{end+1} = foldIndices
            end
        end
      
      end
   end
end