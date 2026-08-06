% INITialize an Real value Population
%
% This function creates a population of given size of random real values. 
%
% Syntax:  Chrom = initrp(Nind, VLUB);
%
% Input parameters:
%    Nind      - A scalar containing the number of individuals in the new population.
%    VLUB      - A matrix of size 2 by number of variables describing the
%                boundaries of each variable. It has the following structure:
%                [lower_bound;   (vector with lower bound for each veriable)
%                 upper_bound]   (vector with upper bound for each veriable)
%                [lower_bound_variable_1  lower_bound_var_2 ... lower_bound_var_Nvar;
%                 upper_bound_variable_1  upper_bound_var_2 ... upper_bound_var_Nvar]
%                example - each individuals consists of 4 variables:
%                   VLUB = [-100 -50 -30 -20;   % lower bound
%                            100  50  30  20]   % upper bound
%              
% Output parameter:
%    Chrom     - A matrix containing the random valued individuals of the
%                new population of size Nind by number of variables.
%
% See also: initip, initbp, initpp, initpop

% Example:
%   VLUB = [-100 -50 -30 -20;   % lower bound
%            100  50  30  20]   % upper bound
%   % population (matrix) with five individuals (rows) and 4 variables
%   % each (number of columns in VLUB), first variable uniform at 
%   % random between -100 and 100, second between -50 and 50 and so on
% >>Chrom = initrp(5, VLUB)
% Chrom =   
%    18.0217   -9.1233   -2.1582    5.1708
%    91.0818  -35.8180   27.6657  -14.9315
%    11.2292    6.4899  -22.4382    6.0501
%   -70.3697  -24.7874  -18.0146    4.8654
%    96.6610   -1.1485  -10.8450   12.1229

% Author:   Hartmut Pohlheim
% History:  23.11.94    file created
%           25.02.95    clean up, check parameter consistency
%           21.10.96    error checking improved, messages changed
%                       example added
%           13.10.99    error/warning handling updated


function Chrom = initrp(Nind, VLUB);

% Check parameter consistency
   if nargin < 2, error('parameter VLUB missing'); end

   [NindRow, NindCol] = size(Nind);
   if any([NindRow, NindCol] ~= 1), Nind = Nind(1); warning('Number of individuals to create must be a scalar!'); end

   [VLUBRow, Nvar] = size(VLUB);
   if VLUBRow < 2, error('VLUB must be a matrix with 2 rows!'); end
   if VLUBRow > 2, VLUB = VLUB([1,2],:); end

   if any(VLUB(1,:) > VLUB(2,:)),
      error('At least one lower bound is greater than the corresponding upper bound!');
   end

% Create initial population
   % Compute Matrix with Range of variables and Matrix with Lower value
   Range = repmat((VLUB(2,:) - VLUB(1,:)), [Nind 1]);
   Lower = repmat(VLUB(1,:), [Nind 1]);

   % Each row contains one individual, the values of each variable uniformly
   % distributed between lower and upper bound (given by VLUB)
   Chrom = rand(Nind, Nvar) .* Range + Lower;


% End of function
