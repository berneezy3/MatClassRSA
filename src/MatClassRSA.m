classdef MatClassRSA
% -------------------------------------------------------------------------
% RSA = MatClassRSA;
% -------------------------------------------------------------------------
% Bernard - July. 12, 2020
%
% Main class for MatClassRSA.  This class contains 5 member variables 
% (also known as class properties): Classification, Preprocessing, 
% RDM_Copmutation, Reliability, Visualization.  The data processing 
% functions are organized via these 5 member variables.  Please check the 
% manual or the member variable docstrings for a complete list of functions 
% for each category.  
%
% To call a function, one would need to: first create a MatClassRSA object,
% then access the relevent member variable containing the function of 
% interest then finally make a call to the original function of interest.  
% For example, a call to the classification function crossValidateMulti() 
% would look like this:
%
% RSA = MatClassRSA;
% RSA.Classification.crossValidateMulti(X, Y);

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

   properties
       Preprocessing;
       Classification;
       RDM_Computation;
       Reliability;
       Visualization;
   end
   methods
       function this = MatClassRSA()
           this.Preprocessing = Preprocessing;
           this.Classification = Classification;
           this.RDM_Computation = RDM_Computation;
           this.Reliability = Reliability;
           this.Visualization = Visualization;
       end
   end
end
