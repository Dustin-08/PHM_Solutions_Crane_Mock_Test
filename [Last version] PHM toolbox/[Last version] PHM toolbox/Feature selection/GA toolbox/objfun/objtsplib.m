% OBJective function for the traveling salesman library
%
% This function computes the length of the routes given by the
% individuals. The variables of the individuals define the order
% of the points to travel. The distance between all points is 
% given by the parameter option (DistMat).
% These problems are known as Travelling salesman (TSP).
% This function provides the objective function for most of the
% problems in the TSPLIB.
%
% Syntax: ObjVal = objtsplib(routes, option)
%
% Input parameter:
%    routes    - Matrix containg the variables of the individuals 
%                   (the points of the routes).
%    option    - if routes contains a matrix with the individuals, 
%                   than option contains the name of the tsp example 
%                   file (TSPLibFunName)
%                elseif routes == [], than
%                option == 1 (or []) return boundaries (here just 
%                             the number of variables and the 
%                             corresponding upper/lower bounds)
%                option == 2 return title for figures or docu
%                option == 3 return value of global minimum
%    TSPLibFunName - additional parameter, string with name of TSPLib problem 
%                    see objtsplib for more info
%
% Output parameter:
%    ObjVal    - Matrix containing the objective values for the individuals
%                  in routes (length of the routes).
%
% See also: scrtsplib, tbxperm, initpp, mutswap, mutexch, recgp, recpm

% Author:   Hartmut Pohlheim
% History:  09.09.1998  file created
%           10.02.2004  changed error in computing dist (irout instead of i)
%           28.05.2005  rework of function


function ObjVal = objtsplib(routes, option, AddPara1)

   % Define global variables
   global TSPLIB_FILENAME;
   global TSPLIB_NAME;
   global TSPLIB_COMMENT;
   global TSPLIB_DIMENSION;
   global TSPLIB_GLOBALOPT;
   global TSPLIB_BESTTOUR;
   global TSPLIB_DISPLAYDATA;
   global TSPLIB_EDGEWEIGHT;

   if isempty(routes),
      if isempty(TSPLIB_NAME), tsp_readlib(TSPLIB_FILENAME); end
      % Default dimension of objective function
      Dim = TSPLIB_DIMENSION;
      % return text of title for graphic output
      if option == 2
         ObjVal = sprintf('TSPLIB: %s', TSPLIB_NAME);
      % return value of global minimum
      elseif option == 3
         ObjVal = 13029;
      % define size of boundary-matrix and values
      else   
         % these values are not really used, 
         % however, the toolbox needs the number of variables
	      ObjVal = [ones(1, Dim); Dim * ones(1, Dim)];
      end
   else
      % Get number of routes and their length
      [Nroutes, Lroute] = size(routes);

      % Read the edge weight matrix from the global variable
      if isempty(TSPLIB_EDGEWEIGHT),
         error('Edge Weight Matrix is not available !');
      else  DistMat = TSPLIB_EDGEWEIGHT; end
   
      % Calculate the distance of each route
      dist = zeros(Nroutes, 1);
      for irout = 1:Nroutes,
         % diag(DistMat(routes(irout,1:Lroute), routes(irout,[2:Lroute,1])))
         dist(irout) = sum(diag(DistMat(routes(irout,1:Lroute), routes(irout,[2:Lroute,1]))));

         % old unvectorized version, takes 4-5 times as long as vectorized
         % for j = 2:Lroute, dist(irout) = dist(irout) + DistMat(routes(irout, j - 1), routes(irout, j)); end
         % dist(irout) = dist(irout) + DistMat(routes(irout, Lroute), routes(irout, 1));
      end
      ObjVal = dist;
      
   end
   

% End of function