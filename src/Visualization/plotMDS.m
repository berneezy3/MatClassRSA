function img = plotMDS(RDM, varargin)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% y = plotMDS(RDM, 'nodeColors', 'nodeLabels', 'iconPath')
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function creates a dendrogram plot with the distance matrix
% passed in.
%
% Required inputs:
% - RDM: A distance matrix.  Diagonals must be 0, and must be
%               symmetrical along the diagonal
%
% Optional name-value pairs:
% - 'nodeColors': a vector of colors, ordered by the order of labels in the 
%                   confusion matrix
%                   e.g. ['y' 'm' 'c' 'r' 'g' 'b' 'w' 'k']
%                   or ['yellow' 'magenta' 'cyan' 'red' 'green' 
%                       'blue' 'white' 'black']            
% - 'nodeLabels': a matrix of alphanumeric labels, ordered by same order of
%                   labels in the confusion matrix
%                   e.g. ['cat' 'dog' 'fish']
% - 'iconPath': a directory containing images used to label, in which the
%                   image files must be ordered in the same order as the 
%                   labels of the confusion matrix
%
%
% Notes:
%   - linkage order
%   - do more things regarding order
%
%TODO
% - specify which dimensions to plot
% - use xlim and ylim to determine boundary correctly
% - let user specify icon height and width
% - if # iamges > # classes, print instead of error


    if length(find(RDM<0)) > 0
        warning('Distance less than 0 detected, converting negative distances to 0');
        RDM(RDM<0) = 0;
    end

    ip = inputParser;
    ip.FunctionName = 'plotMDS';
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) assert(isvector(x))); 
    ip.addParameter('nodeLabels', [], @(x) assert(isvector(x)));
    ip.addParameter('iconPath', '');
    % which dimensions of MDS to plot
    ip.addParameter('dimensions', [1 2], @(x) assert(isvector(x) && ...
        isequal(size(x), [2 1]) || isequal(size(x), [1 2]), ...
        'dimensions must be vector of length 2'));
    ip.addParameter('xLim', [], @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'xlim must be length 2 vector'));
    ip.addParameter('yLim', [], @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'ylim must be length 2 vector'));
    parse(ip, RDM,varargin{:});
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        
        labels = ip.Results.nodeLabels;
        
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        
        labels = dir(ip.Results.iconPath);
        labels = labels(4:length(labels));
        
    elseif isempty(ip.Results.nodeLabels) && isempty(ip.Results.iconPath) ...
            && ~isempty(ip.Results.nodeColors)
        
        labels = ip.Results.nodeColors;
        
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        s = length(RDM);
        labels = [1:s];
    end
    
    img = figure;
    [Y eigs] = cmdscale(RDM);
    [r c] = size(Y);
    
    % set dimensions
    xDim = ip.Results.dimensions(1);
    yDim = ip.Results.dimensions(2);
    if or((xDim<1 | xDim>r), (yDim<1 | yDim>r))
        error('Both xDim and yDim must be between 1 and length(RDM)');
    end
    
    % Set plot axis limits
    xMax = max(Y(:,xDim));
    xMin = min(Y(:,xDim));
    xMax = xMax + (xMax-xMin)/10;
    xMin = xMin - (xMax-xMin)/10;
    
    yMax = max(Y(:,yDim));
    yMin = min(Y(:,yDim));
    yMax = yMax + (yMax-yMin)/10;
    yMin = yMin - (yMax-yMin)/10;
    
    if isempty(ip.Results.xLim)
        xlim([xMin xMax]);
    else
        xlim(ip.Results.xLim);
    end
    if isempty(ip.Results.yLim)
        ylim([yMin yMax]);
    else
        ylim(ip.Results.yLim);
    end
     % x-axis, y-axis label
    xlabel(['Dimension ' num2str(ip.Results.dimensions(1))], 'FontWeight', 'bold');
    ylabel(['Dimension ' num2str(ip.Results.dimensions(2))], 'FontWeight', 'bold'); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
    
        disp('CASE: COLOR AND NODE')
        for i = 1:r

            % artificial method of setting siz
%             plot( Y(i,1) ,Y(i,2) , 's', 'MarkerSize', 15, 'LineWidth', 2, ....
%                 'MarkerEdgeColor', 'k');
            text( Y(i,xDim), Y(i,yDim), char(ip.Results.nodeLabels(i)), ...
                'Color', ip.Results.nodeColors{i}, ...
                'FontWeight', 'bold', 'FontSize', 30 ...
            );
            hold on
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
        disp('CASE: NODE')
        for i = 1:length(RDM)
            text(Y(i,xDim), Y(i,yDim), ip.Results.nodeLabels(i), ...
                'FontSize', 30);
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR AND IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
        labels = dir(ip.Results.iconPath);
        labels = labels(4:length(labels));
        for i = 1:length(labels)
            hold on;
            [thisIcon map] = imread([labels(i).folder '/' labels(i).name]);
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            if ~isempty(map)
                thisIcon = ind2rgb(thisIcon, map);
            else
                thisIcon = double(thisIcon)/255;
            end
            
            if length(size(thisIcon)) == 2
                disp('KSJDKAJSNDKA')
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
            end
            
            % Resize to 40*40 square
            if height > width
                thisIcon = imresize(thisIcon, [30 NaN]);
            else
                thisIcon = imresize(thisIcon, [NaN 30]);
            end
            
            plotLength = (max(Y(:,xDim)) - min(Y(:,xDim)))/12;
            plotHeight = (max(Y(:,yDim)) - min(Y(:,yDim)))/12;


            rectangle('Position', [Y(i,xDim)-plotLength-.1*plotLength, ...
                Y(i,yDim)-plotHeight-.1*plotLength, plotLength+.2*plotLength, ...
                plotHeight+.2*plotLength], 'faceColor', ...
                ip.Results.nodeColors{i}, 'EdgeColor', ip.Results.nodeColors{i});
            
            imagesc([Y(i,xDim), Y(i,xDim) - plotLength], ...
                [Y(i,yDim), Y(i,yDim) - plotHeight], thisIcon);
        end
        
       
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
        labels = dir(ip.Results.iconPath);
        labels = labels(4:length(labels));
        for i = 1:length(labels)
            hold on;
            [thisIcon map] = imread([labels(i).folder '/' labels(i).name]);
            [height width] = size(thisIcon);
            %convert thisIcon to scale 0~1
            if ~isempty(map)
                thisIcon = ind2rgb(thisIcon, map);
            else
                thisIcon = double(thisIcon)/255;
            end
            
            if length(size(thisIcon)) == 2
                disp('KSJDKAJSNDKA')
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);
            end
            
            % Resize to 40*40 square
            if height > width
                thisIcon = imresize(thisIcon, [40 NaN]);
            else
                thisIcon = imresize(thisIcon, [NaN 40]);
            end
            
            plotLength = (max(Y(:,xDim)) - min(Y(:,xDim)))/12;
            plotHeight = (max(Y(:,yDim)) - min(Y(:,yDim)))/12;
            disp(i)

            imagesc([Y(i,xDim), Y(i,xDim) + plotLength], ...
                [Y(i,yDim), Y(i,yDim) - plotHeight], thisIcon);
        end
        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
        for i = 1:r
            plot( Y(i,xDim) ,Y(i,yDim) , 'o', 'MarkerSize', 15, 'LineWidth', 4, ...
                'MarkerEdgeColor', ip.Results.nodeColors{i}, ...
                'MarkerFaceColor', ip.Results.nodeColors{i});
            hold on
        end
        
    end
    
    
    
end


    
    