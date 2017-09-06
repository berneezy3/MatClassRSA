function img = plotMatrix(matrix, varargin)
% plotMatrix(matrix, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function plots a confusion matrix with the
% specified labels.
%
% INPUT ARGS:
% - matrix: A matrix, e.g. a confusion matrix or a distance matrix
%
% Optional name-value pairs:
% - 'axisColors': a vector of colors, ordered by the order of labels in the 
%                   confusion matrix
%                   e.g. ['y' 'm' 'c' 'r' 'g' 'b' 'w' 'k']
%                   or ['yellow' 'magenta' 'cyan' 'red' 'green' 
%                       'blue' 'white' 'black']
% - 'axisLabels': a matrix of alphanumeric labels, ordered by same order of
%                   labels in the confusion matrix
%                   e.g. ['cat' 'dog' 'fish']
% - 'iconPath': a directory containing images used to label, in which the
%                   image files must be ordered in the same order as the 
%                   labels of the confusion matrix
%
%
% Notes:
%   6 types of labels for the visualiations:
%       Color labels
%       Character labels
%       Image labels
%       Color character labels
%       color image labels
%       None
%  
% TODO: test, calcuate optimal size for icons

    % parse inputs
    ip = inputParser;
    ip.FunctionName = 'plotCM';
    ip.addRequired('matrix',@ismatrix);
    options = [1, 0];
    ip.addParameter('axisColors', [], @(x) isvector(x)); 
    ip.addParameter('axisLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    ip.addParameter('colormap', '');
    ip.addParameter('colorbar', '');
    ip.addParameter('matrixLabels', '');
    ip.addParameter('FontSize', 15, @(x) isnumeric(x));
    ip.addParameter('Ticks', 5, @(x) (isnumeric(x) && X>0));
    parse(ip, matrix,varargin{:});
    
    img = figure;
    imagesc(matrix);
    
    if ~isempty(ip.Results.colormap)
        colormap(ip.Results.colormap);
    end
    
    if ~isempty(ip.Results.matrixLabels)
        if ip.Results.matrixLabels
            % Label the dendrogram with values
            % 
            textStrings = num2str(matrix(:),'%0.2f');  %# Create strings from the matrix values
            textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
            [x,y] = meshgrid(1:length(matrix));   %# Create x and y coordinates for the strings
            text(x(:),y(:),textStrings(:),...      %# Plot the strings
                        'HorizontalAlignment','center', ...
                        'FontSize', ip.Results.FontSize);
        end
    end
    
    c = colorbar;
    matMin = min(min(matrix));
    matMax = max(max(matrix));
    inc = (matMax - matMin)/(ip.Results.Ticks-1);
    %c.Ticks = str2num(sprintf('%.2f2 ', [[0:ip.Results.Ticks-2] * inc + matMin  matMax]));
    %c.FontWeight = 'bold';
    c.FontSize = ip.Results.FontSize;
    xticklabels('');
    yticklabels('');

    hold on;
    
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.axisLabels)
        labels = ip.Results.axisLabels;
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        labels = getImageFiles(ip.Results.iconPath);
    elseif isempty(ip.Results.axisLabels) && isempty(ip.Results.iconPath) && ~isempty(ip.Results.axisColors)
         labels = ip.Results.axisColors;
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        return;
    end
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE:  AXIS COLOR LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels) ...
            && isempty(ip.Results.iconPath)
    
        hold off;
        F = getframe(gcf);
        CMimg = F.cdata;
        imagesc(CMimg);
        axis off;
        numLabels = length(labels);

        
        % Variables to determine color plotting coordinates
        textLength = 15;
        textHeight = 15;
        tHeightInit = 72+685/numLabels/2-textHeight/2;
        tWidthInit = 138+685/numLabels/2-textLength/2;
        
        disp(length(labels))
        for i = 1:length(labels)
            hold on;
            
            % since space to fit icons is limited, we will need to adjust 
            % the x coordinates of the icons
            if numLabels < 30
                 text(85 - textLength, 685/numLabels*(i-1) + tHeightInit,...
                     ip.Results.axisLabels(i), 'FontWeight', 'bold', ...
                      'Color', ip.Results.axisColors{i}, 'FontSize', textLength);
                text(790/numLabels*(i-1)+tWidthInit, 770,...
                    ip.Results.axisLabels(i), 'FontWeight', 'bold', ...
                      'Color', ip.Results.axisColors{i}, 'FontSize', textLength);
            else 
                text(110 - textLength*(rem(i,3)+1)/2, 685/numLabels*(i-1) + tHeightInit,...
                    ip.Results.axisLabels(i), 'FontWeight', 'bold', ...
                      'Color', ip.Results.axisColors{i}, 'FontSize', textLength);
                text(790/numLabels*(i-1) + tWidthInit, 760 + textLength/2*rem(i,3),...
                     ip.Results.axisLabels(i), 'FontWeight', 'bold',...
                     'Color', ip.Results.axisColors{i}, 'FontSize', textLength);
            end
        
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: AXIS LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels) ...
            && isempty(ip.Results.iconPath)
        disp('CASE: axis')
        xticks(1:length(ip.Results.axisLabels))
        yticks(1:length(ip.Results.axisLabels))
        xticklabels(ip.Results.axisLabels)
        yticklabels(ip.Results.axisLabels)
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE OR COLOR IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif  ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.axisLabels)
        
        F = getframe(gcf);
        CMimg = im2double(F.cdata);
        image(CMimg);
        axis off;
        
        folder = dir(ip.Results.iconPath);
        folder = folder(1).folder
        disp([folder '/' labels(1)])
        
        % Variables to determine plotting coordinates
        numLabels = length(labels);
        iconLength = 30;
        iconHeight = 30;
        heightInit = 64+685/numLabels/2-iconHeight/2;
        widthInit = 142+685/numLabels/2-iconLength/2;
        
        % Variables to determine color plotting coordinates
        colorLength = 35;
        colorHeight = 35;
        cHeightInit = 64+685/numLabels/2-colorHeight/2;
        cWidthInit = 142+685/numLabels/2-colorLength/2;
        
        disp(length(labels))
        for i = 1:length(labels)
            hold on;
            [thisIcon map] = imread( [char(folder) '/' char(labels(i))] );
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            if ~isempty(map)
                thisIcon = ind2rgb(thisIcon, map);
            else
                thisIcon = double(thisIcon)/255;
            end
            if length(size(thisIcon)) == 2
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
            end
            
            % since space to fit icons is limited, we will need to adjust 
            % the x coordinates of the icons
            if numLabels < 30
                if ~isempty(ip.Results.axisColors)
                     rectangle('Position', [122 - colorLength, 685/numLabels*(i-1) + cHeightInit,...
                         colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
                    rectangle('Position', [790/numLabels*(i-1)+cWidthInit, 752,...
                         colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
                end
                imagesc([120 - iconLength, 120], ...
                    [ 685/numLabels*(i-1) + heightInit, 685/numLabels*(i-1)...
                    + heightInit + iconHeight], thisIcon);
                imagesc([ 790/numLabels*(i-1) + widthInit, 790/numLabels*(i-1)...
                    + widthInit  + iconHeight], [755, 755 + iconLength], thisIcon);
            % stacked labeling
            else 
                if ~isempty(ip.Results.axisColors)
                    rectangle('Position', [117 - iconLength*(rem(i,3)+1), 685/numLabels*(i-1) + cHeightInit,...
                        colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
                    rectangle('Position', [ 790/numLabels*(i-1) + cWidthInit, 758 + iconLength*rem(i,3),...
                         colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
                end
                imagesc([120 - iconLength*(rem(i,3)+1), 120 - iconLength*rem(i,3)], ...
                    [ 685/numLabels*(i-1) + heightInit, 685/numLabels*(i-1) + ...
                    heightInit + iconHeight], thisIcon);
                imagesc([ 790/numLabels*(i-1) + widthInit, 790/numLabels*(i-1)...
                    + widthInit  + iconHeight], [760 + iconLength*rem(i,3), 760 + iconLength*(rem(i,3)+1)], thisIcon);
            end
            
        end
        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.axisColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.axisLabels)
        
        F = getframe(gcf);
        CMimg = im2double(F.cdata);
        image(CMimg);
        axis off;
        numLabels = length(labels);

        
        % Variables to determine color plotting coordinates
        colorLength = 30;
        colorHeight = 30;
        cHeightInit = 64+685/numLabels/2-colorHeight/2;
        cWidthInit = 142+685/numLabels/2-colorLength/2;
        
        disp(length(labels))
        for i = 1:length(labels)
            hold on;
            
            % since space to fit icons is limited, we will need to adjust 
            % the x coordinates of the icons
            if numLabels < 30
                 rectangle('Position', [120 - colorLength, 685/numLabels*(i-1) + cHeightInit,...
                     colorLength, colorHeight], ...
                    'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                    ip.Results.axisColors{i});
                rectangle('Position', [790/numLabels*(i-1)+cWidthInit, 755,...
                     colorLength, colorHeight], ...
                    'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                    ip.Results.axisColors{i});
            else 
                    rectangle('Position', [120 - iconLength*(rem(i,3)+1), 685/numLabels*(i-1) + cHeightInit,...
                        colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
                    rectangle('Position', [ 790/numLabels*(i-1) + cWidthInit, 760 + iconLength*rem(i,3),...
                         colorLength, colorHeight], ...
                        'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
                        ip.Results.axisColors{i});
            end
        
        end


    
    

end