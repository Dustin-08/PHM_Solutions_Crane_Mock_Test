% INITialzation function for de jong's FUNction 1
%
% This function initializes the DE JONG function 1.
%
% Syntax:  [Chrom, VLUB] = initfun1(Nind, VLUB, value)
%
% Input parameters:
%    Nind      - Number of individuals
%    VLUB      - Matrix containing the boundaries of the variables
%    P1 - Px   - Additional parameters
%
% Output parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%    VLUB      - (optional) Matrix containing the new boundaries
%                of the variables
%                
% See also: objfun1

% Author:     Hartmut Pohlheim
% History:    01.08.95     file created


function [Chrom, VLUB] = initfun1(Nind, VLUB, value);

% Check input parameters 
   if nargin < 3, value = 100; end

% Compute population parameters
   Nvar = size(VLUB, 2);
   VLUB = repmat([-value; value], [1, Nvar]);
 
% Create initial population
   Chrom = repmat(value, [Nind, Nvar]);
   Chrom2 = rand(size(Chrom)) < .5;
   Chrom = Chrom .* (-Chrom2) + Chrom .* (~Chrom2);

% End of function

