% OBJective function for the traveling salesman example
%
% This function computes the length of the routes given by the
% individuals. The variables of the individuals define the order
% of the points to travel. The distance between all points is 
% given by the parameter option (DistMat).
% These problems are known as Travelling salesman (TSP).
%
% Syntax: ObjVal = objtsp1(routes, option)
%
% Input parameter:
%    routes    - Matrix containg the variables of the individuals 
%                   (the points of the routes).
%    option    - if routes contains a matrix with the individuals, 
%                   than option contains the distance matrix between 
%                   the citys (points of travel),
%                elseif routes == [] and
%                option == 1 (or []) return boundaries (here just 
%                             the number of variables and the 
%                             corresponding upper/lower bounds)
%                option == 2 return title for figures or docu
%                option == 3 return value of global minimum
%
% Output parameter:
%    ObjVal    - Matrix containing the objective values for the individuals
%                  in routes (length of the routes).
%
% See also: scrtsp1, tbxperm, initpp, mutswap, mutexch, recgp, recpm

% Author:   Hartmut Pohlheim
% History:  22.07.1998  file created
%           08.09.1998  many comments added


function ObjVal = objtsp1(routes, option)

   if isempty(routes),
      % Default dimension of objective function
      Dim = 20;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['Travelling Salesman 1'];
      % return value of global minimum
      elseif option == 3
         ObjVal = 13029;
      % define size of boundary-matrix and values
      else   
      % these values are not necessary, the toolbox just needs the number of variables
         VLB = ones(1, Dim);
         VUB = Dim * ones(1, Dim);
	      ObjVal = [VLB; VUB];
      end
   else
      % Get number of routes and their length
      [Nroutes, Lroute] = size(routes);
      DistMat = option;
   
      % Calculate the distance of each route
      dist = zeros(Nroutes, 1);
      dist1= zeros(Nroutes, 1);
      for i = 1:Nroutes,
         % diag(DistMat(routes(i,1:Lroute), routes(i,[2:Lroute,1])))
         dist(i) = sum(diag(DistMat(routes(i,1:Lroute), routes(i,[2:Lroute,1]))));

         % old unvectorized version, takes 4-5 times as long as vectorized
         % for j = 2:Lroute, dist(i) = dist(i) + DistMat(routes(i, j - 1), routes(i, j)); end
         % dist(i) = dist(i) + DistMat(routes(i, Lroute), routes(i, 1));
      end
      ObjVal = dist;
      
   end
   

% End of function