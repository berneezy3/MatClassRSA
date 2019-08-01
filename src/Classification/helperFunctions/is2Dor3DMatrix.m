 function y = is2Dor3DMatrix(x)
        if ismatrix(x)
            y = 1;
        % checck if input is a 3D matrix
        elseif isequal(size(size(x)), [1 3])
            y = 1;
        else
            y = 0;
        end
 end