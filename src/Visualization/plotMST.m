function img = plotMST(RDM, varargin)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% plotMST = plotMST(RDM, varargin)
% ------------------------------------------------
% Bernard Wang - April 28, 2017
%
% This function creates a minimum spanning tree plot with the distance 
% matrix passed in.  
%
% Required Inputs:
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
% Outputs:
% - None
%
% Notes:
%   TODO - find out how to plot images on the coordinates
%        - turn off labels for color case
%    

    % parse inputs
    ip = inputParser;
    ip.FunctionName = 'plotMST';
    ip.addRequired('RDM',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    ip.addParameter('edgeLabelSize', 15, @(x) isnumeric(x));
    ip.addParameter('nodeLabelSize', 15, @(x) isnumeric(x));
    ip.addParameter('nodeLabelRotation', 50, @(x) isnumeric(x));
    ip.addParameter('roundEdgeLabel', 4, @(x) isnumeric(x));

    parse(ip, RDM, varargin{:});
    

    % set up the nodes and connections between
    [r c] = size(RDM);
    numEdges = ((r-1) + (r-1)^2)/2;
    numNodes = r;
    sourceNodes = NaN(numEdges, 1);
    destNodes = NaN(numEdges, 1);
    weights = NaN(numEdges, 1);
    index = numEdges;
    for i = 1:numNodes-1
        for j = 1:i
            sourceNodes(index) = numNodes - i;
            destNodes(index) = numNodes + 1 - j;
            weights(index) = RDM(sourceNodes(index), destNodes(index));
            index = index - 1;
        end
    end

%     disp(sourceNodes);
%     disp(destNodes);
%     disp(weights);
%     
    
    
    % convert int array into char cell array
    
    img = figure;
    G = graph(sourceNodes, destNodes,weights);
    
    disp(G);
    %p = plot(G,'EdgeLabel',G.Edges.Weight);
    [T,pred] = minspantree(G);
    disp(T.Edges);
    disp(T.Edges.Weight);
    P = plot(T, 'EdgeLabel', T.Edges.Weight);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
    
        disp('CASE: COLOR AND NODE')
        plt = MSTplothelper(sourceNodes, destNodes, weights, ...
            ip.Results.nodeLabels, ip);
        MSTcolorhelper(ip.Results.nodeLabels, ip.Results.nodeColors, plt);


        
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
        
        disp('CASE: NODE')
        MSTplothelper(sourceNodes, destNodes, weights, ip.Results.nodeLabels)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR AND IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
       
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: IMAGE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif isempty(ip.Results.nodeColors) && ~isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % CASE: COLOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif ~isempty(ip.Results.nodeColors) && isempty(ip.Results.iconPath) ...
            && isempty(ip.Results.nodeLabels)
        
        disp('CASE: COLOR AND NODE')
        plt = MSTplothelper(sourceNodes, destNodes, weights, ip.Results.nodeLabels);
        MSTcolorhelper(ip.Results.nodeLabels, ip.Results.nodeColors, plt);
        
        
    end
    
    hold on;
    
end

function plt = MSTplothelper(sourceNodes, destNodes, weights, nodeLabels, ip)
%--------------------------
% helper function to plot the MST 
% 
% args - 
%   sourceNodes - source nodes for the connections
%   destNodes - destination nodes for the connections
%   weights - the weights of each connection
%   nodeLabels - actual label of each node, as opposed to number ID
        sourceLabels = {};
        destLabels = {};
        for i = 1:length(sourceNodes)
            sourceLabels  = [sourceLabels nodeLabels(sourceNodes(i))];
            destLabels = [destLabels nodeLabels(destNodes(i))];
        end
        
        G = graph(sourceLabels, destLabels, weights);
        disp(G);
        [T,pred] = minspantree(G);
        disp(T.Edges);
        disp(T.Edges.Weight);
        plt = plot(T);
        
        nl = plt.NodeLabel;
        plt.NodeLabel = '';
        xd = get(plt, 'XData');
        yd = get(plt, 'YData');
        
        text(xd, yd, nl,  'FontSize',  ip.Results.nodeLabelSize,...
            'HorizontalAlignment','left', 'VerticalAlignment','middle', ...
            'HorizontalAlignment', 'left', ...
            'Rotation', ip.Results.nodeLabelRotation);
        
        % make table of edges
        [edgeR edgeC] = size(T.Edges.EndNodes);
        edgeCoord = NaN(edgeR, edgeC);
        format shortg;
        T.Edges.Weight = round(T.Edges.Weight, 3);
        for i = 1:edgeR
            startNode = findNodeWithLabel(nl, T.Edges.EndNodes(i,1));
            endNode = findNodeWithLabel(nl, T.Edges.EndNodes(i,2));
            edgeCoord(i,1) = (xd(startNode) + xd(endNode))/2;
            edgeCoord(i,2) = (yd(startNode) + yd(endNode))/2;
            ang = findAngle(xd(startNode), yd(startNode), xd(endNode), yd(endNode))
            text((xd(startNode) + xd(endNode))/2 ,(yd(startNode) + yd(endNode))/2, ...
                 num2str(T.Edges.Weight(i)), 'HorizontalAlignment','center', ...
                 'Rotation', ang, 'FontSize', ip.Results.edgeLabelSize, ...
                 'VerticalAlignment','top');
        end
        format;
        %make table containing coords for edges

        edgeCoord = NaN(edgeR, edgeC);
        %
        for i = 1:edgeR
%             edgeCoord(i,1) = find(not(cellfun('isempty',strfind(nl,'IO'))));
%             edgeCoord(i,2) = 
        end

end

function MSTcolorhelper(nodeLabels, nodeColors, graph)
    for i = 1:length(nodeColors)
        highlight(graph, nodeLabels(i), 'NodeColor', nodeColors{i}, 'markerSize', 15);
    end
end

function y = findNodeWithLabel(labels, label)
    y = find(not(cellfun('isempty',strfind(labels,label))));
end

function y = findAngle(x1, y1, x2, y2)
    v1 = [x1-x2, y1-y2];
    m = v1(2)/v1(1);
    y = atan(m) * 180 / pi;
    disp(y)
    if rem(y,90) ~= 0
        if y > 0
            y = 90 - y;
        else
            y = 270- y;
        end
    elseif (y > 90 && y <= 270) | (y >= -270 && y < -90)
        y = y + 180;
    elseif  y == 90 
        y = y+180;
    end
    %y = abs((a1>pi/2)*pi-a1);
end