classdef Preprocessing
% This class contains all the data preprocessing related functions of
% MatClassRSA.  Typically, EEG data is first processed by this functions
% contained in this class, then passed to the "Classification" class to 
% generate confusion matrices.  
%
% To call a preprocessing function, you must first create a instance of
% the MatClassRSA object, access the Preprocessing member variable, then
% call the function of interest.  Below is an example call to the function
% shuffleData():
%
% RSA = MatClassRSA;
% RSA.Preprocessing.shuffleData(X, Y);
%
% Below are the list of classification functions contained in this class:
%   - averageTrials()
%   - shuffleData()
%   - noiseNormalization()

   properties
   end
   methods
   end
end
