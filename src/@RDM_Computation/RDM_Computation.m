classdef RDM_Computation
% This class contains the functions that generate representational 
% dissimilarity matrices (RDMs).  
%
% To compute an RDM, you must first create a instance of the MatClassRSA 
% object, then access the  "RDM_Computation" mebmer variable of the MatClassRSA 
% object to call the function of interest.  Functions of this class may also 
% require EEG data or a classification confusion matrix (generated by the 
% functions in the "Classification" member variable of MatClassRSA). Below 
% is an example call to the function computeClassificationRDM():
%
% RSA = MatClassRSA;
% C = RSA.Classification.crossValidateMulti(X, Y);
% RDM = RSA.RDM_Computation.computeClassificationRDM(C.CM, 'CM')
%
% Below are the list of classification functions contained in this class:
%   - computeClassificationRDM()
%   - computeEuclideanRDM()
%   - computePearsonRDM()    
    
   properties
   end
   methods
       function obj = classification
       end
   end

end
