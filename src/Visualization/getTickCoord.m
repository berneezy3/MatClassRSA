function [xTickVec yTickVec] = getTickCoord()

    % use vertical align to plot images/text easily
    yCoords = yticks;
    xCoords = xticks;
    yl = ylim;
    yOffset = (yl(2) - yl(1))/25;
    xl = xlim;
    xOffset = (xl(2)-xl(1))/25;
    
    yCoord4xAxis = yl(1) - yOffset;
    xCoord4yAxis = xl(1) - xOffset;
    
    xlen = length(xCoords);
    ylen = length(yCoords);
    
    xTickVec = NaN(xlen, 2);
    yTickVec = NaN(ylen, 2);
 
    for i = 1:xlen
        xTickVec(i,1) = xCoords(i);
        xTickVec(i,2) =  yCoord4xAxis;
    end
    
    for i = 1:ylen
        yTickVec(i,1) = xCoord4yAxis;
        yTickVec(i,2) = yCoords(i);
    end
    

end