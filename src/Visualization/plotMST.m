function plotMST(distMat, varargin)
% plotMST = plotMST(distMat, varargin)
% ------------------------------------------------
% Bernard Wang - April 28, 2017
%
% This function creates a minimum spanning tree plot with the distance 
% matrix passed in.  
%
% Required Inputs:
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
    ip.addRequired('distMat',@ismatrix);
    options = [1, 0];
    ip.addParameter('nodeColors', [], @(x) isvector(x)); 
    ip.addParameter('nodeLabels', [], @(x) isvector(x));
    ip.addParameter('iconPath', '');
    parse(ip, distMat,varargin{:});
    

    % set up the nodes and connections between
    [r c] = size(distMat);
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
            weights(index) = distMat(sourceNodes(index), destNodes(index));
            index = index - 1;
        end
    end

%     disp(sourceNodes);
%     disp(destNodes);
%     disp(weights);
%     
    
    
    % convert int array into char cell array
    
    
    G = graph(sourceNodes, destNodes,weights);
    disp(G);
    %p = plot(G,'EdgeLabel',G.Edges.Weight);
    [T,pred] = minspantree(G);
    disp(T.Edges);
    disp(T.Edges.Weight);
    plot(T, 'EdgeLabel', T.Edges.Weight)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
    
        disp('CASE: COLOR AND NODE')
        plt = MSTplothelper(sourceNodes, destNodes, weights, ip.Results.nodeLabels);
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
    
    
    
end

function plt = MSTplothelper(sourceNodes, destNodes, weights, nodeLabels)
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
        plt = plot(T, 'EdgeLabel', T.Edges.Weight)
end

function MSTcolorhelper(nodeLabels, nodeColors, graph)
    for i = 1:length(nodeColors)
        highlight(graph, nodeLabels(i), 'NodeColor', nodeColors(i))
    end
end