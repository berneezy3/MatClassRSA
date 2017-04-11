function y = createMDSplot(distMat, varargin)

    ip = inputParser;
    ip.FunctionName = 'createMDSplot';
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
    
    
    Y = cmdscale(distMat);
    [r c] = size(Y);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CASE: COLOR AND NODE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(ip.Results.nodeColors) && ~isempty(ip.Results.nodeLabels) ...
            && isempty(ip.Results.iconPath)
    
        disp('CASE: COLOR AND NODE')
        for i = 1:r
            plot( Y(i,1) ,Y(i,2) , 's', 'MarkerSize', 15, 'LineWidth', 4, ....
                'MarkerEdgeColor', ip.Results.nodeColors(i));
            hold on
            text( Y(i,1), Y(i,2), ip.Results.nodeLabels(i));
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
        
        for i = 1:r
            plot( Y(i,1) ,Y(i,2) , 's', 'MarkerSize', 15, 'LineWidth', 4, ....
                'MarkerEdgeColor', ip.Results.nodeColors(i));
            hold on
        end
        
    end
    
end


    
    