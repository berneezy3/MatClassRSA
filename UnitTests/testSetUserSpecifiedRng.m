% testSetUserSpecifiedRng.m
% -----------------------------
% Blair - August 14, 2019

clear all; close all; clc
% Be sure to run the helper functions at the bottom before running other
% cells

%% Case: Empty input: Should set to rng=('shuffle', 'twister')
clc
disp('--------- No input ---------')
testUserSpecifiedRng()

%%
clc
disp('--------- NaN input ---------')
testUserSpecifiedRng(NaN)

%%
clc
disp('--------- Empty input ---------')
testUserSpecifiedRng([])

%% Case: Single RNG STRUCT input (acceptable)

clc
disp('--------- Single input (numeric) ---------')
rng(12345, 'combRecursive')
disp('--- User-specified rng to be entered: ---')
thisRng = rng
disp('-----------------------------------------')
testUserSpecifiedRng(thisRng)
clear thisRng

%% Case: Single RNG STRUCT input (unacceptable)

clc
disp('--------- Single input (numeric) ---------')
thisBadStruct.X = 1:10;
thisBadStruct.Y = 11:20;
thisBadStruct
testUserSpecifiedRng(thisBadStruct)
clear thisBadStruct

%% Case: Single input (acceptable)

clc
disp('--------- Single input (numeric) ---------')
testUserSpecifiedRng(10)

%%
clc
disp('--------- Single input (string) ---------')
testUserSpecifiedRng('shuffle')

%%
clc
disp('--------- Single input (default) ---------')
testUserSpecifiedRng('default')

%%
clc
% Edge case: User incorrectly entered single string in double quotes
disp('--------- Single input (badly formatted string) ---------')
testUserSpecifiedRng("shuffle")

%% Case: Single input (unacceptable)

clc
disp('--------- Single input (numeric) ---------')
testUserSpecifiedRng(-10)

%%
clc
disp('--------- Single input (bad string) ---------')
testUserSpecifiedRng('blah!')

%% Case: Dual input, string array (acceptable)

clc
disp('--------- Dual input (numeric and string) ---------')
testUserSpecifiedRng([10, "philox"])

%%
clc
disp('--------- Dual input (string numeric and string) ---------')
testUserSpecifiedRng(["10", "philox"])

%%
clc
disp('--------- Dual input (two strings) ---------')
testUserSpecifiedRng(["shuffle", "philox"])

%% Case: Dual input, string array (unacceptable)

clc
disp('--------- Dual input (''default'' and string) ---------')
testUserSpecifiedRng(["default", "philox"])

%%
clc
disp('--------- Dual input (forgot double quotes) ---------')
testUserSpecifiedRng([0, 'philox'])

%%
clc
disp('--------- Dual input (bad first argument) ---------')
testUserSpecifiedRng(["blah", "philox"])

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng([0, "blah"])

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng(["shuffle", "blah"])

%% Case: Dual input, cell array (acceptable)

clc
disp('--------- Dual input (numeric and string) ---------')
testUserSpecifiedRng({10, 'philox'})

%%
clc
disp('--------- Dual input (two strings) ---------')
testUserSpecifiedRng({'shuffle', 'philox'})

%% Case: Dual input, cell array (unacceptable)

clc
disp('--------- Dual input (''default'' and string) ---------')
testUserSpecifiedRng({'default', 'philox'})

%%
clc
disp('--------- Dual input (bad first argument) ---------')
testUserSpecifiedRng({'blah', 'philox'})

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng({0, 'blah'})

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng({'shuffle', 'blah'})

%%
clc
disp('--------- Dual input (entering number as string) ---------')
testUserSpecifiedRng({'20', 'philox'})

%% Helper functions
function testUserSpecifiedRng(input)
disp('Before:')
dummyRng;
disp('After:')
if nargin < 1, setUserSpecifiedRng();
else setUserSpecifiedRng(input); end
rng
disp(' ')
end

function dummyRng()
rng(234, 'threefry'); rng
end
