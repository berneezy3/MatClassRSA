function [sigma,shrinkage]=cov1para(x,shrink)
% Disclaimer: This piece of code was obtained from Guggenmos et al. 2018.
%-------------------------------------------------------------------
%  [sigma,shrinkage] = cov1para(x,shrink)
%-------------------------------------------------------------------
%
% This function shrinks input data towards one-parameter matrix:
% all covariances are the same, all covariances are zero.
%
% INPUTS:
%   x - Data matrix of size nSpace x nTrial
%   shrink (optional) - value is used for shrinkage. If not entered or
%   entered as -1, the function will compute the shrinkage estimator.
%
% OUTPUTS:
%   sigma (n*n)- invertible covariance matrix estimator
%   shrinkage - the user-specified shrink parameter, used for shrinkage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is released under the BSD 2-clause license.

% Copyright (c) 2014, Olivier Ledoit and Michael Wolf 
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Disclaimer: This piece of code was obtained from Guggenmos et al. 2018.

% de-mean returns
[t,n]=size(x);
meanx=mean(x);
x=x-meanx(ones(t,1),:);

% compute sample covariance matrix
sample=(1/t).*(x'*x);

% compute prior
meanvar=mean(diag(sample));
prior=meanvar*eye(n);

if (nargin < 2 | shrink == -1) % compute shrinkage parameters
  
  % what we call p 
  y=x.^2;
  phiMat=y'*y/t-sample.^2;
  phi=sum(sum(phiMat));
  
  % what we call r is not needed for this shrinkage target
  
  % what we call c
  gamma=norm(sample-prior,'fro')^2;

  % compute shrinkage constant
  kappa=phi/gamma;
  shrinkage=max(0,min(1,kappa/t));
    
else % use specified number
  shrinkage=shrink;
end

% compute shrinkage estimator
sigma=shrinkage*prior+(1-shrinkage)*sample;







