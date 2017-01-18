function printPhoto(filename,varargin)
    
    p = inputParser;
    
    defaultFinish = 'glossy';
    validFinishes = {'glossy','matte'};
    checkFinish = @(x) any(validatestring(x,validFinishes));

    defaultColor = 'RGB';
    validColors = {'RGB','CMYK'};
    checkColor = @(x) any(validatestring(x,validColors));

    defaultWidth = 6;
    defaultHeight = 4;

    addRequired(p,'filename',@ischar);
    addOptional(p,'finish',defaultFinish,checkFinish);
    addOptional(p,'color',defaultColor,checkColor);
    addParameter(p,'width',defaultWidth,@isnumeric);
    addParameter(p,'height',defaultHeight,@isnumeric);
    p.KeepUnmatched = true;
    
    parse(p,filename,varargin{:});
    
    disp(['File name: ',p.Results.filename]);
    disp(['Finish: ', p.Results.finish]);

    if ~isempty(fieldnames(p.Unmatched))
       disp('Extra inputs:');
       disp(p.Unmatched);
    end
    if ~isempty(p.UsingDefaults)
       disp('Using defaults: ');
       disp(p.UsingDefaults);
    end
    
    %{
    printPhoto('myfile.jpg');
    
    printPhoto(100);
    
    printPhoto('myfile.jpg','satin');
    
    printPhoto('myfile.jpg','height',10,'width',8);
    
    printPhoto('myfile.gif','glossy','CMYK');  % positional

    printPhoto('myfile.gif','color','CMYK');   % name and value
    %}
end