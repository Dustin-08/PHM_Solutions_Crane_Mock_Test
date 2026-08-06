% RECombination Multi-Point, low level function
%
% This function takes a matrix OldChrom containing the 
% individuals in the current population, applies recombination
% to consecutive pairs of individuals with probability RecRate 
% and returns the resulting offspring.
% The number of recombination points to use and the forced 
% production of offspring different from their parents can be
% parametrized.
% Every representation of the variables can be used.
% This function is a low level function used by the corresponding
% higher level function, for instance: recsp, recdp, recshrs.
%
% Syntax:  NewChrom = recmp(OldChrom, RecRate, RecXpt, RecRs)
%
% Input parameters:
%    OldChrom  - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual
%                (in binary form).
%    RecRate   - Probability of recombination ocurring between pairs
%                of individuals.
%    RecXpt    - Scalar indicating the number of crossover points
%                1: single point recombination
%                2: double point recombination
%                0: shuffle point recombination
%    RecRs     - reduced surrogate
%                0: no reduced surrogate
%                1: reduced surrogate
%
% Output parameter:
%    NewChrom  - Matrix containing the offspring after mating, 
%                ready to be mutated and/or evaluated, in the same 
%                format as OldChrom.
%
% See also: recombin, recdp, recsh, recsp, recdprs, recsprs, recshrs

% Author:   Hartmut Pohlheim
% History:  31.05.95    file created
%           24.07.97    calculation of Mask changed for compatibility
%                       with Matlab5, see MaskIsZero
%           07.04.98    names of parameters changed


function NewChrom = recmp(OldChrom, RecRate, RecXpt, RecRs);

% Identify the population size (Nind) and the chromosome length (Nvar)
   [Nind, Nvar] = size(OldChrom);

% Set default parameters
   if Nvar < 2, NewChrom = OldChrom; return; end

   if nargin < 4, RecRs = []; end
   if nargin < 3, RecXpt = []; end
   if nargin < 2, RecRate = []; end
   if isnan(RecRate), RecRate = []; end
   if isnan(RecXpt), RecXpt = []; end
   if isnan(RecRs), RecRs = []; end
   if isempty(RecRate), RecRate = 0.7; end
   if isempty(RecXpt), RecXpt = 0; end
   if isempty(RecRs), RecRs = 0; end

   Xops = floor(Nind/2);
   DoCross = rand(Xops,1) < RecRate;
   odd = 1:2:Nind-1;
   even = 2:2:Nind;

% Compute the effective length of each chromosome pair
   Mask = ~RecRs | (OldChrom(odd, :) ~= OldChrom(even, :));
   Mask = cumsum(Mask')';
   % Check for Mask with all zero ==> both individuals are identical
   % set values to one to remove warning divide by zero in xsites(:,2)= ...
   MaskIsZero = find(Mask(:, Nvar)==0);
   Mask(MaskIsZero,:) = ones(length(MaskIsZero), size(Mask, 2));
   % if any(Mask(:, Nvar)==0), Mask(:, Nvar), end

% Compute cross sites for each pair of individuals, according to their
% effective length and RecRate (two equal cross sites mean no recombination)
   xsites(:, 1) = Mask(:, Nvar);
   if RecXpt >= 2,
      xsites(:, 1) = ceil(xsites(:, 1) .* rand(Xops, 1));
   end
   xsites(:,2) = rem(xsites + ceil((Mask(:, Nvar)-1) .* rand(Xops, 1) ) ...
                     .* DoCross - 1 , Mask(:, Nvar) ) + 1;

% Express cross sites in terms of a 0-1 mask
   Mask = (xsites(:,ones(1,Nvar)) < Mask) == (xsites(:,2*ones(1,Nvar)) < Mask);

   if ~RecXpt,
      shuff = rand(Nvar,Xops);
      [ans,shuff] = sort(shuff);
      for i=1:Xops
         OldChrom(odd(i),:)=OldChrom(odd(i),shuff(:,i));
         OldChrom(even(i),:)=OldChrom(even(i),shuff(:,i));
      end
   end

% Perform recombination
   NewChrom(odd,:)  = (OldChrom(odd,:) .*   Mask)  + (OldChrom(even,:) .* (~Mask));
   NewChrom(even,:) = (OldChrom(odd,:) .* (~Mask)) + (OldChrom(even,:) .*   Mask);

% If the number of individuals is odd, the last individual cannot be mated
% but must be included in the new population
   if rem(Nind,2), NewChrom(Nind,:)=OldChrom(Nind,:); end

   if ~RecXpt,
      [ans,unshuff] = sort(shuff);
      for i=1:Xops
         NewChrom(odd(i),:)=NewChrom(odd(i),unshuff(:,i));
         NewChrom(even(i),:)=NewChrom(even(i),unshuff(:,i));
      end
   end


% End of function
