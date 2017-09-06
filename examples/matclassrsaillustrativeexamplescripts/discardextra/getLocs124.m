function locs124 = getLocs124()

% locs124 = getLocs124()
% --------------------------------------------
% This function returns the locations of 124 channels for topoplots.
% No vertex (Cz)
% Usage:
% locs124 = getLocs124();
% topoplot(valuesToPlot, locs124);
%
% (c) Bernard Wang and Blair Kaneshiro, 2017. 
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com

locFile = 'Hydrocel GSN 128 1.0.sfp'
ll = readlocs(locFile);
locs124 = ll([4:127]);