function y = plotDendrogram(distMat, varargin)
% plotDendrogram(distMat, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function creates a dendrogram plot with the distance matrix
% passed in.
%
% INPUT ARGS:
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
%   - linkage order - inorder w/crossing, best order w/o crossing, dist
%   order
%   - flip horizontal
%   - make sure the side thin
%   - make sure the dendrogram is in the correct order, not the order of
%   the dist matrix

    

    expectedDistMethod = {'average', 'centroid', 'complete', 'median', 'single', ...
        'ward', 'weighted'};
    expectedOrientation = {'up', 'down', 'left', 'right'};

    ip = inputParser;
    ip.FunctionName = 'plotDendrogram';
    ip.addRequired('distMat',@ismatrix);
    options = [1, 0];
    ip.addParameter('distMethod', 'average', @(x) any(validatestring(x,  ...
        expectedDistMethod)));
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    ip.addParameter('orientation', 'down', @(x) any(validatestring(x, ...
        expectedOrientation)));
    ip.addParameter('reorder', [], @(x) assert(x == length(distMat)));
    ip.addParameter('maxLeafs', 30, @(x) assert(isPosInt(x)) );
    ip.addParameter('plotHeight', '', @(x) assert(isnumeric(x)));
    ip.addParameter('yLim', '', @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'ylim must be length 2 vector'));
    ip.addParameter('textRotation', 0, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    
    parse(ip, distMat,varargin{:});
    
    tree = linkage(distMat, ip.Results.distMethod);
    [r c] = size(tree);
    [d T P] = dendrogram(tree, 0);

%     set(gca,'xtick',[]);
    if length(ip.Results.nodeLabels) >= 1
        xticklabels(ip.Results.nodeLabels);
    else
        set(gca,'xtick',[]);
    end
    
    set(gca,'FontSize',20);
    set(gca,'xtick',[]);
    set(gcf,'color',[1 1 1]);
    
    % Set dendrogram Y axis height
    if ~isempty(ip.Results.yLim)
        ylim(ip.Results.yLim);
    end
    
    %%%%%%%%%%%%%%%%%%%%
    % CONVERT TO MATRIX
    %%%%%%%%%%%%%%%%%%%%
    F = getframe(gcf);
    dendrogramImg = im2double(F.cdata);

    %imagesc(dendrogramImg);
    addpath(ip.Results.iconPath);
    
    %check that either labels or iconPath has the same amount as nodeColors
    
    % check which set of labels to use
    % alphanumeric labels
    if ~isempty(ip.Results.nodeLabels)
        labels = ip.Results.nodeLabels;
    %picture labels
    elseif ~isempty(ip.Results.iconPath)
        labels = getImageFiles(ip.Results.iconPath);
    %color labels
    elseif isempty(ip.Results.nodeLabels) && isempty(ip.Results.iconPath) && ~isempty(ip.Results.nodeColors)
         labels = ip.Results.nodeColors;
    else %no labels specified
        set(gca,'xtick',[]);
        set(gca,'ytick',[]);
        hold on;
        return;
    end

    %iconPath(1).name

    image(dendrogramImg);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)

        disp('CASE: COLOR NODE');
        for i = 1:length(labels)

            split = (1449-205)/(r+2);
            centerX =  208 + split * i;
            centerY =  960;
            width = 40;
            height = 40;
            if i <= length(ip.Results.nodeColors)
                label = labels(P(i));
                t = text(centerX-width/2, centerY-height, label);
                t.Rotation = ip.Results.textRotation;
                t.Color = char(ip.Results.nodeColors(P(i)));
                t(1).FontSize = 25;
            else

            end

            
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)

        disp('CASE: NODE');
        for i = 1:length(labels)

            split = (1449-205)/(r+2);
            centerX =  208 + split * i;
            centerY =  960;
            width = 40;
            height = 40;
            if i <= length(ip.Results.nodeLabels)
                label = labels(P(i))
                disp(centerX)
                t = text(centerX-width/2, centerY-height, label);
                t.Rotation = ip.Results.textRotation;
                t.Color = 'black';
                t(1).FontSize = 14;
            end

            
        end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR AND IMAGE OR IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeLabels) && ~isempty(ip.Results.iconPath)
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
                thisIcon = imresize(thisIcon, [40 NaN]);
            else
                thisIcon = imresize(thisIcon, [NaN 40]);
            end

            % Add 3rd(color) dimension if there is none
            if length(size(thisIcon)) == 2
                disp('KSJDKAJSNDKA')
                thisIcon = cat(3, thisIcon, thisIcon, thisIcon);

            end
            
            split = round((1449-208)/(r+2));
            centerX =  208 + split * i;
            centerY =  960;
            width = 40;
            height = 40;
            cWidth = 58;
            cHeight = 58;
            if i <= length(labels)
%                 rect = rectangle('Position',[centerX-cWidth/2, centerY-cHeight, cWidth, cHeight], ...
%                 'FaceColor', char(ip.Results.nodeColors(P(i))));
%                 dendrogramImg(centerY-cHeight:centerY-1, centerX-cWidth/2:centerX+cWidth/2-1, 1:3) = rect;
                if ~isempty(ip.Results.nodeColors)
                    dendrogramImg = insertShape(dendrogramImg, 'FilledRectangle', ...
                        [centerX-cWidth/2, centerY-cHeight, cWidth, cHeight], ...
                        'color', colorShort2Long(char(ip.Results.nodeColors(P(i)))));
                end
                dendrogramImg(centerY-height-9:centerY-1-9, centerX-width/2:centerX+width/2-1, 1:3) ...
                    = thisIcon;
                image(dendrogramImg);
                label = labels(P(i));
            else
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        disp('CASE: COLOR');
        for i = 1:length(labels)
            
            split = round((1449-208)/(r+2));
            centerX =  208 + split * i;
            centerY =  960;
            width = 40;
            height = 40;
            if i <= length(ip.Results.nodeColors)
                %insertShape(dendrogramImg, 'Rectangle', [centerX-width/2 centerY-height width height]);
            end
        end
         
    end
     
    
    set(gca,'xtick',[]);
    set(gca,'ytick',[]);

    hold on
     
end

%helper function to customDendrogram
function y = colorSquare(original, xCorner, yCorner, width, height)
    
    

end

function y = isPosInt(x)

    if floor(x)==x && x>0
        y = 1;
    else
        y = 0;
    end
    

end
