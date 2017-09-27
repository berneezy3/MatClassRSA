function img = plotDendrogram(RDM, varargin)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% plotDendrogram(RDM, varargin)
% ------------------------------------------------
% Bernard Wang - April 23, 2017
%
% This function creates a dendrogram plot with the distance matrix
% passed in.
%
% INPUT ARGS:
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
% - 'iconPath': a directory containing imaAges used to label, in which the
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
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('distMethod', 'average', @(x) any(validatestring(x,  ...
        expectedDistMethod)));
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    ip.addParameter('orientation', 'down', @(x) any(validatestring(x, ...
        expectedOrientation)));
    ip.addParameter('reorder', [], @(x) assert(length(x) == length(RDM)));
    %ip.addParameter('maxLeafs', 0, @(x) assert(x >= 0 && isnumeric(x)) );
%     ip.addParameter('plotHeight', '', @(x) assert(isnumeric(x)));
    ip.addParameter('yLim', '', @(x) assert(isequal(size(x), [2 1]) || ...
        isequal(size(x), [1 2]),  'ylim must be length 2 vector'));
    ip.addParameter('textRotation', 0, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('lineWidth', 2, @(x) assert(isnumeric(x), ...
        'textRotation must be a numeric value'));
    ip.addParameter('lineColor', 'black');
    ip.addParameter('iconSize', 40);
    
    parse(ip, RDM,varargin{:});
    
    RDMmod = RDM(tril(true(size(RDM)),-1))';
    tree = linkage(RDMmod, ip.Results.distMethod);
    [r c] = size(tree);
    
    img = figure;
    if (~isempty(ip.Results.reorder))
        [d T P] = dendrogram(tree, 0, 'reorder', ip.Results.reorder);
    else
        % all leaf nodes
        [d T P] = dendrogram(tree, 0);
    end
    
    set(d ,'LineWidth',  ip.Results.lineWidth, 'Color', ip.Results.lineColor);
    %set(gca,'xtick',[]);
    if length(ip.Results.nodeLabels) >= 1
        xticklabels(ip.Results.nodeLabels);
    end
    

    set(gca,'FontSize',20);
    %set(gca,'xtick',[]);
    set(gcf,'color',[1 1 1]);
    
    % Set dendrogram Y axis height
    if ~isempty(ip.Results.yLim)
        ylim(ip.Results.yLim);
    end
    
    %%%%%%%%%%%%%%%%%%%%
    % CONVERT TO MATRIX
    %%%%%%%%%%%%%%%%%%%%
%     F = getframe(gcf);
%     dendrogramImg = im2double(F.cdata);
    
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
%         set(gca,'xtick',[]);
%         set(gca,'ytick',[]);
%         hold on;
%         return;
    end

    %iconPath(1).name


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels)
        disp('CASE: COLOR NODE');
        %
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');

        for i = 1:length(labels)
            if i <= length(ip.Results.nodeColors)
                label = labels(P(i));
                t = text(xTickCoords(i, 1), xTickCoords(i, 2), label, ...
                    'HorizontalAlignment', 'center');
                t.Rotation = ip.Results.textRotation;
                t.Color = ip.Results.nodeColors{P(i)};
                t(1).FontSize = 25;
            else

            end

            
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) &&  ~isempty(ip.Results.nodeLabels)

        disp('CASE: LABEL');
        set(gca,'xTickLabel', '');


%         labels = NaN{1,length(RDM)};
%         for i = 1:length(RDM)
%             labels(i) = ip.Results.nodeLabels{P(i)};
%         end
        
        set(gca,'xTickLabel', ip.Results.nodeLabels);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeLabels) && ~isempty(ip.Results.iconPath)
        
        disp('CASE: IMAGE');
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');
        pos = get(gca,'position');
        x = pos(1);
        y = pos(2);
        dlta = (pos(3)) / (length(xTickCoords) + 1);
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
                lblAx = axes('parent',gcf,'position',[pos(1)+dlta*i - ...
                    ip.Results.iconSize/2/figWidth,y-ip.Results.iconSize/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                imagesc(thisIcon,'parent',lblAx);
                axis(lblAx,'off');
            else
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        disp('CASE: COLOR');
        
        set(gca,'xTickLabel', '');
        xTickCoords = getTickCoord;
        set(gca,'xTickLabel', '');
        pos = get(gca,'position');
        x = pos(1);
        y = pos(2);
        dlta = (pos(3)) / (length(xTickCoords) + 1);
        
        figPos = get(gcf, 'position');
        figWidth = figPos(3);
        figHeight = figPos(4);
        
        for i = 1:length(labels)

            if i <= length(labels)
                lblAx = axes('parent',gcf,'position',[pos(1)+dlta*i - ...
                    ip.Results.iconSize/2/figWidth,y-ip.Results.iconSize/figHeight, ...
                    ip.Results.iconSize/figWidth, ip.Results.iconSize/figHeight]);
                rectangle('FaceColor', labels{i});
                axis(lblAx,'off');
            else
            end
        end
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: NONE (Default number labels)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        
        disp('CASE: DEFAULT LABELS');
        % Do NOTHING

        
        
    end
    
    hold on;
     
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
