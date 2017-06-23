Ifunction overlayImage(original, new, X, Y, width, height)
% overlayImage(original, new, X, Y, width, height)
% ------------------------------------------------
% Bernard - April 12, 2017
%
% This function overlays on image onto another image
%
% INPUT ARGS:
%   original - The image which will be overlayed by the new image
%   new - The new image to be overlayed on the original image
%   X - The middle pixel index for the new image to be overlayed
%   Y - The top pixel index for the new image to be overlayed
%   width - self-explanatory
%   height - self-explanatory
%
% OUTPUT ARGS:
% - N/A
%
% EXAMPLE:
%
% TODO:
%

    
    original( Y-height:Y-1, X-width/2:X+width/2, 1:3) = new;

end