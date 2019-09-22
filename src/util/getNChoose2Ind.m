function [firstInds, secondInds] = getNChoose2Ind(n)

    nc2 = n * (n-1) / 2;
    nbfirstInds = zeros(1, nc2);
    secondInds = zeros(1, nc2);
    for i = 1:nc2
        temp = i;
        for j = n-1:-1:1
            if (temp - j <= 0)
                secondInds(i) = n + temp - j;
                firstInds(i) = n-j; 
                break;
            else
                temp = temp -j;
            end
        end
    end

end