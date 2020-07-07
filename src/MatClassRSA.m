classdef MatClassRSA
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
