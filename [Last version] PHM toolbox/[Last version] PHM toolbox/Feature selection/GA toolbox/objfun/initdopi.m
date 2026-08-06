% INITialzation function for DOuble Integrator objdopi
%
% This function initializes the Double Integrator.
%
% Syntax:  [Chrom, VLUB] = initdopi(Nind, VLUB, method, TSTART, TEND)
%
% Input parameters:
%    Nind      - Number of individuals
%    VLUB      - Matrix containing the boundaries of the variables
%    method    - (optional) method of simulation
%    TSTART    - (optional) start time
%    TEND      - (optional) end time
%
% Output parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%    VLUB      - (optional) Matrix containing the new boundaries
%                of the variables
%                
% See also: objdopi, initfun1

% Author:     Hartmut Pohlheim
% History:    24.08.95     file created


function [Chrom, VLUB] = initdopi(Nind, VLUB, method, TSTART, TEND);

% Compute population parameters
   Nvar = size(VLUB, 2);
 
% Check input parameters 
   if nargin < 3, method = 1; end     % 1 - sim: simulink model
   if nargin < 4, TSTART = 0; end
   if nargin < 5, TEND   = 1; end

% Create population, this is for illustration, there is no real meaning
   Chrom = rand(Nind, Nvar);
   Chrom = (Chrom <  0.5) .* repmat(VLUB(1,:), [Nind, 1]) + ...
           (Chrom >= 0.5) .* repmat(VLUB(2,:), [Nind, 1]);

% End of function

