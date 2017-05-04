function y = plotMDS(distMat, varargin)
% createDendrogram(distMat, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function creates a dendrogram plot with the distance matrix
% passed in.
%
% Required inputs:
% - distMat: A distance matrix.  Diagonals must be 0, and must be
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

    ip = inputParser;
    ip.FunctionName = 'plotMDS';
    ip.addRequired('distMat',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        
        labels = ip.Results.nodeLabels;
        
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        
        labels = dir(ip.Results.iconPath);
        labels = labels(4:length(labels));
        
    elseif isempty(ip.Results.nodeLabels) && isempty(ip.Results.iconPath) && ~isempty(ip.Results.nodeColors)
        
         labels = ip.Results.nodeColors;
        
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        return;
    end
    
    
    [Y eigs] = cmdscale(distMat);
    [r c] = size(Y);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
    
        disp('CASE: COLOR AND NODE')
        for i = 1:r
            plot( Y(i,1) ,Y(i,2) , 's', 'MarkerSize', 15, 'LineWidth', 2, ....
                'MarkerEdgeColor', 'w');
            text( Y(i,1), Y(i,2), ip.Results.nodeLabels(i), ...
                'color', ip.Results.nodeColors(i), ...
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
        for i = 1:length(distMat)
            text(Y(i,1), Y(i,2), ip.Results.nodeLabels(i));
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
            
            plotLength = (max(Y(:,1)) - min(Y(:,1)))/12;
            plotHeight = (max(Y(:,2)) - min(Y(:,2)))/12;


            rectangle('Position', [Y(i,1)-plotLength-.1*plotLength, Y(i,2)-plotHeight-.1*plotLength, plotLength+.2*plotLength, plotHeight+.2*plotLength], ...
                        'faceColor', ip.Results.nodeColors(i), 'EdgeColor', ip.Results.nodeColors(i));
            
            imagesc([Y(i,1), Y(i,1) - plotLength], ...
                [Y(i,2), Y(i,2) - plotHeight], thisIcon);
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
            
            plotLength = (max(Y(:,1)) - min(Y(:,1)))/12;
            plotHeight = (max(Y(:,2)) - min(Y(:,2)))/12;
            disp(i)

            imagesc([Y(i,1), Y(i,1) - plotLength], ...
                [Y(i,2), Y(i,2) - plotHeight], thisIcon);
        end
        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
        for i = 1:r
            plot( Y(i,1) ,Y(i,2) , 'o', 'MarkerSize', 15, 'LineWidth', 4, ...
                'MarkerEdgeColor', ip.Results.nodeColors(i), ...
                'MarkerFaceColor', ip.Results.nodeColors(i));
            hold on
        end
        
    end
    
end


    
    