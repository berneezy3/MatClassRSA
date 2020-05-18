classdef MatClassRSA
   properties
       preprocess;
       classify;
       computeRDM;
       computeReliability;
       visualize;
   end
   methods
       function this = MatClassRSA()
           this.preprocess = Preprocessing;
           this.classify = Classification;
           this.computeRDM = RDM_Computation;
           this.computeReliability = Reliability;
           this.visualize = Visualization;
       end
   end
end
