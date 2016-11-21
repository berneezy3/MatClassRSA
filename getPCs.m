%load('Kaneshiro_etAl_objectCategoryEEG/s1.mat');

function y = getPCs(X, PCs)

    [U,S,V] = svd(X);


    % This graph shows how many PCs explain 
    diagS = diag(S);
    diagS = diagS.^2;
    diagS = diagS/sum(diagS);
    %find first variable in cumsumDiagS that is above explThresh, 
    %arbitrarily set explThresh to .9
    if (PCs < 1 && PCs >0)
        explThresh = PCs;
        cumsumDiagS = cumsum(diagS);
        nPC = find(cumsumDiagS>=explThresh, 1);
    elseif (PCs>1)
        nPC = round(PCs);
     
    end
    
    %plot(cumsumDiagS);
    %xlim([0,250]);

    xPC = X * V;
    y = xPC(:,1:nPC);

end