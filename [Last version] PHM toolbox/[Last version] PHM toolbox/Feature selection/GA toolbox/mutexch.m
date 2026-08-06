% MUTation by eXCHange
%
% This function takes the current population, mutates each element
% with given mutation probability by exchanging it with another 
% element and returns the resulting population.
%
% Syntax:  NewChrom = mutexch(Chrom, VLUB, MutRate)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    VLUB      - Matrix containing the boundaries of each variable.
%                not used here, necessary for compatibility with
%                real valued mutation
%    MutRate   - Scalar containing the mutation rate / probability.
%                if omitted or NaN MutRate = 1/size(Chrom,2) is
%                assumed.
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutate, mutswap, mutreal, mutbin, mutint, initip

% Author:   Hartmut Pohlheim
% History:  15.05.98    file created
%                       same calling syntax as real valued mutation
%                          (VLUB is second parameter and ignored)
%           20.07.98    comments updated, name changed to mutexch


function NewChrom = mutexch(Chrom, VLUB, MutRate)

% get population size (Nind) and chromosome length (VarLength)
   [Nind, VarLength] = size(Chrom);

% Check input parameters
   if nargin < 3, MutRate = []; end
   if isnan(MutRate), MutRate = []; end
   if isempty(MutRate), MutRate = 1/VarLength; end
   MutRate = MutRate(1);

% Perform mutation of individuals
   % check each parameter of each individual for mutation
   [XchInd, XchVar] = find(rand(Nind, VarLength) < MutRate);
   % find the element to exchange with
   XchWith = ceil(VarLength * rand(size(XchInd)));
   % exchange the parameters (cannot be vectorised due to multiple swaps)
   for elem = 1:length(XchInd),
      temp = Chrom(XchInd(elem), XchVar(elem));
      Chrom(XchInd(elem), XchVar(elem)) = Chrom(XchInd(elem), XchWith(elem));
      Chrom(XchInd(elem), XchWith(elem)) = temp;
   end
   NewChrom = Chrom;


% End of function