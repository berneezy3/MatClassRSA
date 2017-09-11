function y = endswith(a, b)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
    if (length(a) < length(b))
        y = 0;
        return
    elseif (length(a) == length(b))
        if strcmp(a,b)
            y = 1;
            return
        else
            y=0;
            return
        end
    end

    for i=1:length(b)
        if a(length(a)-(length(b)-i)) ~= b(i)
            y = 0;
            return
        end
    end
    
    y=1
end