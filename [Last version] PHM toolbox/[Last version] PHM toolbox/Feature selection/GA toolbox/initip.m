% CReaTe an initial (Integer value) Population
%
% This function creates a population of given size of random integer value.
%
% It is ensured, that the values are created uniform at random, even at the 
% bounds of the initialization range.
% What is the problem? 
% Try hist(initip(10000, [1; 10])), look for the first and last area.
% Then try hist(initip(10000, [0.5001; 10.4999])) for a solution.
% Thus, the upper and lower boundary is extended, to give the bounded
% integers also a uniform initialization range of (nearly) 1.
%
% Syntax:  Chrom = initip(Nind, FieldDR);
%
% Input parameters:
%    Nind      - A scalar containing the number of individuals in the new population.
%    VLUB      - A matrix of size 2 by number of variables describing the boundaries 
%                of each variable. The bounds should be integers, to get an even 
%                distribution of the values.
%                For more info, see initrp.
%
% Output parameter:
%    Chrom     - A matrix containing the random valued individuals of the
%                new population of size Nind by number of variables.
%
% See also: initrp, initbp

% Author:   Hartmut Pohlheim
% History:  17.10.1997  file created
%           13.03.2005  bounds are extended by (nearly) 0.5 for uniform initialization
%                       at the defined bounds


function Chrom = initip(Nind, VLUB);

% Create initial population

   % First, extend the bound array
   ValExtend = 0.4999;
   VLUBIntern = VLUB + repmat([-ValExtend; ValExtend], [1, size(VLUB,2)]);
   
   % Create real population and round the values
   Chrom = round(initrp(Nind, VLUBIntern));


   % Generate the random numbers.
   % r = floor(rand(m, n) * (distance+1));

   % Offset the numbers to the specified value.
   % out = ones(m,n)*range(1);
   % out = out + r;




% End of function
