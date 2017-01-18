% pValues.m
% -----------
% Blair
% January 30 2012

rate = 13.16;  % number between 0-100
chance = 1/12;
trialsPerFold = floor(108*12/10);


pVal = 1-binocdf(floor(trialsPerFold*rate/100), trialsPerFold, chance)