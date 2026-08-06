% MUTation for INTeger representation
%
% This function takes the integer representation of the current
% population, mutates each element with given probability and 
% returns the resulting population.
%
% Syntax:  NewChrom = mutint(Chrom, VLUB, MutOpt)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    VLUB      - Matrix containing the boundaries of each variable.
%                not used here, necessary for compatibility with
%                real valued mutation
%    MutOpt    - (optional) Vector containing mutation options (similar
%                           to real valued mutation in mutreal)
%                MutOpt(1): MutRate - number containing the mutation rate -
%                           probability for mutation of a variable
%                           if omitted or NaN, MutRate = 1/variables per individual
%                           is assumed
%                MutOpt(2): MutRange - (optional) number for shrinking the
%                           mutation range in the range [0 1], possibility to
%                           shrink the range of the mutation depending on,
%                           for instance actual generation.
%                           if omitted or NaN, MutRange = 1 is assumed
%                MutOpt(3): MutPreci - (optional) precision of mutation steps
%                           if omitted or NaN, MutPreci = 16 is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutate, mutreal, mutbmc, mutbin, initip

% Author:   Hartmut Pohlheim
% History:  17.10.97    file created
%                       same calling syntax then real valued mutation
%           02.03.98    excluded setting of variables to boundaries, 
%                          when variables outside boundaries


function NewChrom = mutint(Chrom, VLUB, MutOpt)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind,Nvar] = size(Chrom);

% Set standard mutation parameter
   MutOptStandard = [1/Nvar, 1, 16];      % MutRate = 1/Nvar, MutRange = 1, MutPreci = 16

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end

   [mF, nF] = size(VLUB);
   if mF ~= 2, error('VLUB must be a matrix with 2 rows'); end
   if Nvar ~= nF, error('VLUB and Chrom disagree'); end

   if nargin < 3, MutOpt = []; end
   if isnan(MutOpt), MutOpt = []; end
   if length(MutOpt) > length(MutOptStandard), error(' Too many parameter in MutOpt'); end

   MutOptIntern = MutOptStandard; MutOptIntern(1:length(MutOpt)) = MutOpt;
   MutRate = MutOptIntern(1); MutRange = MutOptIntern(2); MutPreci = MutOptIntern(3);

   if isnan(MutRate), MutRate = MutOptStandard(1);
   elseif (MutRate < 0 | MutRate > 1), error('Parameter for mutation rate must be a scalar in [0, 1]'); end

   if isnan(MutRange), MutRange = MutOptStandard(2);
   elseif (MutRange < 0 | MutRange > 1), 
      error('Parameter for shrinking mutation range must be a scalar in [0, 1]');
   end

   if isnan(MutPreci), MutPreci = MutOptStandard(3);
   elseif MutPreci <= 1, error('Parameter for mutation precision must be greater than 1'); end

% the variabels are mutated with probability MutRate
% NewChrom = Chrom (+ or -) * Range * MutRange * Delta
% Range = 0.5 * (upperbound - lowerbound)
% Delta = Sum(Alpha_i * 2^-i) from 0 to MutPreci; Alpha_i = rand(MutPreci,1) < 1/MutPreci

% Matrix with range values for every variable
   Range = repmat(ceil(MutRange * (VLUB(2,:) - VLUB(1,:))), [Nind 1]);

% Calculate step size
   % Defines the steepness or Kurvigkeit of the exponential function
   % Higher values produce a less curved function
   % Good value: 2
   MutSteep = 2;
   % "Table Lookup" into the exponential function exp(-MutPreci/MutSteep)
   % Produces values between 0 and 1, most values are small,
   % only a few are large
   Steps = exp(-(MutPreci/MutSteep) * rand(Nind, Nvar));
   % Convert step sizes to domain or Range area
   Steps = round(Steps .* Range);
   % Ensure, that all steps < 1 are set to 1
   Steps = Steps .* (Steps >= 1) + 1 * (Steps < 1);

% zeros and ones for mutation or not of this variable
   Steps = Steps .* (rand(Nind, Nvar) < MutRate);

% Compute, if + or - sign 
   Steps = Steps .* (1 - 2 * (rand(Nind, Nvar) < 0.5));

% Perform mutation 
   NewChrom = Chrom + Steps;

% Ensure variables are integer
   NewChrom = round(NewChrom);
   

% End of function


% Test of steepness
% MutSteep=24; t=rand(500,1); ekurv=exp(MutSteep/2*(-t));
% figure(2); hist(ekurv,100); figure(3); plot(sort(ekurv),'r.');
