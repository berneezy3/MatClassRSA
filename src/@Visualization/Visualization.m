classdef Visualization
% This class contains the functions to visualize EEG data.  
%
% To create a visualization plot, you must first create a instance of the 
% MatClassRSA object, then access the  "Visualization" member variable  
% to call the function of interest.  Functions of this class may also 
% require a Representational Dissimilarity Matrix (RDM) or a Confusion Matrix 
% (CM) to be passed in. Below is an example call to the function 
% plotMDS():
%
% RSA = MatClassRSA;
% C = RSA.Classification.crossValidateMulti(X, Y);
% RDM = RSA.RDM_Computation.computeClassificationRDM(C.CM, 'CM')
% plotMDS(RDM);
%
% Below are the list of classification functions contained in this class:
%   - plotDendrogram()
%   - plotMatrix()
%   - plotMDS()  
%   - plotMST()
 
    
   properties
   end
   methods
   end
end
