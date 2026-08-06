% SHARing between individuals
%
% This function performs sharing between individuals.
% This is used during the calculation of fitness values in 
% the ranking of multiple objective values.
%
% Syntax:  FitnVShare = rankshare(Chrom, FitnV, ShareOpt)
%
% Algorithm reference: 
%    The sharing function is implemented according to:
%       Goldberg & Richardson, Deb & Goldberg
%
% Input parameters:
%    ShareV    - Matrix containing the individuals or objective values 
%                of the population (sharing in search or solution space)
%    FitnV     - Vector containing the fitness values of the individuals
%    ShareOpt  - (optional) Vector containing sharing option
%                ShareOpt(1): ShareSigma
%                ShareOpt(2): ShareAlpha
%                ShareOpt(3): ShareBeta
%
% Output parameters:
%    FitnVShare- Column vector containing the shared fitness values
%
% See also: ranking

% Author:   Hartmut Pohlheim
% History:  28.04.99    file created
%           19.05.99    parameter checking updated
%           25.05.99    comments added
%           23.01.01    vectorized sharing included


function FitnVShare = rankshare(ShareV, FitnV, ShareOpt)

   % Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(ShareV);
   
   % When just one Individual or dimension provided nothing to share
   if any([Nind == 1, Nvar == 1]), FitnVShare = FitnV; return; end

   % Set standard sharing parameter
   ShareOptStandard = [1e-2, 1, 1];      % ShareSigma = 1e-2, ShareAlpha = 1, ShareBeta = 1

   % Check parameter consistency
   if nargin < 1,  error('Not enough input parameter (at least one necessary).'); end

   if nargin < 2, FitnV = []; end
   if isnan(FitnV), FitnV = []; end
   if isempty(FitnV), FitnV = ones(Nind, 1); end
   
   if nargin < 3, ShareOpt = []; end
   if isnan(ShareOpt), ShareOpt = []; end
   if length(ShareOpt) > length(ShareOptStandard), 
      warning('Too many parameters in ShareOpt');
      ShareOpt = ShareOpt(1:length(ShareOptStandard));
   end

   ShareOptIntern = ShareOptStandard; ShareOptIntern(1:length(ShareOpt)) = ShareOpt;
   ShareSigma = ShareOptIntern(1); ShareAlpha = ShareOptIntern(2); ShareBeta = ShareOptIntern(3);

   if ~(ShareSigma > 0),
      if ~(isnan(ShareSigma)), warning('Parameter for share sigma too small.'); end
      ShareSigma = ShareOptStandard(1);
   end

   if ~(ShareAlpha > 0),
      if ~(isnan(ShareAlpha)), warning('Parameter for share alpha too small.'); end
      ShareAlpha = ShareOptStandard(2);
   end
   
   if ~(ShareBeta > 0),
      if ~(isnan(ShareBeta)), warning('Parameter for share beta too small.'); end
      ShareBeta = ShareOptStandard(3);
   end

   % Vectorized Sharing
   
   % Compute full distance matrix including main diagonal
   Dist = compdiv('distance_chrom_mat_2', ShareV);
   
   % Penalty for all individuals too close together
   Share = (1 - (Dist / ShareSigma) .^ ShareAlpha) .* (Dist < ShareSigma);
   FitnVShare = FitnV ./ (sum(Share, 2).^ShareBeta);

   % another variant with the same effect
   % Share = ((Dist / ShareSigma) .^ ShareAlpha) .* (Dist < ShareSigma) + (Dist >= ShareSigma);
   % FitnVShare = sum(Share, 2).^ShareBeta .* FitnV ./ (Nind-1);


% End of function