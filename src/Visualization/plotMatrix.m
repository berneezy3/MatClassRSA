function img = plotMatrix(RDM, varargin)
%-------------------------------------------------------------------
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

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

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
    ip.addParameter('matrixLabels', 1);
    ip.addParameter('FontSize', 15, @(x) isnumeric(x));
    ip.addParameter('ticks', 5, @(x) (isnumeric(x) && x>0));
    ip.addParameter('textRotation', 0, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('iconSize', 40);
    parse(ip, RDM,varargin{:});
    
    imagesc(RDM);
    img = gcf;

    
    if ~isempty(ip.Results.colormap)
        colormap(ip.Results.colormap);
    end
    
    if (ip.Results.matrixLabels==1)
        % Label the dendrogram with values
        % 
        textStrings = num2str(RDM(:),'%0.2f');  %# Create strings from the matrix values
        textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
        [x,y] = meshgrid(1:length(RDM));   %# Create x and y coordinates for the strings
        text(x(:),y(:),textStrings(:),...      %# Plot the strings
                    'HorizontalAlignment','center', ...
                    'FontSize', ip.Results.FontSize);
    end
    
    if ip.Results.colorbar > 0
        c = colorbar;
        c.FontSize = ip.Results.FontSize;
        matMin = min(min(RDM));
        matMax = max(max(RDM));
        %truncMax = fix(matMax * 10^2)/10^2;
        inc = (matMax - matMin)/(ip.Results.ticks-1);
        c.Ticks = str2num(sprintf('%.2f2 ', [[0:ip.Results.ticks-2] * inc + matMin  matMax]));
        c.FontWeight = 'bold';
    end
    

    
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
%         set(gca,'xtick',[]);
%         set(gca,'ytick',[]);
        return;
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE:  DEFAULT LABELS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(ip.Results.axisColors) && isempty(ip.Results.axisLabels) ...
            && isempty(ip.Results.iconPath)
    disp('CASE: DEAFULT LABELS')

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE:  AXIS COLOR LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels) ...
            && isempty(ip.Results.iconPath)
        
        disp('CASE: AXIS COLOR LABELS')

        [xTickCoords yTickCoords] = getTickCoord;
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');
        numLabels = length(labels);
        bottomYCoord =  numLabels + .5;

        
        for i = 1:length(labels)
                label = labels(i);
                t = text(xTickCoords(i, 1), bottomYCoord, label, ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'top');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.axisColors{i};
                t(1).FontSize = 25;
        end
        
        for i = 1:length(labels)
                label = labels(i);
                t = text(yTickCoords(i, 1), yTickCoords(i, 2), label, ...
                    'HorizontalAlignment', 'center');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.axisColors{i};
                t(1).FontSize = 25;

        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: AXIS LABEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.axisColors) && ~isempty(ip.Results.axisLabels) ...
            && isempty(ip.Results.iconPath)
        disp('CASE: LABEL')

        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');

        set(gca,'xTickLabel', ip.Results.axisLabels, 'FontSize', ip.Results.FontSize);
        set(gca,'yTickLabel', ip.Results.axisLabels, 'FontSize', ip.Results.FontSize);

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif  ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.axisLabels)
        
                
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');
        
        [xTickCoords yTickCoords] = getTickCoord;

        pos = get(gca,'position');
        leftMargin = pos(1);
        bottomMargin = pos(2);
        topMargin = pos(2) + pos(4);
        xdlta = (pos(3)) / (length(xTickCoords));
        ydlta = (pos(4)) / (length(xTickCoords));
        xinit = xdlta/2;
        yinit = ydlta/2;
        figPos = get(gcf, 'position');
        figWidth = figPos(3);
        figHeight = figPos(4);
        
        for i = 1:length(labels)
            [thisIcon map] = imread([char(labels(i))]);
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            
            if ~isempty(map)
                disp('converting to RGB')
                %disp(map);
                thisIcon = ind2rgb(thisIcon, map);
            else
                thisIcon = thisIcon/255;
            end
            
            % Resize to 40*40 square
            if height > width
                thisIcon = imresize(thisIcon, [ip.Results.iconSize NaN]);
            else
                thisIcon = imresize(thisIcon, [NaN ip.Results.iconSize]);
            end

            % Add 3rd(color) dimension if there is none
            if length(size(thisIcon)) == 2
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
            end

            if i <= length(labels)
                % plot x axis labels
                lblAx = axes('parent',gcf,'position', ...
                    [leftMargin + xinit + xdlta * (i-1) - ip.Results.iconSize/2/figWidth ...
                    ,bottomMargin-ip.Results.iconSize/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                imagesc(thisIcon,'parent',lblAx);
                axis(lblAx,'off');
                % plot y axis labels
                lblAx = axes('parent',gcf,'position', ...
                    [leftMargin - ip.Results.iconSize/figWidth ...
                    ,topMargin - yinit - ydlta * (i-1) - ip.Results.iconSize/2/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                imagesc(thisIcon,'parent',lblAx);
                axis(lblAx,'off');
            else
            end
        end
        
        
        
%         F = getframe(gcf);
%         CMimg = im2double(F.cdata);
%         image(CMimg);
%         axis off;
%         
%         folder = dir(ip.Results.iconPath);
%         folder = folder(1).folder
%         disp([folder '/' labels(1)])
%         
%         % Variables to determine plotting coordinates
%         numLabels = length(labels);
%         iconLength = 30;
%         iconHeight = 30;
%         heightInit = 64+685/numLabels/2-iconHeight/2;
%         widthInit = 142+685/numLabels/2-iconLength/2;
%         
%         % Variables to determine color plotting coordinates
%         colorLength = 35;
%         colorHeight = 35;
%         cHeightInit = 64+685/numLabels/2-colorHeight/2;
%         cWidthInit = 142+685/numLabels/2-colorLength/2;
%         
%         disp(length(labels))
%         for i = 1:length(labels)
%             hold on;
%             [thisIcon map] = imread( [char(folder) '/' char(labels(i))] );
%             [height width] = size(thisIcon);
%             %convert thisIcon to scale 0~1
%             if ~isempty(map)
%                 thisIcon = ind2rgb(thisIcon, map);
%             else
%                 thisIcon = double(thisIcon)/255;
%             end
%             if length(size(thisIcon)) == 2
%                 thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
%             end
%             
%             % since space to fit icons is limited, we will need to adjust 
%             % the x coordinates of the icons
%             if numLabels < 30
%                 if ~isempty(ip.Results.axisColors)
%                      rectangle('Position', [122 - colorLength, 685/numLabels*(i-1) + cHeightInit,...
%                          colorLength, colorHeight], ...
%                         'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
%                         ip.Results.axisColors{i});
%                     rectangle('Position', [790/numLabels*(i-1)+cWidthInit, 752,...
%                          colorLength, colorHeight], ...
%                         'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
%                         ip.Results.axisColors{i});
%                 end
%                 imagesc([120 - iconLength, 120], ...
%                     [ 685/numLabels*(i-1) + heightInit, 685/numLabels*(i-1)...
%                     + heightInit + iconHeight], thisIcon);
%                 imagesc([ 790/numLabels*(i-1) + widthInit, 790/numLabels*(i-1)...
%                     + widthInit  + iconHeight], [755, 755 + iconLength], thisIcon);
%             % stacked labeling
%             else 
%                 if ~isempty(ip.Results.axisColors)
%                     rectangle('Position', [117 - iconLength*(rem(i,3)+1), 685/numLabels*(i-1) + cHeightInit,...
%                         colorLength, colorHeight], ...
%                         'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
%                         ip.Results.axisColors{i});
%                     rectangle('Position', [ 790/numLabels*(i-1) + cWidthInit, 758 + iconLength*rem(i,3),...
%                          colorLength, colorHeight], ...
%                         'faceColor', ip.Results.axisColors{i}, 'EdgeColor', ...
%                         ip.Results.axisColors{i});
%                 end
%                 imagesc([120 - iconLength*(rem(i,3)+1), 120 - iconLength*rem(i,3)], ...
%                     [ 685/numLabels*(i-1) + heightInit, 685/numLabels*(i-1) + ...
%                     heightInit + iconHeight], thisIcon);
%                 imagesc([ 790/numLabels*(i-1) + widthInit, 790/numLabels*(i-1)...
%                     + widthInit  + iconHeight], [760 + iconLength*rem(i,3), 760 + iconLength*(rem(i,3)+1)], thisIcon);
%             end
%             
%         end
        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.axisColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.axisLabels)
        
                
        set(gca,'xTickLabel', '');
        set(gca,'yTickLabel', '');
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