% Conversion of individuals in routes and routes in individuals for the VRP
%
% This function converts individuals to routes and back.
% The representation of routes is not directly suitable for 
% optimization (at least in GEATbx using the well known 
% permutation operators).
% Thus, a simple but powerful representation for individuals
% was employed.
% The conversion from individuals to routes is used inside 
% the objective function before calling the cost function.
% The conversion from routes to individuals is called in the 
% demo function, when special initialization functions are 
% used (which produce routes).
% The description of both representations can be found below.
%
% Description of coding/format
%   1. routes 
%      - the depot gets always the number 1
%      - each route starts with the depot and finishes at the depot,
%        thus each route starts with 1 and ends with 1
%      - the customers get numbers from 2 to the number of customers+1
%      
%      Examples for route representation:
%      % 1 route with 5 customers
%      >> RouteIndIn = {[1 2 5 3 6 4 1]}
%      
%      % 2 routes serving 3 and 6 customers (9 customers at all)
%      >> RouteIndIn = {[1 3 9 7 1], [1 8 2 10 4 6 5 1]}
%
%      % 5 routes serving 3, 2, 6, 3 and 4 customers (18 customers at all)
%      >> RouteIndIn = {[1 10 5 6 1], [1 8 4 1], [1 12 3 16 9 15 19 1], [1 7 11 2 1], [1 18 14 13 17 1]}
%      
%   
%   2. Individuals
%      - must represent a variable number of variable lengths routes 
%        (all with a fixed length chromosome with integers from up to ...)
%      - customers get numbers from 1 to the number of customers
%      - dividers of routes are numbers larger than the maximal number 
%        of customers
%      - the maximal number of routes is given by the number of numbers 
%        largers than the max number of customers (any more numbers ? :-)
%      - have a look to the examples, it is not this difficult
%      - there is more than one possibility to code a given number of routes
%      - this representation ensures, that the standard operators for 
%        permutation problems can be used, including the random initialization
%        % Ind = initpp(1, NumCustomers+MaxVehicles-1)
%        >> Ind = initpp(1, 9+2-1)
%
%      Examples for individual representation:
%      % 1 route with 5 customers (max 1 vehicle)
%      >> RouteIndIn = [1 4 2 5 3]
%
%      % 1 route with 5 customers (max 2 vehicle)
%      >> RouteIndIn = [6 1 4 2 5 3]
%      >> RouteIndIn = [1 4 2 5 3 6]
%
%      % 2 routes with 5 customers (max 2 vehicle)
%      >> RouteIndIn = [1 4 2 6 5 3]
%
%      % 5 customers (max 3 vehicle), 1, 2 or 3 routes
%      >> RouteIndIn = [6 1 4 2 5 3 7]  % 1 route
%      >> RouteIndIn = [6 1 4 7 2 5 3]  % 2 routes
%      >> RouteIndIn = [1 4 7 2 5 6 3]  % 3 routes
%      % Convert individual to Routes (size of VRPData.XYData needed for conversion)
%      >> VRPData.XYData=ones(5+2-1,1); 
%      >> Routes = vrpconvind('ind2route', RouteIndIn, VRPData)
%
%      % 2 routes serving 3 and 6 customers (9 customers at all, max 2 vehicles)
%      >> RouteIndIn = [2 8 6 10 7 1 9 3 5 4]
%      % Convert individual to Routes (size of VRPData.XYData needed for conversion)
%      >> VRPData.XYData=ones(9+2-1,1); 
%      >> Routes = vrpconvind('ind2route', [2 8 6 10 7 1 9 3 5 4], VRPData)
%
% Syntax: RouteIndOut = vrpconvind(ConvType, RouteIndIn, VRPData)
%
% Input parameter:
%    ConvType   - String defining the kind of conversion
%                 'ind2route': convert the individuals to routes
%                              used in objective function before calling 
%                              the cost function
%                 'route2ind': convert routes to individuals
%                              used in initilization function to convert the 
%                              generated routes to individuals
%    RouteIndIn - Matrix containing the routes or individuals to convert
%    VRPData    - Structure containing the problem specific data (parts are 
%                 needed for the conversion)
%                 see vrpgetdata for the structure of VRPData
%
% Output parameter:
%    RouteIndOut - similar to RouteIndIn the converted individuals or routes
%
% Examples for conversion
% % Get problem specific data for VRP 
% >> VRPData = vrpgetdata('sol25_r101');
% % Create an individual (randomly) and convert to a route (25 customers, max 10 vehicles)
% >> Ind = initpp(1, 25+10)
% >> Routes = vrpconvind('ind2route', Ind, VRPData)
% % Show the routes
% >> prprintf(Routes)
% % Plot the routes
% >> plotvrp('objvrp', Ind, 1, VRPData)
%
% See also: vrpgetdata, objvrp, demovrp, plotvrp

% Author:   Hartmut Pohlheim
% History:  28.05.2005  file created


function RouteIndOut = vrpconvind(ConvType, RouteIndIn, VRPData)

   NAIN = nargin; NAOUT = nargout;

   % Number of customers (number of rows in XYData minus the depot)
   NumCustomer = size(VRPData.XYData,1) - 1;

   % Get number of routes/individuals and their length
   [Nroutes, Lroute] = size(RouteIndIn);

   switch lower(ConvType),
      case 'ind2route',
         for irout = 1:Nroutes,
            % Create the route
            RouteIndOut = {}; NumRoute = 1; CurRoute = 1;
            for icust = 1:Lroute,
               AddCust = 1;
               if RouteIndIn(irout, icust) <= NumCustomer,
                  CurRoute = [CurRoute, RouteIndIn(irout, icust) + 1];
               else
                  AddCust = 0;
               end
               if any([AddCust == 0, icust == Lroute]),
                  if length(CurRoute) > 1,
                     CurRoute = [CurRoute, 1];
                     RouteIndOut{irout, NumRoute} = CurRoute;
                     NumRoute = NumRoute + 1;
                     CurRoute = 1;
                  end
               end
            end
         end
         % RouteIndOut
         % prprintf(RouteIndOut)

   end


% End of function