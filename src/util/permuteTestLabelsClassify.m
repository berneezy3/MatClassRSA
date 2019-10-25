function accuracy = permuteTestLabelsClassify(testLabels, ip)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% permuteTestLabelsClassify(testLabels, ip)
% --------------------------------
% Bernard Wang, Sept 28, 2019
% 
% INPUT ARGS:
%   - testLabels: 
%   - ip: 
%
% OUTPUT ARGS:
%   - accuracy
%.
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


    for i = 1:ip.Results.permutations
        
        %permute the test labels
        % (check if randperm is seeded every single time differently)
        % (yes, it is)
        disp(['calculating ' num2str(i) ' of '...
            num2str(ip.Results.permutations) ' permutations']);
        pTestY = testY(randperm(length(testY)));
        %store accuracy
        for k = 1:length(predictedY)
            if predictedY(k) == pTestY(k)
                correctPreds = correctPreds + 1;
            else
                incorrectPreds = incorrectPreds + 1;
            end
        end
        corrMat(j,i) = correctPreds;
        allMat(j,i) = correctPreds + incorrectPreds;
        correctPreds = 0;
        incorrectPreds = 0;
        
    end

end